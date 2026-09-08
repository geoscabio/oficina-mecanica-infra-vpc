// Only a successful push CI for this exact repository, branch and commit authorizes CD.
module.exports = async ({ github, context, core, sleep = ms => new Promise(resolve => setTimeout(resolve, ms)), attempts = 120 }) => {
  for (let attempt = 0; attempt < attempts; attempt++) {
    const { data } = await github.rest.actions.listWorkflowRuns({
      ...context.repo, workflow_id: 'ci.yml', head_sha: context.sha,
      branch: context.ref.replace('refs/heads/', ''), event: 'push', per_page: 100
    });
    const run = data.workflow_runs
      .filter(run => run.head_sha === context.sha && run.event === 'push' &&
        run.head_branch === context.ref.replace('refs/heads/', '') &&
        run.head_repository?.full_name === `${context.repo.owner}/${context.repo.repo}`)
      .sort((a, b) => b.id - a.id)[0];
    if (run?.status === 'completed') {
      if (run.conclusion !== 'success') throw new Error(`CI ${run.id}: ${run.conclusion}. CD bloqueado.`);
      core.setOutput('run_id', String(run.id));
      return;
    }
    await sleep(20000);
  }
  throw new Error('CI do commit não concluiu dentro de 40 minutos. CD bloqueado.');
};
