# JetStream2 Execution Protocol

This document describes the exact procedure used to execute the forecasting
workflow on a JetStream2 instance.

---

## 1. Create GPU Instance (Exosphere)

- Select Ubuntu image
- Choose GPU flavor
- Attach SSH key
- Assign floating IP
- Launch

Verify GPU:

    nvidia-smi

---

## 2. Clone Repository

    mkdir -p ~/repos
    cd ~/repos
    git clone https://github.com/ms-cc-org/NAIRR-AI-Unlocked.git
    cd NAIRR-AI-Unlocked
    git rev-parse HEAD

---

## 3. Create Environment

    conda env create -f platforms/jetstream2/env_exports/jetstream2-forecast.yml
    conda activate js2-gpu-forecast

    python -m ipykernel install --user --name js2-forecast --display-name "js2-forecast"

Verify GPU inside Python:

    import torch
    torch.cuda.is_available()

---

## 4. Stage Dataset

The notebook expects the dataset at `data/temperature-us/` in the repository root.

**Download the dataset from link:** https://kilthub.cmu.edu/articles/dataset/Compiled_daily_temperature_and_precipitation_data_for_the_U_S_cities/7890488

**On VM:**
```bash
cd ~/MSCCAM/NAIRR-AI-Unlocked
mkdir -p data
```

To get the paths:
- Use `pwd` on Mac
- Use `cd` on Windows

Run this command from a new command prompt or terminal **not on the VM**:
`rsync -avP path / to /7890488/ ubuntu@<IP>:~/MSCCAM/NAIRR-AI-Unlocked/data/temperature-us/`

**Verify on VM/HPC:** `ls -1 data/temperature-us/*.csv | wc -l  # Should output 211`

---

## 5. Execute Notebook

    These values can be edited for initial tests or full benchmark runs. By increasing 
the batch size, epochs, you can make it more of a benchmarking run and complex.

    export PLATFORM_LABEL="JetStream2"
    export N_CITIES=210
    export EPOCHS=25
    export BATCH_SIZE=4096
    export NUM_WORKERS=8
    export WIDTH=1024
    export DEPTH=8
    export DROPOUT=0.1
    export LAGS="1,3,7,14,30,60"
    export ROLLS="7,30"

    /usr/bin/time -v jupyter nbconvert \
      --to notebook \
      --execute forecasting.ipynb \
      --ExecutePreprocessor.kernel_name=js2-forecast \
      --ExecutePreprocessor.timeout=7200 \
      --output outputs/reports/forecasting.executed.ipynb \
      2> results/benchmarks/time_forecast_gpu.txt

Optional GPU monitoring:

    nvidia-smi --query-gpu=timestamp,name,utilization.gpu,utilization.memory,memory.used,memory.total \
      --format=csv -l 1 > results/benchmarks/gpu_metrics.csv

---

## 6. Capture System Snapshot

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
      echo "PIP_FREEZE"; pip freeze
    } > results/system/jetstream2_gpu_env.txt

---

Or use the provided wrapper:

    bash platforms/jetstream2/scripts/run_jetstream2.sh

## 7. Commit Evidence

Commit:

- results/system/*
- results/benchmarks/*
- outputs/metrics/*
