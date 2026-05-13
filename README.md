# NAIRR AI Unlocked

**Reproducible AI Workflows for Research, Education, and National Cyberinfrastructure**

Workshop: [AI Unlocked: Empowering Higher Education through Research and Discovery](https://www.colorado.edu/rc/ai-unlocked-empowering-higher-education-through-research-and-discovery)

Session: *Lowering the Barrier to AI Research: Reproducible Workflows Across Cloud and National Infrastructure*
Presented by Amanda Tan and Pavan Nara

---

## Overview

NAIRR AI Unlocked is a hands-on educational repository developed to support the AI Unlocked workshop. It provides a practical, reproducible machine learning workflow designed to run across multiple computational environments, including cloud platforms and national cyberinfrastructure systems such as JetStream2 and Anvil.

The repository is supported through ACCESS, the NAIRR Pilot, and the University of Colorado Boulder Research Computing program. Its central purpose is to help researchers, educators, and students move from local experimentation to scalable, reproducible AI workflows running on shared computational infrastructure.

Many researchers can successfully run AI workflows in isolated notebook environments but encounter significant operational barriers when transitioning to larger-scale or collaborative systems. This repository addresses those barriers directly, with a focus on operational clarity, reproducibility, and infrastructure awareness rather than model complexity.

---

## Goals of This Repository

- Demonstrate a portable, end-to-end ML workflow that runs reproducibly across multiple compute environments
- Establish CPU and GPU execution baselines and support direct performance comparisons
- Help researchers understand the operational differences between local, cloud, and HPC systems
- Lower the technical barriers to using national cyberinfrastructure
- Support teaching, research, and workforce development activities
- Serve as a reusable framework for onboarding researchers to NAIRR and ACCESS resources

The emphasis throughout is on operational understanding and reproducibility, not model accuracy or novelty.

---

## Workshop Context

This repository supports the [AI Unlocked: Empowering Higher Education through Research and Discovery](https://www.colorado.edu/rc/ai-unlocked-empowering-higher-education-through-research-and-discovery) workshop, which brings together researchers, educators, students, cyberinfrastructure professionals, and AI practitioners from across higher education.

Workshop focus areas include:

- AI research workflows and reproducibility
- Cloud and HPC onboarding
- AI-assisted coding and AI literacy
- Equitable access to AI infrastructure
- Workforce development, with particular attention to emerging research institutions including HBCUs, TCUs, and MSIs

---

## Who This Repository Is For

You do not need extensive HPC experience to begin. This repository is designed for:

- Researchers beginning to explore AI workflows on shared infrastructure
- Faculty integrating AI into teaching or research
- Students learning practical AI and HPC skills
- Research computing facilitators and workshop instructors
- Institutions building AI readiness programs

---

## Relationship to NAIRR

The National AI Research Resource (NAIRR) is designed to broaden access to advanced AI compute resources, reduce barriers to entry for researchers and students, and enable reproducible and portable AI workflows across heterogeneous systems.

In practice, many researchers begin their work on laptops, campus servers, or cloud notebooks such as Colab or JupyterHub. Moving these workflows onto national AI infrastructure introduces new challenges:

- Different hardware architectures and batch scheduling environments
- Reproducibility requirements across systems
- Resource constraints and performance scaling considerations

This repository supports the NAIRR mission by providing a portable, end-to-end ML workflow with CPU and GPU execution paths, reproducible execution evidence, and a direct performance comparison framework across NAIRR and cloud GPU systems.

---

## What You Will Learn

- Running AI workflows non-interactively via Jupyter notebooks and nbconvert
- Managing reproducible environments with Conda
- Executing workflows on GPU-enabled systems
- Using Slurm to submit and manage batch jobs on HPC systems
- Comparing interactive VM (JetStream2) and batch HPC (Anvil) execution models
- Benchmarking workflow performance across CPU and GPU environments
- Understanding the operational differences between cloud and national cyberinfrastructure

---

## The Workflow

The repository is built around a single ML forecasting workflow that runs identically across multiple platforms. The workflow trains a multi-layer perceptron (MLP) model on a historical temperature dataset covering 210 US cities, producing execution metrics and benchmark output for comparison.

### Core Notebook: `forecasting.ipynb`

The notebook contains the complete ML pipeline:

- Data loading and feature engineering (lag features, rolling statistics)
- Model training (PyTorch MLP) with configurable architecture and hyperparameters
- Evaluation and test metrics
- Benchmark output written to `results/`

The notebook is designed for non-interactive, automated execution via nbconvert. All parameters are read from environment variables, making it straightforward to adjust the run configuration without editing the notebook.

### Configurable Parameters

| Variable | Default | Description |
|---|---|---|
| `PLATFORM_LABEL` | *(required)* | Label written into benchmark output |
| `N_CITIES` | `210` | Number of cities to include in training |
| `EPOCHS` | `50` | Training epochs |
| `BATCH_SIZE` | `8192` | Batch size |
| `NUM_WORKERS` | `8` | DataLoader worker processes |
| `WIDTH` / `DEPTH` | `1024` / `8` | MLP hidden layer width and depth |
| `DROPOUT` | `0.1` | Dropout rate |
| `LAGS` | `1,3,7,14,30,60` | Lag features (days) |
| `ROLLS` | `7,30` | Rolling window sizes (days) |
| `SEED` | `42` | Random seed |

For a quick smoke test during the workshop, use `N_CITIES=10` and `EPOCHS=2` to reduce runtime.

---

## Repository Structure

```
NAIRR-AI-Unlocked/
├── forecasting.ipynb              # Portable ML notebook: data loading, feature engineering, training, evaluation
├── WORKSHOP.md                    # Step-by-step participant guide
├── docs/
│   └── platforms.md               # Platform index and quick command reference
├── platforms/
│   ├── jetstream2/                # Execution guide, Conda environment export, run script
│   └── anvil/                     # Execution guide, Conda environment export, Slurm job script
├── scripts/                       # Utility scripts including preflight.sh
├── outputs/                       # Executed notebooks, metrics, models, logs (written at runtime)
├── results/
│   └── benchmarks/                # Benchmark rows and run metadata (written at runtime)
└── runs/                          # Archived execution evidence from previous platform runs
```

> The dataset (`7890488/`) is not included in the repository and must be staged separately. See the Quick Start section below.

---

## Supported Platforms

| Platform | Execution Style | Start Here |
|---|---|---|
| JetStream2 | VM, interactive shell, GPU | `platforms/jetstream2/docs/execution.md` |
| Anvil | HPC cluster, Slurm batch job, GPU | `platforms/anvil/docs/execution.md` |

The workflow is also adaptable to other ACCESS resources and national cyberinfrastructure environments. The Conda environment definitions and parameterized notebook design are intended to minimize platform-specific changes.

---

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/ms-cc-org/NAIRR-AI-Unlocked.git
cd NAIRR-AI-Unlocked
```

### 2. Stage the Dataset

The notebook expects the dataset at `7890488/` in the repository root. On platforms with internet access:

```bash
git clone --depth 1 https://github.com/radames/dataset-historical-daily-temperature-210-US.git 7890488_src
rsync -avP 7890488_src/ 7890488/
```

Alternatively, transfer from a local copy:

```bash
rsync -avP /path/to/7890488/ <user>@<host>:~/NAIRR-AI-Unlocked/7890488/
```

### 3. Create the Conda Environment

Use the environment export for your platform:

```bash
conda env create -f platforms/<platform>/env_exports/<platform>-forecast.yml
conda activate <environment-name>
```

If the platform export does not transfer cleanly to a new allocation, install the minimum packages manually. See [`WORKSHOP.md`](WORKSHOP.md) for the minimal install commands.

### 4. Run the Workflow

JetStream2:

```bash
bash platforms/jetstream2/scripts/run_jetstream2.sh
```

Anvil (edit the `#SBATCH -A` line to your allocation first):

```bash
sbatch platforms/anvil/slurm/run_anvil_gpu.slurm
```

### 5. Check Outputs

A successful run produces:

- `outputs/reports/*.executed.ipynb` — executed notebook with full output
- `outputs/metrics/` — epoch timing, run summary, and test metrics
- `outputs/models/` — trained model weights and feature scaler
- `results/benchmarks/benchmark_row.csv` — one row per run for cross-platform comparison

For full step-by-step instructions, see [`WORKSHOP.md`](WORKSHOP.md).

---

## Benchmarking Approach

Each run of the workflow uses the same dataset, notebook, environment definition, and training configuration. This enables direct comparison of:

- Time per epoch and total training time
- CPU versus GPU speedup
- Resource utilization and cost per run

Each run appends a row to `results/benchmarks/benchmark_row.csv`. Archived execution evidence from prior runs is stored under `runs/<platform>/<date>/` and includes the executed notebook, benchmark row, and a run summary.

---

## Reproducibility

Reproducibility is a central design goal of this repository. The workflow achieves it through:

- Pinned Conda environment exports per platform
- A fixed random seed (configurable via `SEED` environment variable)
- Non-interactive notebook execution via nbconvert
- All configuration passed through environment variables, not hardcoded values
- Execution evidence archived per run, including the executed notebook, logs, and metrics

The goal is not simply to run a model, but to produce a workflow that is portable, auditable, and repeatable across different systems and over time.

---

## Related Resources

- [AI Unlocked Workshop](https://www.colorado.edu/rc/ai-unlocked-empowering-higher-education-through-research-and-discovery)
- [University of Colorado Boulder Research Computing](https://www.colorado.edu/rc/national-ai-workshop)
- [NAIRR Pilot](https://nairrpilot.org/)
- [ACCESS](https://access-ci.org/)

---

## Contributing

Contributions are welcome. Areas of particular interest include:

- Additional platform guides and environment exports
- Workflow enhancements and reproducibility improvements
- Educational adaptations for classroom or workshop use
- Infrastructure testing on additional ACCESS resources
- Workshop materials and onboarding documentation

---
