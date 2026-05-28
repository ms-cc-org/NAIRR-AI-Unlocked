# Workshop guide: running the forecasting workflow

This guide is for workshop participants who clone this repository and run the
same ML forecasting workflow on their own allocation.

The repository has three parts:

- `forecasting.ipynb`: the portable notebook that trains and evaluates the model.
- `platforms/<platform>/`: setup notes, Conda exports, and launch scripts for each platform.

## 1. Choose your platform

Start with the platform that matches your allocation:

| Platform | Execution style | Start here |
| --- | --- | --- |
| JetStream2 | VM, interactive shell | `platforms/jetstream2/docs/execution.md` |
| Anvil | HPC, Slurm batch job | `platforms/anvil/docs/execution.md` |

## 2. Clone the repository

On the system where you will run the workflow:

```bash
mkdir -p ~/repos
cd ~/repos
git clone https://github.com/ms-cc-org/NAIRR-AI-Unlocked.git
cd NAIRR-AI-Unlocked
```

## 3. Stage the dataset

The notebook expects the temperature dataset at:

```bash
data/temperature-us/
```

The expected files include:

```bash
data/temperature-us/city_info.csv
data/temperature-us/*.csv
```

### Stage the Dataset

The forecasting workflow requires a historical temperature dataset convering 210 US cities. The notebook expects at `data/tempareture-us/` in the repo root.

**Download the dataset from link:** https://kilthub.cmu.edu/articles/dataset/Compiled_daily_temperature_and_precipitation_data_for_the_U_S_cities/7890488

**Size:** 292 MB

**On VM/HPC:**
```bash
cd ~/MSCCAM/NAIRR-AI-Unlocked
mkdir -p data
```

To get the paths:
- Use `pwd` on Mac
- Use `cd` on Windows

Run this command from a new command prompt or terminal:
`rsync -avP path / to /7890488/ ubuntu@<IP>:~/MSCCAM/NAIRR-AI-Unlocked/data/temperature-us/`

**Verify on VM/HPC:** `ls -1 data/temperature-us/*.csv | wc -l  # Should output 211`

The dataset directory is intentionally ignored by Git.

## 4. Create the Conda environment

Use the environment export for your platform:

```bash
conda env create -f platforms/<platform>/env_exports/<platform>-forecast.yml
conda activate <environment-name>
```

Environment names used by the platform scripts:

| Platform | Environment | Kernel |
| --- | --- | --- |
| JetStream2 | `js2-gpu-forecast` | `js2-forecast` |
| Anvil | `anvil-forecast` | default active Python |

If your platform-specific export is too tied to the original machine, create a
fresh Python 3.10 environment and install the minimum packages:

```bash
conda create -n <environment-name> python=3.10 -y
conda activate <environment-name>
conda install -y -c conda-forge pandas numpy scikit-learn jupyter nbconvert ipykernel tqdm joblib
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
python -m ipykernel install --user --name <kernel-name> --display-name "<kernel-name>"
```

## 5. Configure the run

The notebook reads these environment variables (change these values as you see fit for your instance):

```bash
export PLATFORM_LABEL="<your-platform>"
export N_CITIES=210
export EPOCHS=50
export BATCH_SIZE=8192
export NUM_WORKERS=8
export WIDTH=1024
export DEPTH=8
export DROPOUT=0.1
export LAGS="1,3,7,14,30,60"
export ROLLS="7,30"
export SEED=42
```

For a quick smoke test during the workshop, reduce runtime:

```bash
export N_CITIES=10
export EPOCHS=2
export BATCH_SIZE=1024
```

For benchmark comparisons, use the full settings in the platform guide or the
provided Slurm/run script.

Optional preflight check:

```bash
bash scripts/preflight.sh <platform>
```

## 6. Run the workflow

JetStream2:

```bash
bash platforms/jetstream2/scripts/run_jetstream2.sh
```

Anvil:

1. Edit the `#SBATCH -A` line in the platform Slurm script to use your allocation.
2. Confirm the partition, GPU type, memory, and time limit are valid for your allocation.
3. Submit the job.

```bash
sbatch platforms/anvil/slurm/run_anvil_gpu.slurm
```

## 7. Check outputs

A successful run writes:

```text
outputs/reports/*.executed.ipynb
outputs/metrics/history.csv
outputs/metrics/epoch_timing.csv
outputs/metrics/run_summary.json
outputs/metrics/test_metrics.json
outputs/models/mlp_state.pt
outputs/models/feature_scaler.pkl
results/benchmarks/run_metadata.json
results/benchmarks/benchmark_row.csv
```

For Slurm jobs, inspect the scheduler logs first:

```bash
tail -n 80 results/benchmarks/slurm_<jobid>.err
tail -n 80 results/benchmarks/nbconvert_stderr_<platform>.txt
```

## 8. Compare results

Each run appends one row to:

```text
results/benchmarks/benchmark_row.csv
```

Archived examples live under `runs/<platform>/<date>/results/summary.md` and
`runs/<platform>/<date>/results/benchmarks/benchmark_row.csv`.

## Workshop readiness checklist

Before the live session:

- Confirm each platform allocation name and queue/partition.
- Confirm participants can SSH into their assigned system.
- Confirm Conda or Miniconda is available.
- Confirm the dataset has been staged or internet access is available to mirror it.
- Run one smoke test with `N_CITIES=10` and `EPOCHS=2`.
- Run one full benchmark per platform for comparison evidence.