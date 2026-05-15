# Anvil Error Handling

### Error: PyTorch Import Failure – Undefined symbol iJIT_NotifyEvent

`ImportError: …libtorch_cpu.so: undefined symbol: iJIT_NotifyEvent`

**Solution:** Removing existing PyTorch packages:

`conda remove --force pytorch torchvision torchaudio pytorch-cuda -y`

Then installed PyTorch with CUDA:

`pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118`

### Error: CONDA_BACKUP_QT_XCB_GL_INTEGRATION unbound variable in SLURM job

`…/conda/deactivate.d/qt-main_deactivate.sh: line 5: CONDA_BACKUP_QT_XCB_GL_INTEGRATION: unbound variable`

**Solution:** Before activating Conda, source the conda initialization.

`source "$(conda info --base)/etc/profile.d/conda.sh"`

And remove the -u flag to make it `set -eo pipefail`

