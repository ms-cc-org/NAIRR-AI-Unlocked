# Workshop Guide — JetStream2

**Time:** ~90 minutes  
**Format:** Groups of 2–3, one pre-provisioned instance per group  
**What's already done for you:** The instance is running, the repo is cloned, the dataset is staged, and the Conda environment is built.

Your job today: open a browser, connect to your instance, run a GPU-accelerated ML training job, and understand what you just did well enough to apply it to your own research.

---

## How to connect to your instance

Your facilitator has given you a card (or Slack message) with:
- A URL: `https://jetstream2.exosphere.app`
- An instance name assigned to your group
- The `exouser` passphrase for that instance

**Steps:**

1. Open `https://jetstream2.exosphere.app` in your browser and log in with your ACCESS credentials
2. You will see the Instances list — find the instance name assigned to your group
3. Click **"Connect to"** → **"Web Shell"**
4. A new browser tab opens with a terminal prompt — you are in

You should see a prompt that looks like:
```
exouser@your-instance-name:~$
```

> **Pasting commands into the web shell:** The web shell runs in your browser, so your normal paste shortcut may not work. Use `Ctrl+Alt+Shift` (Windows/Linux) or `Ctrl+Cmd+Shift` (Mac) to open the Guacamole clipboard panel, paste your text there, close the panel, then paste into the terminal with `Shift+Insert` or right-click → Paste.

---

## Get your bearings

Navigate to the repo and confirm everything is in place:

```bash
cd ~/repos/NAIRR-AI-Unlocked
ls
```

You should see:
```
forecasting.ipynb  platforms/  scripts/  outputs/  results/  README.md
```

Confirm the dataset is staged:
```bash
ls 7890488/ | wc -l
```
Should return `211` (210 city files + `city_info.csv`).

Confirm the environment is ready:
```bash
conda activate js2-gpu-forecast
python -c "import torch; print('CUDA available:', torch.cuda.is_available())"
```
Should print `CUDA available: True`.

If anything above is missing or wrong, flag your facilitator before continuing.

---

## What this workflow does — 5 minutes before you run it

`forecasting.ipynb` trains a multilayer perceptron to predict daily temperatures for up to 210 US cities. The model is intentionally large for a laptop — that is the point. You are about to run it on a GPU and measure the difference.

The pipeline: load CSV data → engineer lag/rolling features → train MLP → evaluate → write metrics and benchmark output.

**Model accuracy is not the goal.** The goal is a measurable, reproducible execution time you can compare across systems. The benchmark row this run produces is your evidence.

One thing worth noting before you run: the notebook executes *non-interactively* via `nbconvert` — a command-line tool that runs a Jupyter notebook from top to bottom and saves the outputs. This is how you run notebooks on HPC systems where there is no browser. The script handles it for you, but you should know what is happening.

---

## Step 1 — Smoke test

Before the full run, do a 2-minute smoke test to confirm the environment, dataset, and script are all connected.

```bash
export PLATFORM_LABEL="js2-smoketest"
export N_CITIES=10
export EPOCHS=2
export BATCH_SIZE=1024
bash platforms/jetstream2/scripts/run_jetstream2.sh
```

You will see `nbconvert` output scroll by as the notebook executes. When it finishes, check that outputs were written:

```bash
ls outputs/metrics/
```

Expected: `run_summary.json  epoch_timing.csv  history.csv  test_metrics.json`

**If those files are missing**, read the last 30 lines of the error log before calling your facilitator:
```bash
tail -n 30 results/benchmarks/nbconvert_stderr_jetstream2.txt
```

Do not move on until the smoke test produces output files.

---

## Step 2 — Full benchmark run

Smoke test passed. Now run the full workload.

```bash
export PLATFORM_LABEL="jetstream2-gpu"
bash platforms/jetstream2/scripts/run_jetstream2.sh
```

The script uses these defaults automatically: 210 cities, 50 epochs, batch size 8192, hidden width 1024, depth 8.

**Typical runtime: 15–25 minutes** depending on GPU type.

The notebook runs in the foreground — you will see live epoch progress. While it runs, work through the discussion questions with your group (next section). Do not close the browser tab.

> **If the tab goes to sleep or disconnects:** The job will likely keep running on the instance. Reopen the web shell from Exosphere and check progress with `ls -lt outputs/metrics/`.

---

## While you wait — discuss with your group

These are not rhetorical. Write down actual answers — you will share them.

**1. What is the compute bottleneck in your current research?**  
Is it data preprocessing, model training, inference, or something else? How long does it currently take?

**2. What would the scaling story look like for your work?**  
If you ran your workflow on a GPU like this one, which step would speed up most? Which would not improve at all?

**3. What would you need to change to run your notebook on JetStream2?**  
Think about: dataset size and where it lives, environment dependencies, how long the run would take, whether you need interactive access or could batch it.

---

## Step 3 — Read your results

When the run finishes, look at what was produced.

### Your benchmark row
```bash
column -t -s, results/benchmarks/benchmark_row.csv
```

This captures: platform, GPU type, total training time, time per epoch, and key config parameters. This is the row you would compare against a CPU baseline or an Anvil run.

### Training summary
```bash
cat outputs/metrics/run_summary.json
cat outputs/metrics/test_metrics.json
```

### Epoch timing — the most informative output
```bash
cat outputs/metrics/epoch_timing.csv
```

Look at time per epoch. Is it consistent across all 50 epochs? An early spike followed by stable times is normal (data loading + GPU warmup on epoch 1). Large variance across epochs can indicate memory pressure or contention.

### The executed notebook
The full notebook with all cell outputs is at `outputs/reports/forecasting.executed.ipynb`. You can download it using the Guacamole file transfer panel (`Ctrl+Alt+Shift` → Files) and open it locally in JupyterLab or VS Code.

---

## Step 4 — Group debrief

Share your discussion answers with the room. Specifically:

- What were your epoch times? Compare across groups — different GPU flavors produce different numbers.
- What was the biggest surprise in the outputs?
- What is the one thing you would need to figure out to run *your* workflow on JetStream2?

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Web shell tab opens but shows nothing | Refresh the tab; if still blank, go back to Exosphere and reopen the web shell |
| Paste does not work | Use `Ctrl+Alt+Shift` (Win) or `Ctrl+Cmd+Shift` (Mac) to open the Guacamole clipboard panel |
| `conda: command not found` | Run `source ~/miniconda3/etc/profile.d/conda.sh` then retry |
| `CUDA available: False` | Run `nvidia-smi` — if a GPU is listed but CUDA is False, flag your facilitator |
| Smoke test output files missing | Run `tail -n 30 results/benchmarks/nbconvert_stderr_jetstream2.txt` and share the error with your facilitator |
| Full run seems to hang | Check `nvidia-smi` in a second web shell tab — if GPU utilization is above 0%, it is running |
