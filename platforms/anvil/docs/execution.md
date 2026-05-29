# Anvil GPU Execution flow

## Prerequisites

- Setting up anvil account, and ready to use with SSH

Remember, that any HPC has 2 different nodes: 
- **Login node:** This is the front-end node where you log in. We edit files, compile code, manage data, and submit jobs to the scheduler on this node. It is not meant for running heavy computations.

- **Compute node:** This is the back-end node where the actual computations run. When you submit a job, it is sent to a compute node, which has the CPU, GPU, and memory resources needed to perform the task given.

---

## Login to Anvil

From your system:

`ssh <your-username>@anvil.rcac.purdue.edu`

For your allocation name and type, enter `mybalance`.

---
## Setting up your HPC

```
mkdir -p ~/MSCCAM
cd ~/MSCCAM
git clone https://github.com/ms-cc-org/NAIRR-AI-Unlocked.git
cd NAIRR-AI-Unlocked
```

---
## Prepare the Dataset Folder
The notebook expects the dataset folder to exist in the repository root as: `data/temparature-us/`

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
`rsync -avP path / to /7890488/ <your-username>@anvil.rcac.purdue.edu:~/MSCCAM/NAIRR-AI-Unlocked/data/temperature-us/`

**Verify on VM/HPC:** `ls -1 data/temperature-us/*.csv | wc -l  #Should output 211`

---

## Module setup

As HPCs use module command.

To see available libraries: `module avail`

`module load anaconda`
or
`module load anaconda/2025.06-py313`

Enable conda activation: `source $(conda info --base)/etc/profile.d/conda.sh`

Restart the session: `source ~/.bashrc`

Confirm conda works: `conda --version`

---
## Conda environment

Create the environment from the Anvil environment file:
`conda env create -f platforms/anvil/env_exports/anvil-forecast.yml`

Activate it: `conda activate anvil-forecast`

If You See a conda error `CondaError: Run 'conda init' before 'conda activate'`

Follow this sequence:
- `conda init bash`
- `source ~/.bashrc`
- `conda activate anvil-forecast`

Environment installation can also be done manually:

```bash
conda create -n anvil-forecast python=3.10 -y
conda activate anvil-forecast

conda install -y -c conda-forge pandas numpy scikit-learn jupyter nbconvert ipykernel tqdm joblib

pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

```

**Test PyTorch import:**

```bash
python - << 'PY'
import torch
print("torch version:", torch.__version__)
print("Cuda available:", torch.cuda.is_available())
print("cuda version: ", torch.version.cuda)
PY
```

**Kernel:** `python -m ipykernel install --user --name anvil-forecast --display-name "anvil-forecast"`

**Create output folders:** 

From the repo root: `cd ~/MSCCAM/NAIRR-AI-Unlocked`

`mkdir -p results/benchmarks results/system outputs/reports outputs/metrics outputs/models`

---

## Edit Slurm script

There is already an existing slurm script.

Make sure you are on the repo: `cd ~/MSCCAM/NAIRR-workflows`

To see the slurm script from your terminal: `cat platforms/anvil/slurm/run_anvil_gpu.slurm`

Make sure to edit the allocation name and partition type. To get these two use `mybalance` command.

To open the slurm script from your terminal: `nano platforms/anvil/slurm/run_anvil_gpu.slurm`. Then change:
- The allocation name
- The partition type

Once you edit, `Ctrl + O` to save, press `Enter` and then `Ctrl + X` to exit.

## Job scheduling

Enter command to submit a job:

`sbatch platforms/anvil/slurm/run_anvil_gpu.slurm`

You'll get something like `Submitted batch job <job_id>`

## Monitor the Job

Check queue status: `squeue -u $USER`

**Check Slurm output:**
```bash
tail -n 80 results/benchmarks/slurm_<job_id>.out
tail -n 80 results/benchmarks/slurm_<job_id>.err
```
**Check notebook execution logs:**
```bash
tail -n 80 results/benchmarks/nbconvert_stderr_anvil.txt
tail -n 80 results/benchmarks/nbconvert_stdout_anvil.txt
```
**A successful run shows:**
```bash
[NbConvertApp] Writing ... to outputs/reports/forecasting.anvil.executed.ipynb
Exit status: 0
```
That is the key success signal.

## Git Commit
```bash
conda env export --from-history > platforms/anvil/env_exports/anvil-forecast.yml
git add outputs/reports/forecasting.anvil.executed.ipynb
git add results/benchmarks/*anvil*
git add results/system/anvil_env_snapshot.txt

git commit -m "Anvil GPU execution: notebook + benchmarks + system snapshot"
```
