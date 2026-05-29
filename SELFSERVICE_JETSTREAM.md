# Self-Service Guide — Running the AI Forecasting Workflow on JetStream2

This guide takes you from zero to a running GPU benchmark on JetStream2. It assumes you did not attend a facilitated workshop, or you did and want to reproduce everything independently on your own allocation.

**Estimated time:** 2–3 hours end to end, mostly waiting on environment setup and training.

---

## What you need before you start

- A US-based institutional affiliation (required for NAIRR/ACCESS)
- An ACCESS account — free, takes ~10 minutes to register
- A JetStream2 allocation — free to request, approval takes 1–3 business days
- A modern browser (Chrome or Firefox work best with Exosphere)

If you already have an ACCESS account and a JetStream2 allocation, skip to [Step 2](#step-2--launch-a-jetstream2-instance).

---

## Step 1 — Get an ACCESS account and JetStream2 allocation

### Register for ACCESS

Go to [access-ci.org](https://access-ci.org) and click **"Register"**. Use your institutional email. You will verify via your institution's identity provider (the same login you use for campus systems).

Once registered, note your ACCESS username — it is typically `FirstLast` or similar, and it is separate from your institutional username.

### Request a JetStream2 allocation

The fastest path for individuals and small groups is an **Explore ACCESS** allocation — low barrier to entry, enough resources for this tutorial and early-stage research.

1. Log in at [allocations.access-ci.org](https://allocations.access-ci.org)
2. Click **"Request New Allocation"** → **"Explore ACCESS"**
3. Fill in the project title, abstract (~150 words describing your research goals), and requested resources
4. Under resources, select **Jetstream2 GPU** and request **1,000–5,000 SUs** (Service Units) to start
5. Submit — decisions typically come within 1–3 business days

> **What is an SU?** A Service Unit is roughly one CPU-core-hour. GPU allocations cost more SUs per hour than CPU-only instances. A single full benchmark run on a GPU instance costs approximately 4–8 SUs. Your starting allocation will cover dozens of runs.

Once approved, your allocation appears in the ACCESS portal and is available in Exosphere within a few hours.

---

## Step 2 — Launch a JetStream2 instance

### Open Exosphere

Go to [jetstream2.exosphere.app](https://jetstream2.exosphere.app) and log in with your ACCESS credentials.

If prompted to select an allocation, choose your JetStream2 allocation.

### Create an instance

1. Click **"Create"** → **"Instance"**
2. **Choose an image:** Select **Featured Images** and pick **Ubuntu 22.04 (latest)**
3. **Choose a flavor** (size): For this tutorial, `g3.small` (1 GPU, 10 vCPUs, 60GB RAM) is sufficient. If `g3.small` is unavailable, try `m3.quad` (no GPU, but good for testing environment setup) and switch to a GPU flavor for the actual benchmark
4. **Enable Web Shell** — this should be on by default; confirm it is checked under "Advanced Options"
5. **Name your instance** something memorable (e.g., `nairr-workshop`)
6. Click **"Create"**

Instance creation takes 5–10 minutes. You will see status progress in the Exosphere dashboard.

### Connect via web shell

Once the instance status shows **"Ready"**:

1. Click **"Connect to"** → **"Web Shell"**
2. A new browser tab opens with a terminal logged in as `exouser`

> **Pasting commands:** Use `Ctrl+Alt+Shift` (Windows/Linux) or `Ctrl+Cmd+Shift` (Mac) to open the Guacamole clipboard panel, paste your text there, then use `Shift+Insert` or right-click to paste into the terminal.

> **Important — shelve when not in use:** JetStream2 charges SUs while an instance is running, even if you are not computing. When you are done for the day, go to Exosphere → instance → **"Actions"** → **"Shelve"**. This preserves your data and stops SU consumption. **Do not delete the instance** unless you want to lose your work.

---

## Step 3 — Set up the environment

All of the following commands run in the web shell on your JetStream2 instance.

### Install Miniconda (if not present)

```bash
conda --version
```

If this returns a version number, skip to the next section. If not:

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3
eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
echo 'eval "$($HOME/miniconda3/bin/conda shell.bash hook)"' >> ~/.bashrc
```

### Clone the repository

```bash
mkdir -p ~/repos
cd ~/repos
git clone https://github.com/ms-cc-org/NAIRR-AI-Unlocked.git
cd NAIRR-AI-Unlocked
```

### Stage the dataset

The notebook expects the dataset at `~/repos/NAIRR-AI-Unlocked/7890488/`. JetStream2 has outbound internet access, so you can pull it directly:

```bash
mkdir -p ~/data
git clone --depth 1 \
  https://github.com/radames/dataset-historical-daily-temperature-210-US.git \
  ~/data/7890488_src
rsync -avP ~/data/7890488_src/ ./7890488/
```

Verify:
```bash
ls 7890488/ | wc -l   # should return 211
```

### Build the Conda environment

```bash
conda env create -f platforms/jetstream2/env_exports/jetstream2-forecast.yml
```

This takes 5–15 minutes. When it finishes:

```bash
conda activate js2-gpu-forecast
python -c "import torch; print('CUDA:', torch.cuda.is_available())"
```

Expected output: `CUDA: True`

**If the environment file fails** (version conflicts on your specific image), use the fallback:

```bash
conda create -n js2-gpu-forecast python=3.10 -y
conda activate js2-gpu-forecast
conda install -y -c conda-forge pandas numpy scikit-learn jupyter nbconvert ipykernel tqdm joblib
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
python -m ipykernel install --user --name js2-forecast --display-name "js2-forecast"
```

---

## Step 4 — Run a smoke test

Confirm everything is wired up before committing to a full benchmark:

```bash
conda activate js2-gpu-forecast
export PLATFORM_LABEL="js2-smoketest"
export N_CITIES=10
export EPOCHS=2
export BATCH_SIZE=1024
bash platforms/jetstream2/scripts/run_jetstream2.sh
```

Should finish in under 3 minutes. Verify:
```bash
ls outputs/metrics/
# Expected: run_summary.json  epoch_timing.csv  history.csv  test_metrics.json
```

If files are missing: `tail -n 30 results/benchmarks/nbconvert_stderr_jetstream2.txt`

---

## Step 5 — Run the full benchmark

```bash
conda activate js2-gpu-forecast
export PLATFORM_LABEL="jetstream2-gpu"
bash platforms/jetstream2/scripts/run_jetstream2.sh
```

Full defaults: 210 cities, 50 epochs, batch size 8192, width 1024, depth 8.

**Runtime: 15–25 minutes on a g3.small (A100 GPU)**

To keep the job running if your browser closes, use `tmux`:
```bash
tmux new -s benchmark
conda activate js2-gpu-forecast
export PLATFORM_LABEL="jetstream2-gpu"
bash platforms/jetstream2/scripts/run_jetstream2.sh
# Detach: Ctrl+B then D
# Reattach later: tmux attach -t benchmark
```

---

## Step 6 — Review your results

```bash
# Benchmark row (your comparison artifact)
column -t -s, results/benchmarks/benchmark_row.csv

# Runtime summary
cat outputs/metrics/run_summary.json

# Test set accuracy
cat outputs/metrics/test_metrics.json

# Epoch-by-epoch timing
cat outputs/metrics/epoch_timing.csv
```

To download the executed notebook, use the Guacamole file transfer panel (`Ctrl+Alt+Shift` → Files → navigate to `outputs/reports/`) and download `forecasting.executed.ipynb` to your local machine.

---

## Adapting this to your own research

The patterns here transfer directly to your own notebooks.

**Swap in your notebook:**
Point the run script at your notebook instead of `forecasting.ipynb`. The core execution command is:
```bash
jupyter nbconvert --to notebook --execute your_notebook.ipynb \
  --output outputs/your_notebook.executed.ipynb
```

**Export your environment after testing:**
```bash
conda env export > platforms/jetstream2/env_exports/my-project.yml
```
Commit this file so collaborators and your future self can recreate the environment exactly.

**Scale your instance to your workload:**
If your dataset is larger or your model needs more GPU memory, resize your instance in Exosphere (Actions → Resize) to `g3.medium` or `g3.large`. You can do this without losing data as long as you shelve first.

**When you are done:**
Shelve your instance in Exosphere to stop SU consumption. Your data is preserved. Unshelve it when you want to continue.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Web shell opens blank | Guacamole loading issue | Refresh the tab; re-open from Exosphere if still blank |
| `conda: command not found` | Conda not initialized | Run `source ~/miniconda3/etc/profile.d/conda.sh` |
| `CUDA available: False` | CPU-only PyTorch | `pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121` |
| `conda env create` takes 30+ min or hangs | Slow solver | `conda install -n base conda-libmamba-solver` then add `--solver=libmamba` flag |
| Dataset not found mid-run | Wrong working directory | `cd ~/repos/NAIRR-AI-Unlocked` and rerun |
| Instance shows "Error" in Exosphere | VM build failed | Delete the instance and create a new one; this is rare but happens |
| SU balance low warning | Running low on allocation | Request a supplement at [allocations.access-ci.org](https://allocations.access-ci.org) or apply for a larger allocation |

---

## Getting help

- **JetStream2 documentation:** [docs.jetstream-cloud.org](https://docs.jetstream-cloud.org)
- **ACCESS support portal:** [support.access-ci.org](https://support.access-ci.org)
- **JetStream2 Slack:** Request access via a support ticket — there is an active `#jetstream` channel
- **This repository:** Open a GitHub issue for workflow-specific problems
