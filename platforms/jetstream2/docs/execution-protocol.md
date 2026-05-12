# JetStream2 Execution Guide

## 0. What This Workflow Does
This workflow runs a weather forecasting notebook: `forecasting.ipynb`

The notebook uses historical daily weather data from multiple U.S. cities and trains a neural network to predict next day:
- maximum temperature
- minimum temperature
- precipitation

The run is controlled using environment variables such as:
- N_CITIES
- EPOCHS
- BATCH_SIZE
- WIDTH
- DEPTH
- LAGS
- ROLLS
- NUM_WORKERS

That means the same notebook can be used for either:
- a small test run
- a CPU baseline run
- a larger benchmark run
- a GPU run, if the instance has working GPU drivers

## 1. Create a JetStream2 Instance
Use Exosphere to create your JetStream2 instance.
Official guide: https://docs.jetstream-cloud.org/getting-started/first-instance/

Recommended choices:
- Image: Ubuntu
- Flavor: choose based on your allocation and whether you need CPU or GPU
- SSH key: attach your public SSH key
- Floating IP: assign one so you can SSH into the instance
After launching, note your public IP address such as 149.165.xxx.xxx

You will use this IP to connect from your local computer.

## 2. SSH Into the Instance
From your local machine terminal or command line: ssh ubuntu@<PUBLIC_IP>

Example: `ssh ubuntu@149.165.xxx.xxx`

The first time you connect, you may see:
The authenticity of host cannot be established. Are you sure you want to continue connecting?
Type: `yes`
You should then land inside the JetStream2 instance as the ubuntu user.

## 3. Clone the Repository

Inside the JetStream2 instance:
- Create a folder to clone the repo: `mkdir -p ~/{folder-name}`
- Go into the folder: `cd ~/{folder-name}`
- Clone the repo: `git clone https://github.com/ms-cc-org/NAIRR-AI-Unlocked.git`
- Open the repo: `cd NAIRR-AI-Unlocked`

## 4. Load Miniforge / Conda
On your JetStream2 instance, load the Miniforge module:
`module load miniforge/24.7.1-0`
Check that Conda is available: `conda --version`
Expected output: `conda 24.7.1`

## 5. Create the Conda Environment
Create the environment from the JetStream2 environment file:
`conda env create -f platforms/jetstream2/env_exports/jetstream2-forecast.yml`
Activate it:
`conda activate js2-gpu-forecast`
If You See a conda error `CondaError: Run 'conda init' before 'conda activate'`
Run:
- `conda init bash`
- `source ~/.bashrc`
- `conda activate js2-gpu-forecast`

## 6. Register the Jupyter Kernel
The notebook is executed using nbconvert, so the Conda environment must be registered as a Jupyter kernel.
Run:
```bash
python -m ipykernel install --user \
  --name js2-gpu-forecast \
  --display-name "js2-gpu-forecast"
```
Verify available kernels: `jupyter kernelspec list`
Then you should see: `js2-gpu-forecast`

## 7. Stage the Dataset

From inside the repo, create the dataset folder:
`mkdir -p 7890488`

To get the path, use `pwd`

From your local machine open another terminal or cmd, copy the dataset to JetStream2:
`rsync -avP /path/to/7890488/ ubuntu@<PUBLIC_IP>:~/{folder-name}/NAIRR-AI-Unlocked/7890488/`

For example: `rsync -avP ~/Downloads/7890488/ ubuntu@149.165.xxx.xxx:~/{folder-name}/NAIRR-AI-Unlocked/7890488/`

Back on JetStream2, verify the dataset:
`cd ~/{folder-name}/NAIRR-AI-Unlocked`

## 8. Create Output Folders Before Running
`mkdir -p outputs/reports outputs/metrics outputs/models results/benchmarks results/system`

## 9. Check Whether This Is CPU or GPU
Run: `nvidia-smi`
**If You See GPU Information:** Then the instance has access to an NVIDIA GPU and working drivers. You can run a GPU benchmark.
**If You See:** NVIDIA-SMI has failed because it couldn't communicate with the NVIDIA driver. Then this is not a usable GPU environment. The workflow can still run, but it will run as a CPU baseline. 

Also check PyTorch:
```bash
python - <<'PY'
import torch
print("torch version:", torch.__version__)
print("cuda available:", torch.cuda.is_available())
print("device count:", torch.cuda.device_count())
if torch.cuda.is_available():
    print("gpu name:", torch.cuda.get_device_name(0))
PY
```

## 10. Run a small test 
Use this before running a full benchmark.
This confirms that:
- the repo is cloned correctly
- the dataset is in the right place
- the Conda environment works
- the notebook executes through nbconvert
- output folders are being written correctly

```bash
cd ~/{folder-name}/NAIRR-AI-Unlocked

export PLATFORM_LABEL="JetStream2"
export N_CITIES=20
export EPOCHS=2
export BATCH_SIZE=64
export WIDTH=128
export DEPTH=1
export DROPOUT=0.1
export LAGS="1"
export ROLLS="7"
export NUM_WORKERS=0
export PREFETCH_FACTOR=1
export SEED=42

/usr/bin/time -v jupyter nbconvert \
  --to notebook \
  --execute forecasting.ipynb \
  --ExecutePreprocessor.kernel_name=js2-gpu-forecast \
  --ExecutePreprocessor.timeout=7200 \
  --output outputs/reports/forecasting.executed.ipynb \
  2> results/benchmarks/time_forecast_small_test.txt
```

