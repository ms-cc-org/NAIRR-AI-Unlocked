# AI Unlocked: Running AI Workflows on Jetstream2

## Workshop Overview

In this exercise, you will run an AI workflow on Jetstream2, a cloud-based research computing platform available through ACCESS.

Unlike Anvil, which uses a shared HPC scheduler, Jetstream2 provides researchers with on-demand virtual machines that can be customized for specific research needs.

By the end of this exercise, you will:

- Connect to a Jetstream2 virtual machine
- Run an AI workflow on a GPU-enabled instance
- Review benchmark results
- Compare cloud and HPC computing approaches

**Estimated Time:** 30–40 minutes

---

# What Has Already Been Prepared

To keep today's workshop focused on research workflows rather than system administration, the following resources have already been prepared:

- Virtual machine instance
- Repository
- Dataset
- Software environment

Your goal today is to run and understand the workflow.

---

# Step 1: Connect to Your Instance

Your facilitator will provide:

- Instance name
- Access information

Log into:

https://jetstream2.exosphere.app

Find your assigned instance.

Select:

**Connect To → Web Shell**

A browser-based terminal window will open.

You should see a prompt similar to:

```bash
exouser@instance-name:~$
```

---

# Step 2: Navigate to the Workshop Repository

```bash
cd ~/repos/NAIRR-AI-Unlocked
ls
```

---

# Step 3: Activate the Environment

```bash
conda activate js2-gpu-forecast
python -c "import torch; print('CUDA available:', torch.cuda.is_available())"
```

Expected output:

```bash
CUDA available: True
```

---

# Step 4: Run the Workshop Benchmark

```bash
export PLATFORM_LABEL="jetstream2-gpu"
bash platforms/jetstream2/scripts/run_jetstream2.sh
```

Typical runtime is approximately 15–25 minutes.

---

# While the Job Runs

Discuss with your group:

- What makes Jetstream2 different from Anvil?
- What research projects might benefit from a cloud environment?
- What are the tradeoffs between cloud and HPC?

---

# Step 5: Review Results

```bash
column -t -s, results/benchmarks/benchmark_row.csv
cat outputs/metrics/run_summary.json
cat outputs/metrics/test_metrics.json
```

---

# Understanding the Benchmark

| Parameter | Meaning | Why It Matters |
|------------|----------|----------------|
| Epochs | Number of training passes through the data | More epochs increase runtime |
| Batch Size | Number of records processed simultaneously | Larger batches require more memory |
| Number of Cities | Dataset size | Larger datasets require more compute |
| Runtime | Total execution time | Useful for comparing systems |
| GPU Memory Usage | GPU memory consumed | Helps determine hardware requirements |
| Training Time | Time spent training the model | Useful for estimating computational cost |

---

# Comparing Anvil and Jetstream2

| Anvil | Jetstream2 |
|---------|-----------|
| Shared HPC resource | Cloud virtual machine |
| Jobs submitted through Slurm | Interactive VM access |
| Optimized for batch workloads | Optimized for flexibility |
| Shared compute environment | Customizable environment |
| HPC scheduling model | Cloud computing model |

---

# Key Takeaways

Jetstream2 provides researchers with flexible, cloud-based computing resources that can support AI, data science, and computational research workflows.

The most important takeaway is understanding when a cloud platform like Jetstream2 may be a better fit than a traditional HPC environment.
