# Workshop Guide: Running the AI Forecasting Workflow on Anvil

This is your complete guide. Everything you need is on this page — you do not need to open any other file.

**What you will do:** SSH into Anvil, set up the workflow environment, submit a GPU training job to the Slurm scheduler, and inspect your results. By the end you will have a benchmark you can compare against other systems and a workflow pattern you can reuse.

**How long this takes:** About 60–90 minutes for a first run, including environment setup. The training job itself takes 15–25 minutes once it starts running (queue wait time varies).

---

## Before you start — confirm your prerequisites

Work through this checklist before the session. Most workshop delays come from unresolved prerequisites.

- [ ] You have an ACCESS account at [access-ci.org](https://access-ci.org)
- [ ] You have an active Anvil allocation — check at [allocations.access-ci.org](https://allocations.access-ci.org)
- [ ] You know your **ACCESS project code** (it looks like `abc123456` — find it in your allocation details)
- [ ] You can SSH into Anvil: `ssh <username>@anvil.rcac.purdue.edu`
- [ ] Conda is available on Anvil: run `module load anaconda` then `conda --version`

**If SSH fails:** Verify your ACCESS username. Anvil uses your ACCESS credentials, not a local Purdue account. Contact [support.access-ci.org](https://support.access-ci.org) if login fails after verifying.

**If your allocation is not listed:** Allocations can take up to 24 hours to activate after approval. If your allocation was recently approved and is not showing up, contact your facilitator.

---

## What Anvil is (and why it works the way it does)

Anvil is a traditional HPC cluster. You log into a **login node** — a shared entry point — and submit work to a **Slurm scheduler**. Slurm queues your job and launches it on a **compute node** (the machine with the actual GPUs) when resources are available.

This model is different from cloud VMs or your laptop. You cannot run long computations on the login node — it is shared and has no GPUs. Instead, you write a **job script** describing what you need, submit it, and wait.

This takes some getting used to if you are new to HPC, but it is the standard model for national supercomputers — Frontera, Delta, Bridges-2, and most campus clusters all work the same way. Learning Slurm on Anvil transfers directly.

**The key mental model:** You are not running code. You are writing instructions, handing them to Slurm, and Slurm runs them on your behalf when a GPU node is free.

---

## Step 1 — Connect and set up your workspace

### Option 1: SSH into Anvil from your local terminal

```bash
ssh <x-your-access-username>@anvil.rcac.purdue.edu
```

### Option 2: Use Anvil Shell Access from the Anvil On Demand dashboard

You can also connect to Anvil through Anvil OnDemand dashboard without a local terminal

- Go to Anvil OnDemand dashboard
- Signin using your Access ID and password
- After logging in, Select Clusters from the top menu
- From the dropdown meny, choose **Anvil Shell Access**
- A browser shell session will open and connect you to the Anvil system.

You will land on a login node (`anvil-login-xx`). This is where you set up your environment and submit jobs. Do not run training jobs here.

### Load the Conda module

Conda is available on Anvil as a module, not installed by default in your PATH:

```bash
module avail conda
module load conda/2026.03
conda --version
```

You should see a version number. Add this module load to your `~/.bashrc` so it is available automatically in future sessions:

```bash
echo "module load anaconda" >> ~/.bashrc
```

### Clone the repository

```bash
mkdir -p ~/repos
cd ~/repos
git clone https://github.com/ms-cc-org/NAIRR-AI-Unlocked.git
cd NAIRR-AI-Unlocked
```

Confirm the clone succeeded:
`ls`

You should see: `forecasting.ipynb  platforms/  scripts/  outputs/  results/  README.md  WORKSHOP_JETSTREAM2.md  WORKSHOP_ANVIL.md`

> **Why this directory structure matters:** Everything in this tutorial runs relative to the repo root (`~/repos/NAIRR-AI-Unlocked`). The Slurm script, the dataset path, and the output directories all assume you are in this directory when you submit. If commands fail with "file not found" errors, the first thing to check is your current directory: run `pwd` and confirm you see `.../NAIRR-AI-Unlocked`.

---

## Step 2 — Stage the dataset

The notebook trains on historical daily temperature data for 210 US cities. The dataset is not stored in Git (too large), so you need to place it at the path the notebook expects before submitting.

**The notebook looks for the dataset here:**
`data/temperature-us/`

**Expected contents:**
```bash
data/temperature-us/city_info.csv
data/temperature-us/ABQ.csv
data/temperature-us/ANC.csv
... (one CSV per city)
```

Create the data directories:
```bash
mkdir -p data
mkdir -p data/temperature-us
```

### Option A — Transfer from your local machine (recommended for Anvil)

Anvil compute nodes have restricted outbound internet access, so direct download from the internet is not reliable. Transfer the dataset from your local machine:

```bash
# Run this command on your LOCAL machine (not on Anvil)
rsync -avzP /path/to/your/7890488/ \
  <your-username>@anvil.rcac.purdue.edu:~/repos/NAIRR-AI-Unlocked/data/temperature-us/
```

### Option B — Copy from a facilitator-provided path

Your facilitator may have pre-staged the dataset in a shared directory on Anvil. They will give you the path:

```bash
# Run this on Anvil
cp -r /anvil/projects/x-cis260907/dataset_shared/* ~/repos/NAIRR-AI-Unlocked/data/temperature-us/
```

### Verify the dataset is in place

```bash
ls data/temperature-us/ | head -10
wc -l data/temperature-us/city_info.csv
```

You should see a list of CSV files and `city_info.csv` should have 211 lines (1 header + 210 cities). If the directory is empty or missing, do not proceed — the job will fail immediately when it runs.

---

## Step 3 — Build the Conda environment

The workflow requires specific Python and ML library versions. We use a pre-tested environment definition so you get exactly what was tested on Anvil hardware.

> **Important:** Build the environment on the login node, not in a job. This is one of the few things you do directly on the login node — environment creation does not need a GPU and is not a heavy compute task.

### Create the environment from the provided file

> **Important:** Enter `module avail cuda`, if the terminal returns **No module(s) or extension(s) found!**, then you're probably on CPU module. 

To swap to GPU module, use: `module swap modtree/cpu modtree/gpu`

Then once again try `module avail cuda`, if you get core applications with cuda, the you are on GPU module. 

### Environment creation:

```bash
conda env create -f platforms/anvil/env_exports/anvil-forecast.yml
```

This installs PyTorch, scikit-learn, pandas, nbconvert, and their dependencies. **It takes 5–15 minutes.** This is normal — do not cancel it.

When it finishes, you will see:
```bash
done
# To activate this environment, use:
#     conda activate anvil-forecast
```

## Activate the environment

```bash
conda activate anvil-forecast
```

**Check PyTorch and Cuda versions:**
```bash
python - <<'PY'
> import torch
> print("torch:", torch.__version__)
> print("cuda available:", torch.cuda.is_available())
> print("cuda version:", torch.version.cuda)
> PY
```

When it finishes, you will see:
```bash
torch: 2.5.1+cu124
cuda available: False
cuda version: 12.4
```

Here, CUDA is available, but it is showing as `False` because you are on the login node.

### What to do if the environment file fails

If `conda env create` exits with errors, use this fallback — it installs a minimal but fully working set:

```bash
conda create -n anvil-forecast python=3.10 -y
conda activate anvil-forecast
conda install -y -c conda-forge pandas numpy scikit-learn jupyter nbconvert ipykernel tqdm joblib
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
```

---

## Step 4 — Edit the Slurm job script

Before you can submit the job, you need to add your ACCESS project code to the Slurm script. This is how Anvil knows which allocation to charge.

### Open the script

```bash
nano platforms/anvil/slurm/run_anvil_gpu.slurm
```

### Find and update these lines

```bash
#SBATCH -A YOUR_ALLOCATION     ← Replace with your ACCESS project code (e.g., abc123456)
#SBATCH -p gpu                 ← Verify this matches a partition your allocation can access
#SBATCH --gres=gpu:1           ← Requesting 1 GPU
#SBATCH --mem=64G              ← Memory per node
#SBATCH -t 01:00:00            ← Time limit: 1 hour (enough for the full benchmark)
```

Replace `YOUR_ALLOCATION` with your actual ACCESS project code. Leave the other lines as-is unless your facilitator tells you otherwise.

Save and exit nano: `Ctrl+O` then `Enter` to save, `Ctrl+X` to exit.

### What is a Slurm job script?

A Slurm script is a shell script with special `#SBATCH` comment lines at the top. Those lines are directives to the scheduler — they tell Slurm what resources to allocate and what account to charge. The commands below the `#SBATCH` lines are what actually run when your job starts.

When you submit with `sbatch`, Slurm reads those directives, places your job in the queue, and executes the script on a compute node when resources are available.

---

## Step 5 — Smoke test: confirm everything is wired together

Before submitting a full benchmark run, do a quick smoke test with a small workload. This confirms the Slurm script, environment, and dataset are all connected correctly. Because this is a batch system, the smoke test is also submitted as a job — but it finishes in a few minutes.

### Edit the script for a smoke test run

Open the Slurm script again:
```bash
nano platforms/anvil/slurm/run_anvil_gpu.slurm
```

Find the section where environment variables are set and change these values:
```bash
export PLATFORM_LABEL="anvil-smoketest"
export N_CITIES=10
export EPOCHS=2
export BATCH_SIZE=1024
```

Save and exit.

### Submit the smoke test

```bash
sbatch platforms/anvil/slurm/run_anvil_gpu.slurm
```

Slurm will respond with your job ID:
```
Submitted batch job 12345678
```

### Monitor the job

Check whether your job is queued, running, or finished:
```bash
squeue -u $USER
```

Output while queued:
```
JOBID    PARTITION  NAME     USER      ST  TIME  NODES NODELIST
12345678 gpu        run_anvi yourname  PD  0:00  1     (Priority)
```

`ST` shows status: `PD` = pending (queued), `R` = running, `CG` = completing.

Once running, watch the log in real time:
```bash
tail -f results/benchmarks/slurm_12345678.err
```

Replace `12345678` with your actual job ID.

### Confirm the smoke test succeeded

After the job finishes (it disappears from `squeue`), check the outputs:
```bash
ls outputs/metrics/
```

You should see: `run_summary.json  epoch_timing.csv  history.csv  test_metrics.json`

If these files are missing, read the error log:
```bash
tail -n 50 results/benchmarks/slurm_12345678.err
tail -n 50 results/benchmarks/nbconvert_stderr_anvil.txt
```

**Common smoke test failures and fixes:**

| Error message | Cause | Fix |
|---|---|---|
| `Invalid account` or `Authorization failure` | Wrong allocation code | Re-edit `#SBATCH -A` line in the script |
| `Invalid partition` | Partition not available on your allocation | Ask facilitator for the correct partition name |
| `FileNotFoundError: data/temperature-us/city_info.csv` | Dataset not staged | Redo Step 2 |
| `ModuleNotFoundError: No module named torch` | Environment not found | Verify `conda activate anvil-forecast` works and the env was built in Step 3 |
| Job stays in PD for 20+ minutes | Queue backlog | This is normal during peak times; continue waiting or ask facilitator about priority queues |

Do not proceed to Step 6 until the smoke test produces output files.

---

## Step 6 — Run the full benchmark

With a passing smoke test, you are ready for the full run.

### Reset the script to full benchmark settings

Open the Slurm script and restore the full benchmark parameters:
```bash
nano platforms/anvil/slurm/run_anvil_gpu.slurm
```

Update the environment variable section:
```bash
export PLATFORM_LABEL="anvil-gpu"
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

Save and exit.

### Submit the full benchmark job

```bash
sbatch platforms/anvil/slurm/run_anvil_gpu.slurm
```

Note the new job ID. Monitor it:
```bash
squeue -u $USER
```

Once running, watch live progress:
```bash
tail -f results/benchmarks/slurm_<jobid>.err
```

**Typical runtime once running:** 15–25 minutes on an Anvil A100 GPU.

**Queue wait time** varies by system load. During workshop hours with many participants submitting simultaneously, you may wait longer. This is normal — use the wait time to review your smoke test outputs or read ahead to Step 7.

---

## Step 7 — Inspect your results

After the job finishes (it disappears from `squeue`), check your outputs.

### Check the benchmark row

```bash
cat results/benchmarks/benchmark_row.csv
```

This is a one-row CSV capturing: platform label, GPU type, total training time, time per epoch, and the key configuration parameters. Every run appends a new row — if you run multiple experiments, they accumulate here automatically.

For a formatted view:
```bash
column -t -s, results/benchmarks/benchmark_row.csv
```

### Check the training metrics

```bash
cat outputs/metrics/run_summary.json
cat outputs/metrics/test_metrics.json
```

`run_summary.json` shows total runtime and configuration. `test_metrics.json` shows MAE and RMSE on the held-out test set.

### Review the executed notebook

The fully executed notebook — with all cell outputs — is at:
```
outputs/reports/forecasting.executed.ipynb
```

To view it, download it to your laptop:
```bash
# Run this on your LOCAL machine
scp <username>@anvil.rcac.purdue.edu:~/repos/NAIRR-AI-Unlocked/outputs/reports/forecasting.executed.ipynb .
```

Then open it in JupyterLab or VS Code.

### Full output map

```
outputs/
├── reports/forecasting.executed.ipynb   ← Notebook with all outputs
├── metrics/
│   ├── run_summary.json                 ← Platform, config, total runtime
│   ├── epoch_timing.csv                 ← Seconds per epoch
│   ├── history.csv                      ← Loss per epoch
│   └── test_metrics.json                ← MAE, RMSE
└── models/
    ├── mlp_state.pt                     ← Saved model weights
    └── feature_scaler.pkl               ← Fitted sklearn scaler

results/benchmarks/
├── run_metadata.json                    ← GPU model, CPU count, RAM
├── benchmark_row.csv                    ← Accumulated benchmark rows
└── slurm_<jobid>.err                    ← Scheduler log for this run
```

---

## Step 8 — Connect this to your own research

Now that the workflow ran successfully, think about how you would adapt it for your own work.

**Running your own notebook on Anvil:**  
Any notebook that runs on your laptop can be executed on Anvil using the same Slurm pattern. The core command the job script runs is:
```bash
jupyter nbconvert --to notebook --execute your_notebook.ipynb \
  --output outputs/your_notebook.executed.ipynb
```
Update the Slurm script to point to your notebook, adjust the resource requests for your workload (more GPU memory, more time, etc.), and submit.

**Adapting the Slurm directives for your workload:**

```bash
#SBATCH --gres=gpu:2        ← Request 2 GPUs for multi-GPU training
#SBATCH --mem=128G          ← More memory for large datasets
#SBATCH -t 04:00:00         ← More time for longer runs
#SBATCH -N 2                ← Multiple nodes for distributed training
```

**Capturing your own environment:**  
After your code runs, export the environment:
```bash
conda env export > platforms/anvil/env_exports/my-project-env.yml
```
Commit this file. Anyone with an Anvil allocation can recreate your environment exactly.

**Transferring this to other HPC systems:**  
The Slurm job script pattern is nearly identical on Frontera, Delta, Bridges-2, Expanse, and most campus HPC clusters. The main differences are partition names and GPU types — the `#SBATCH` directives and the overall structure are the same.

> **Discussion prompt:** What computational task in your current research takes the longest on your laptop or campus system? What would the Slurm job script need to look like — how many GPUs, how much memory, how much time?

---

## Troubleshooting reference

| Symptom | Most likely cause | Fix |
|---|---|---|
| `Permission denied (publickey)` on SSH | ACCESS account issue or wrong username | Verify username at [access-ci.org](https://access-ci.org); contact [support.access-ci.org](https://support.access-ci.org) |
| `conda: command not found` | Module not loaded | Run `module load anaconda` |
| `Invalid account or account/partition combination specified` | Wrong allocation code or partition | Double-check `#SBATCH -A` in the script; ask facilitator for valid partition names |
| Job stays `PD` indefinitely | Queue backlog or resource mismatch | Run `scontrol show job <jobid>` and read the `Reason` field |
| `FileNotFoundError: data/temperature-us/city_info.csv` | Dataset not staged | Redo Step 2 |
| Job fails immediately (exit code 1) | Environment or script error | Read `tail -n 80 results/benchmarks/slurm_<jobid>.err` |
| `outputs/metrics/` empty after job finishes | nbconvert error | Read `tail -n 80 results/benchmarks/nbconvert_stderr_anvil.txt` |
| GPU shows 0% utilization in job log | CPU fallback in PyTorch | Verify `torch.cuda.is_available()` in the activated environment; reinstall PyTorch if needed |

---

## Facilitator notes

**Before the session:**
- [ ] Confirm all participants have ACCESS accounts and active Anvil allocations
- [ ] Collect all participant ACCESS project codes in advance — these are needed in the Slurm script
- [ ] Pre-stage the dataset in a shared directory on Anvil's `/anvil/scratch/` or `/anvil/projects/` storage
- [ ] Run a smoke test job on a representative allocation to catch partition or quota issues
- [ ] Determine the correct partition name(s) for participant allocations — this varies by allocation type
- [ ] Share the `#ai-unlocked` Slack channel link before participants arrive

**During the session:**
- [ ] Have participants verify `module load anaconda && conda --version` before starting — catches PATH issues early
- [ ] Walk through the Slurm script edit (Step 4) as a group before anyone submits — the allocation code is the most common failure point
- [ ] Submit smoke tests as a group, then monitor with `squeue -u $USER` together — seeing the queue work in real time is one of the most instructive moments for HPC newcomers
- [ ] Use `scontrol show job <jobid>` to explain why jobs are queued when participants ask about wait times
