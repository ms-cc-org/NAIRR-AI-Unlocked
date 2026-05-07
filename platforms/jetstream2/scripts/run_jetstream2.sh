#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
cd "$REPO_ROOT"

echo "Activating conda..."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate js2-gpu-forecast

TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")
MACHINE="JetStream2"
outputs_dir="outputs/${MACHINE}/${TIMESTAMP}"
results_dir="results/${MACHINE}/${TIMESTAMP}"

mkdir -p "${results_dir}/system" "${results_dir}/benchmarks"
mkdir -p "${outputs_dir}/metrics" "${outputs_dir}/models" "${outputs_dir}/reports"


export PLATFORM_LABEL="${PLATFORM_LABEL:-JetStream2}"
export N_CITIES="${N_CITIES:-5}"
export EPOCHS="${EPOCHS:-1}"
export BATCH_SIZE="${BATCH_SIZE:-64}"
export WIDTH="${WIDTH:-128}"
export DEPTH="${DEPTH:-1}"
export DROPOUT="${DROPOUT:-0.1}"
export LAGS="${LAGS:-1}"
export ROLLS="${ROLLS:-7}"
export NUM_WORKERS="${NUM_WORKERS:-0}"
export PREFETCH_FACTOR="${PREFETCH_FACTOR:-1}"
export SEED="${SEED:-42}"

echo "Running notebook..."
/usr/bin/time -v jupyter nbconvert \
  --to notebook \
  --execute forecasting.ipynb \
  --ExecutePreprocessor.kernel_name=js2-gpu-forecast \
  --ExecutePreprocessor.timeout=600 \
  --output "${outputs_dir}/reports/forecasting.executed.ipynb" \
  > "${results_dir}/benchmarks/nbconvert_stdout_js2.txt" \
  2> "${results_dir}/benchmarks/nbconvert_stderr_js2.txt"

{
  echo "DATE"; date -Is
  echo "GIT_COMMIT"; git rev-parse HEAD
  echo "HOST"; hostname
  echo "OS"; uname -a
  echo "CPU"; lscpu
  echo "MEM"; free -h
  echo "DISK"; df -h
  echo "NVIDIA_SMI"; nvidia-smi || true
  echo "CONDA"; conda --version
  echo "ACTIVE_ENV"; echo "$CONDA_DEFAULT_ENV"
  echo "PYTHON"; which python
  echo "JUPYTER"; which jupyter
} > "${results_dir}/system/jetstream2_env_snapshot.txt"

echo "Done."

