# NAIRR AI Unlocked Tutorial

This repository demonstrates a **reproducible machine learning workflow** designed to run across multiple compute environments such as Anvil and JetStream2.


## Workshop quickstart

If you are using this repository in a workshop/tutorial, start with:

- [WORKSHOP.md](WORKSHOP.md)
- [docs/platforms.md](docs/platforms.md)

The workshop path is:

1. Clone the repository on your assigned platform.
2. Stage the dataset in `7890488/`.
3. Create the platform Conda environment from `platforms/<platform>/env_exports/`.
4. Run the platform script or Slurm job.
5. Check `outputs/` and `results/` for the executed notebook, metrics, logs, and benchmark row.

---

## Relationship to NAIRR

The National AI Research Resource (NAIRR) is designed to:

- Broaden access to advanced AI compute resources
- Reduce barriers to entry for researchers and students
- Enable reproducible and portable AI workflows
- Support training and experimentation across heterogeneous systems

However, many researchers begin their work on:

- Laptops
- Campus servers
- Cloud notebooks (such as Colab, jupyterhub)

Moving these workflows onto national AI infrastructure introduces new challenges:

- Different hardware architectures
- Batch scheduling environments
- Resource constraints
- Reproducibility requirements
- Performance scaling considerations

This repository supports the NAIRR mission by:

- Providing a **portable, end-to-end ML workflow**
- Establishing a **CPU baseline execution**
- Capturing **reproducible execution evidence**
- Enabling **direct performance comparisons** across NAIRR and cloud GPU systems

---

## Purpose of this repository

This project demonstrates how a single ML workflow can:

1. Run reproducibly on multiple platforms
2. Produce measurable performance improvements
3. Support cross-platform benchmarking

The focus is not on model accuracy, but on **execution performance across systems**.

---

## Platform structure

This repository is organized as a single workflow with platform-specific execution packs.

Start here:
- `WORKSHOP.md`
- `docs/platforms.md`

Platform-specific assets live under:
- `platforms/<platform>/`
  - `docs/` execution guide
  - `env_exports/` environment export
  - `scripts/` or `slurm/` run wrappers or Slurm job scripts

## Benchmarking approach

The workflow is designed to run identically across multiple systems. Each run uses:

- The same dataset
- The same notebook
- The same environment definition
- The same training configuration

This enables direct comparison of:

- Time per epoch
- Total training time
- Resource utilization
- Cost per run
- Speedup between CPU and GPU environments

---

## Core components of the workflow

### Reproducible environments
**Folder:** `platforms/<platform>/env_exports/`

Defines the Python and ML dependencies captured during platform execution.
If an export is too platform-specific for a new allocation, use the minimal
package install shown in `WORKSHOP.md`.

---

### Machine learning workflow
**File:** `forecasting.ipynb`

This notebook contains the full ML pipeline:

- Data loading
- Feature engineering
- Model training
- Evaluation

It is designed for **non-interactive, automated execution**.

---

## How to reproduce the JetStream2 run

1. Launch a JetStream2 instance.
2. Clone the repository.
3. Create and activate the environment:
```
    conda env create -f platforms/jetstream2/env_exports/jetstream2-forecast.yml
    conda activate js2-gpu-forecast
```
4. Execute:
```
   bash platforms/jetstream2/scripts/run_jetstream2.sh
```

## How to Reproduce Anvil Run

Use the platform guide, update the `#SBATCH -A YOUR_ALLOCATION` line, and submit:

```
sbatch platforms/anvil/slurm/run_anvil_gpu.slurm
```

See `WORKSHOP.md` for the participant workflow and `docs/platforms.md` for all
platform-specific guides.

---

## Expected outcome

This repository will produce a **simple, reproducible performance comparison** across:

- CPU-based development environments
- Cloud GPU systems
- NAIRR-supported AI supercomputing resources

The result will be:

- A clear scaling story from CPU to national AI systems
- Evidence-based guidance for researchers choosing NAIRR resources
- A reusable benchmark framework for onboarding new users

## Choose your platform

Start here:

- `WORKSHOP.md`
- `docs/platforms.md`

Platform-specific scripts, environment exports, and Slurm job files are under:
`platforms/<platform>/`

Execution evidence (executed notebooks + benchmarks + system snapshots) is archived under:
`runs/<platform>/<date>/`