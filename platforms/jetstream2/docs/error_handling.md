## Problem 1: conda activate does not work

**Error:** CondaError: Run 'conda init' before 'conda activate'

**Fix:**
```bash
conda init bash
source ~/.bashrc
conda activate js2-gpu-forecast
```

## Problem 2: No such file or directory
**Cause:** The folder does not exist yet.
**Fix:**
`mkdir -p results/benchmarks`
Better fix:
`mkdir -p outputs/reports outputs/metrics outputs/models results/benchmarks results/system`

## Problem 3: Run is too slow

Start with a smaller test:
- export N_CITIES=20
- export EPOCHS=2
- export BATCH_SIZE=64
- export WIDTH=128
- export DEPTH=1
- export NUM_WORKERS=0

Then scale **gradually**:
- N_CITIES: 20 --> 50 --> 100 --> 210
- EPOCHS: 2 --> 5 --> 10 --> 25
- WIDTH: 128 --> 512 --> 1024
- DEPTH: 1 --> 4 --> 8
- BATCH_SIZE: 64 --> 1024 --> 4096