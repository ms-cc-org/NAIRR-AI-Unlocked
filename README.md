# NAIRR AI Unlocked

Run a GPU-accelerated machine learning workflow on national AI research infrastructure. Train a real model, collect performance benchmarks, and walk away with a workflow pattern you can adapt to your own research.

---

## Find your guide

| I am... | My guide is... |
|---|---|
| **In a facilitated workshop right now** (JetStream2 instance already provisioned) | [`WORKSHOP_JETSTREAM2.md`](WORKSHOP_JETSTREAM2.md) |
| **Working on my own** and want to set up JetStream2 from scratch | [`SELF_SERVICE_JETSTREAM2.md`](SELF_SERVICE_JETSTREAM2.md) |
| **On Anvil** (HPC / Slurm) | [`WORKSHOP_ANVIL.md`](WORKSHOP_ANVIL.md) |

Each guide is self-contained. Pick the one that matches your situation and follow it — you do not need to read the others.

---

## What this is

`forecasting.ipynb` trains a multilayer perceptron on historical daily temperature data for 210 US cities. The model is intentionally large for a laptop. The point is to run it on national GPU infrastructure, measure the execution time, and understand the workflow well enough to apply the same pattern to your own data and models.

---

## Repository structure

```
NAIRR-AI-Unlocked/
├── WORKSHOP_JETSTREAM2.md       ← Workshop guide (pre-provisioned instance)
├── WORKSHOP_ANVIL.md            ← Workshop guide (Anvil / Slurm)
├── SELF_SERVICE_JETSTREAM2.md   ← Full setup guide, start from scratch
├── forecasting.ipynb            ← The ML pipeline
├── platforms/
│   ├── jetstream2/
│   │   ├── env_exports/         ← Conda environment file
│   │   └── scripts/             ← Launch script
│   └── anvil/
│       ├── env_exports/         ← Conda environment file
│       └── slurm/               ← Slurm job script
├── scripts/preflight.sh         ← Pre-run diagnostic check
├── outputs/                     ← Created at runtime
└── results/benchmarks/          ← Created at runtime
```

The dataset (`7890488/`) is not in Git. Your guide covers how to get it.

---

## Getting help

- **During a workshop:** `#ai-unlocked` on the NAIRR Slack instance
- **JetStream2 docs:** [docs.jetstream-cloud.org](https://docs.jetstream-cloud.org)
- **Anvil docs:** [rcac.purdue.edu/anvil](https://www.rcac.purdue.edu/anvil)
- **ACCESS support:** [support.access-ci.org](https://support.access-ci.org)
:wq
