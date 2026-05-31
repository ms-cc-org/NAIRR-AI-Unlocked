# AI Unlocked: Running AI Workflows on Anvil

## Workshop Overview

In this exercise, you will run an AI workflow on Anvil, a national cyberinfrastructure resource available to researchers through ACCESS.

The goal of this activity is not to become an Anvil expert or learn every aspect of HPC administration.

The goal is to understand:

- What national cyberinfrastructure is
- How AI jobs are submitted to HPC systems
- How researchers use shared compute resources
- How this workflow could support your own research

**Estimated Time:** 30-40 minutes

---

# Learning Objectives

By the end of this exercise, you should be able to:

✅ Log into a national cyberinfrastructure resource

✅ Submit an AI job using a scheduler

✅ Monitor job execution

✅ Review benchmark results

✅ Explain how HPC resources differ from running workloads on a laptop

---

# What Has Already Been Prepared

To keep today's workshop focused on research workflows rather than system administration, the following resources have already been prepared:

- ACCESS accounts
- Workshop allocation
- Dataset
- Software environment
- Job scripts

In a real research project, you may need to perform these setup steps yourself. For today's workshop, we will focus on running and understanding the workflow.

---

# Step 1: Log Into Anvil

Open the Anvil Open OnDemand dashboard.

Log in using your ACCESS credentials.

From the top navigation menu select:

**Clusters → Shell Access**

You should see a terminal window.

If you do not see a terminal, raise your hand and a workshop helper will assist you.

---

# Step 2: Navigate to the Workshop Repository

Run:

```bash
cd ~/repos/NAIRR-AI-Unlocked
```

Verify your location:

```bash
pwd
```

Expected output:

```bash
~/repos/NAIRR-AI-Unlocked
```

---

# Step 3: Submit the Workshop Job

Submit the prepared AI workflow:

```bash
sbatch platforms/anvil/slurm/run_workshop.slurm
```

Expected output:

```bash
Submitted batch job 123456
```

Write down your Job ID.

---

# Step 4: Monitor the Job

Check job status:

```bash
squeue -u $USER
```

Common status codes:

| Status | Meaning |
|----------|----------|
| PD | Pending |
| R | Running |
| CG | Completing |

When the job disappears from the queue, execution has completed.

---

# Step 5: View Results

Display the benchmark summary:

```bash
cat results/benchmarks/benchmark_row.csv
```

Display model metrics:

```bash
cat outputs/metrics/test_metrics.json
```

---

# Understanding the Results

The benchmark output contains several common AI training parameters.

You do not need to memorize these values.

The goal is to understand how they affect compute requirements and performance.

| Parameter | Meaning | Why It Matters |
|------------|----------|----------------|
| Epochs | Number of times the model sees the full training dataset | More epochs generally improve learning but increase runtime |
| Batch Size | Number of training samples processed simultaneously | Larger batches typically require more memory |
| Number of Cities | Size of the dataset being analyzed | Larger datasets require more compute resources |
| Training Time | Time spent training the model | Useful for estimating computational cost |
| GPU Memory Usage | Amount of GPU memory consumed | Helps determine what hardware is required |
| Runtime | Total execution time | Useful for comparing computing platforms |

---

# Discussion Questions

Discuss with your neighbors:

### 1. What happened when you submitted the job?

Where did the computation actually occur?

### 2. Why didn't the job run directly on the login node?

What role does the scheduler play?

### 3. How is this different from running code on your laptop?

What advantages does Anvil provide?

### 4. What would happen if:

- The dataset doubled in size?
- The number of epochs increased?
- The model became more complex?

### 5. How might you use resources like Anvil in your own research?

---

# What Just Happened?

You submitted a job to the Slurm scheduler.

Rather than running directly on the login node, the scheduler allocated compute resources and executed the workflow on a dedicated compute node.

This approach allows many researchers to share large computing systems efficiently.

The same model is used by many national cyberinfrastructure resources, including:

- Anvil
- Bridges-2
- Delta
- Frontera
- Expanse

---

# Key Takeaways

National cyberinfrastructure enables researchers to access powerful computing resources without purchasing or maintaining their own GPU clusters.

The workflow demonstrated today can be adapted to support:

- AI and machine learning
- Climate science
- Genomics
- Engineering simulations
- Digital humanities
- Social science research
- Large-scale data analysis

The most important takeaway is not the specific commands you ran.

It is understanding that national cyberinfrastructure provides scalable computing resources that can accelerate research across many disciplines.

---

# Next Steps

Interested in using these resources for your own research?

Explore:

- ACCESS
- Anvil
- Jetstream2
- NAIRR Pilot
- Campus research computing programs

Talk with the workshop instructors about potential research use cases and follow-up training opportunities.