## 11. Verify the Smoke Test
After the run finishes:

```bash
ls -lah outputs/reports/forecasting.executed.ipynb
ls -lah results/benchmarks/time_forecast_smalll_test.txt
ls -lah outputs/metrics
ls -lah outputs/models
ls -lah results/benchmarks
```
Expected:
- outputs/reports/forecasting.executed.ipynb
- results/benchmarks/time_forecast_smoke_test.txt
- outputs/metrics/history.csv
- outputs/metrics/run_summary.json
- outputs/metrics/test_metrics.json
- outputs/models/mlp_state.pt
- outputs/models/feature_scaler.pkl
- results/benchmarks/run_metadata.json
- results/benchmarks/benchmark_row.csv

## 12. Full run (CPU only)
Use this when JetStream2 does not have a working GPU.

```bash
cd ~/{folder-name}/NAIRR-AI-Unlocked

mkdir -p outputs/reports outputs/metrics outputs/models results/benchmarks results/system

export PLATFORM_LABEL="JetStream2-CPU"
export N_CITIES=210
export EPOCHS=25
export BATCH_SIZE=4096
export WIDTH=1024
export DEPTH=8
export DROPOUT=0.1
export LAGS="1,3,7,14,30,60"
export ROLLS="7,30"
export NUM_WORKERS=8
export PREFETCH_FACTOR=4
export SEED=42

/usr/bin/time -v jupyter nbconvert \
  --to notebook \
  --execute forecasting.ipynb \
  --ExecutePreprocessor.kernel_name=js2-gpu-forecast \
  --ExecutePreprocessor.timeout=7200 \
  --output outputs/reports/forecasting.jetstream2_cpu.executed.ipynb \
  2> results/benchmarks/time_forecast_jetstream2_cpu.txt
```
This gives you a reproducible CPU baseline.
 
## 13. Run a GPU Benchmark (If GPU Is Available)
Only use this section if: `nvidia-smi` works and: `python -c "import torch; print(torch.cuda.is_available())"` prints: `True`
Start GPU monitoring in a separate terminal or background process: `mkdir -p results/benchmarks`

```bash
nvidia-smi \
  --query-gpu=timestamp,name,utilization.gpu,utilization.memory,memory.used,memory.total \
  --format=csv \
  -l 1 > results/benchmarks/gpu_metrics.csv &
```

Save the monitor process ID: `echo $! > results/benchmarks/gpu_monitor.pid`

Then run the notebook: 
```bash
cd ~/{folder-name}/NAIRR-AI-Unlocked
mkdir -p outputs/reports outputs/metrics outputs/models results/benchmarks results/system

export PLATFORM_LABEL="JetStream2-GPU"
export N_CITIES=210
export EPOCHS=25
export BATCH_SIZE=4096
export WIDTH=1024
export DEPTH=8
export DROPOUT=0.1
export LAGS="1,3,7,14,30,60"
export ROLLS="7,30"
export NUM_WORKERS=8
export PREFETCH_FACTOR=4
export SEED=42

/usr/bin/time -v jupyter nbconvert \
  --to notebook \
  --execute forecasting.ipynb \
  --ExecutePreprocessor.kernel_name=js2-gpu-forecast \
  --ExecutePreprocessor.timeout=7200 \
  --output outputs/reports/forecasting.jetstream2_gpu.executed.ipynb \
  2> results/benchmarks/time_forecast_jetstream2_gpu.txt
```

Stop GPU monitoring: `kill "$(cat results/benchmarks/gpu_monitor.pid)"`
Check GPU metrics:
`head results/benchmarks/gpu_metrics.csv`
`tail results/benchmarks/gpu_metrics.csv`

## 14. Capture System Snapshot

Run this after the notebook finishes.

`cd ~/{folder-name}/NAIRR-AI-Unlocked`

`mkdir -p results/system`

```bash
{
  echo "DATE"; date -Is
  echo "GIT_COMMIT"; git rev-parse HEAD
  echo "HOST"; hostname
  echo "OS"; uname -a
  echo "CPU"; lscpu
  echo "MEM"; free -h
  echo "DISK"; df -h
  echo "GPU"; nvidia-smi
  echo "CONDA"; conda --version
  echo "ACTIVE_ENV"; echo $CONDA_DEFAULT_ENV
  echo “PYTHON”; echo python --version
  echo "PIP_FREEZE"; pip freeze
} > results/system/jetstream2_env_snapshot.txt
```

## 15. Commit or Archive the Evidence
After a successful run, preserve the evidence.
```bash
git status
git add results/system
git add results/benchmarks
git add outputs/metrics
git add outputs/reports/*.executed.ipynb
git commit -m "Add JetStream2 forecasting benchmark evidence"
```
If Git ignores outputs or results, check: `cat .gitignore`