const { test } = require('node:test');
const assert = require('node:assert/strict');
const awaitCI = require('./await-ci.cjs');
const context = { repo: { owner: 'team', repo: 'api' }, sha: 'abc', ref: 'refs/heads/develop' };
const success = { id: 10, head_sha: 'abc', head_branch: 'develop', head_repository: { full_name: 'team/api' }, event: 'push', status: 'completed', conclusion: 'success' };
function harness(runs) {
  const outputs = {};
  let calls = 0;
  return { outputs, args: { context, attempts: 2, sleep: async () => {}, core: { setOutput: (k,v) => outputs[k] = v }, github: { rest: { actions: { listWorkflowRuns: async params => {
    assert.equal(params.workflow_id, 'ci.yml');
    assert.equal(params.head_sha, context.sha);
    return { data: { workflow_runs: runs[Math.min(calls++, runs.length - 1)] } };
  } } } } } };
}
test('accepts the successful push CI and exposes its artifact run', async () => {
  const h = harness([[success]]); await awaitCI(h.args); assert.equal(h.outputs.run_id, '10');
});
for (const conclusion of ['failure', 'cancelled', 'skipped', 'timed_out']) {
  test(`blocks ${conclusion}`, async () => {
    const h = harness([[{ ...success, conclusion }]]); await assert.rejects(awaitCI(h.args), /CD bloqueado/); assert.deepEqual(h.outputs, {});
  });
}
for (const override of [{head_sha:'other'}, {head_branch:'main'}, {event:'pull_request'}, {head_repository:{full_name:'fork/api'}}]) {
  test(`rejects unrelated execution ${JSON.stringify(override)}`, async () => {
    const h = harness([[{ ...success, ...override }]]); await assert.rejects(awaitCI(h.args), /40 minutos/);
  });
}
test('waits for completion', async () => {
  const h = harness([[{ ...success, status:'in_progress' }], [success]]); await awaitCI(h.args); assert.equal(h.outputs.run_id, '10');
});
test('fails closed when no CI is found', async () => { const h = harness([[]]); await assert.rejects(awaitCI(h.args)); });
test('does not reuse an older success after a newer failure', async () => {
  const h = harness([[success, { ...success, id:11, conclusion:'failure' }]]); await assert.rejects(awaitCI(h.args), /11: failure/);
});
test('API permission errors block deployment', async () => {
  const h = harness([[]]); h.args.github.rest.actions.listWorkflowRuns = async () => { throw new Error('403'); };
  await assert.rejects(awaitCI(h.args), /403/);
});
