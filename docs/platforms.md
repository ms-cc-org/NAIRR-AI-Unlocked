# Platform guides

For a participant-facing walkthrough, start with:

- `WORKSHOP.md`

Pick your platform and follow the execution guide:

- JetStream2: `platforms/jetstream2/docs/execution.md`
- Anvil (HPC GPU, Slurm): `platforms/anvil/docs/execution.md`

Quick command index:

```bash
bash scripts/run.sh
bash platforms/jetstream2/scripts/run_jetstream2.sh
sbatch platforms/anvil/slurm/run_anvil_gpu.slurm
```

Before running, stage the dataset at `data/temperature-us` and create the platform Conda environment from `platforms/<platform>/env_exports/`.