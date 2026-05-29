# Using Results to Plan Compute Allocations

**Purpose:** This guide explains how to interpret the outputs from a forecasting workflow run and use those numbers to justify and request appropriate computational resources for your own research problem.

---

## Why These Metrics Matter

When you write an allocation request, reviewers ask: *"How much compute do you actually need, and why?"*

This workflow produces concrete evidence:
- **How long** similar computations take on different hardware
- **How much** data your approach can process per unit time
- **Whether** your approach is working (validation trends, test accuracy)
- **How to scale** from this baseline to your actual problem size

---

## The Four Output Categories

### 1. Training Progress & Throughput (`outputs/metrics/history.csv`)

**What it contains:**
```
epoch,train_loss,val_loss,epoch_sec,throughput_samples_per_sec
1,0.8432,0.7654,45.2,28156
2,0.7821,0.7123,44.8,28401
3,0.7234,0.6892,45.1,28233
...
```

**What it tells you:**

| Metric | Meaning | Use for Allocation |
|---|---|---|
| `train_loss` | How well the model fits training data | Watch trend: should decrease steadily. If plateaus early, you need more epochs OR your approach needs adjustment |
| `val_loss` | How well the model generalizes | **Most important**: if val_loss keeps decreasing, longer training will help. If it increases (overfitting), you need regularization or a different approach—more compute won't help |
| `epoch_sec` | Seconds per epoch on THIS hardware | **Critical for scaling**: if your real problem has 2x the data, expect ~2x the time per epoch |
| `throughput_samples_per_sec` | How fast your hardware processes data | Benchmark: if you get 28k samples/sec on GPU, and your problem has 10M samples, budget 10M / 28k = 357 seconds per epoch |

**How to use for allocation requests:**

1. **Identify your problem size:** How many samples/examples does your actual dataset have?
2. **Calculate your epoch time:** 
   ```
   Your epoch time = (Your samples) / (throughput_samples_per_sec from this run)
   ```
3. **Multiply by your needs:**
   ```
   Total training time = epoch_time × number_of_epochs_needed
   ```
4. **Add overhead:** Typically add 20–30% for data loading, validation, checkpointing
5. **Build request:** "Based on a similar 210-city temperature model that takes X minutes to train, my problem (which is Y times larger) will require Z hours of GPU time"

**Example:**
```
This workflow:
- 25 cities × 1273K samples = 31.8M samples
- Throughput: 28,000 samples/sec
- 50 epochs × 45 sec/epoch = 37.5 minutes

Your problem:
- 500 cities × 500K samples = 250M samples
- Projected throughput: ~28,000 samples/sec (same hardware)
- Projected epoch time: 250M / 28k = 8,900 sec = 148 min
- 50 epochs = 7,400 min = 123 hours GPU time
- Request: 150 hours (with overhead) for training
```

---

### 2. Total Training Summary (`outputs/metrics/run_summary.json`)

**What it contains:**
```json
{
  "total_training_sec": 2847,
  "total_training_min": 47.45,
  "avg_epoch_sec": 44.9,
  "avg_throughput_samples_per_sec": 28234
}
```

**What it tells you:**

| Metric | Meaning | Use for Allocation |
|---|---|---|
| `total_training_sec/min` | Wall-clock time from first to last epoch | This is your lower bound: "At minimum, I need this much time" |
| `avg_epoch_sec` | Average seconds per epoch (ignores variability) | Use this for linear scaling to larger datasets |
| `avg_throughput_samples_per_sec` | Average data processing rate | **Golden metric for scaling**: plug this directly into your problem size calculation |

**How to use for allocation requests:**

This file gives you the **summary line** for your allocation narrative:

> *"A comparable workflow on [CPU/GPU hardware] processes [throughput_samples_per_sec] samples per second and completes [total_training_min] minutes of training. Our problem is [X] times larger, so we project [scaled_time] hours and request [conservative_estimate] hours."*

**Why this matters:**
- Reviewers see you've **measured** not guessed
- You've used a **validated baseline** (this workflow)
- You've **scaled appropriately** without over-requesting or under-requesting

---

### 3. Model Quality (`outputs/metrics/test_metrics.json`)

**What it contains:**
```json
{
  "tmax_target": {"MAE": 2.34, "RMSE": 3.12},
  "tmin_target": {"MAE": 1.87, "RMSE": 2.56},
  "prcp_target": {"MAE": 0.15, "RMSE": 0.43}
}
```

**What it tells you:**

| Metric | Meaning | Use for Allocation |
|---|---|---|
| `MAE` (Mean Absolute Error) | Average prediction error in original units | For temp: "Our predictions are off by ~2°F on average" |
| `RMSE` (Root Mean Squared Error) | Penalizes large errors more | Stricter than MAE; shows worst-case error magnitude |
| Target-specific values | Each output variable has different scales and difficulty | Tmax/tmin easier to predict than precipitation |

**How to use for allocation requests:**

These numbers answer: *"Does my approach actually work?"*

**In your request narrative:**

- **If MAE/RMSE are good and validation loss is decreasing:** "Our approach is sound and benefits from more compute. We request X hours to train a larger model / longer / on more data."

- **If MAE/RMSE are poor and validation loss is high:** "Current results suggest we need a methodological adjustment, not just more compute. We request Y hours to [try different architecture / get more training data / tune regularization], then scale up."

- **If MAE/RMSE are good but validation loss is increasing:** "We're seeing overfitting. We request Z hours to [add regularization / tune hyperparameters / use more data], not just longer training."

---

### 4. Trained Model (`outputs/models/mlp_state.pt` and `outputs/models/feature_scaler.pkl`)

**What it contains:**
- `mlp_state.pt`: PyTorch model weights (trained neural network)
- `feature_scaler.pkl`: Feature normalization parameters

**What it tells you:**

You have a **production-ready model** that can make predictions on new data without retraining.

**How to use for allocation requests:**

- **Inference cost:** If your allocation covers training, you can also run inference (predictions) on the same hardware—it's typically 10–100x cheaper than training
- **Iteration strategy:** "We train once (X hours), then iterate on inference and evaluation (Y hours) within the same allocation"
- **Transfer learning:** If your problem is similar to this one, you can fine-tune this model instead of training from scratch—huge savings

---

## Example: Writing an Allocation Request

Here's how all four outputs come together:

---

### Sample Allocation Narrative

**Background:**
We are training a multi-city precipitation and temperature forecasting model on 500 U.S. cities. We need compute time to develop and validate our approach.

**Baseline Evidence:**
A reference workflow trains a similar MLP model on 25 cities:
- **Dataset size:** 31.8M training samples
- **Training time:** 47.5 minutes (50 epochs)
- **Throughput:** 28,234 samples/second on GPU
- **Model quality:** MAE 0.15°F (within acceptable range for operational forecasting)
- **Validation trend:** Improving throughout training, no signs of severe overfitting

**Our Problem Scaling:**
- **Dataset size:** 500 cities = ~320M training samples (10.1× larger)
- **Projected single-run training time:** 47.5 min × 10.1 = 480 minutes ≈ **8 hours**
- **Projected inference (5 runs for testing):** 8 hours × 0.05 = 0.4 hours

**Request Justification:**
- **Development & validation runs:** 5 training runs × 8 hours = 40 hours
- **Hyperparameter tuning:** 3 additional configurations × 8 hours = 24 hours
- **Inference & analysis:** 5 hours
- **Contingency (20%):** 13.8 hours
- **Total request:** **83 GPU hours**

---

## Checklist: Using Results for Allocation Planning

- [ ] Run the workflow on your target platform to get **actual hardware metrics**
- [ ] Note the `avg_throughput_samples_per_sec` from run_summary.json
- [ ] Measure or estimate your **actual problem size** (number of samples)
- [ ] Calculate: `your_epoch_time = your_problem_size / throughput_from_baseline`
- [ ] Multiply by number of epochs you anticipate needing
- [ ] Check `test_metrics.json` — is your approach working? Does it justify more compute?
- [ ] Check `history.csv` validation trends — are you improving? Overfitting? Plateauing?
- [ ] Build conservative estimate: `training_time + inference_time + contingency (20%)`
- [ ] Write narrative that references **actual measurements**, not guesses

---

## Key Principles

1. **Measure, don't guess:** Use real numbers from your workflow, not estimates
2. **Be transparent about scaling:** Show your math—"Problem is 10× larger, so time scales 10×"
3. **Address model quality:** Explain why your metrics justify the requested compute
4. **Plan for iteration:** Budget extra time for tuning, not just final training
5. **Show validation health:** Validation loss trends prove your approach benefits from more compute

---

## Questions to Answer in Your Allocation Request

For each output file, ask:

**history.csv:**
- Is validation loss decreasing throughout? (If no, more epochs alone won't help)
- Is throughput stable? (If erratic, investigate hardware issues before scaling)

**run_summary.json:**
- How does avg_epoch_sec compare across runs? (Lower is better for your scaling)
- Does throughput scale with batch size as expected? (Tells you if memory is limiting)

**test_metrics.json:**
- Are MAE/RMSE acceptable for your use case? (Rough threshold: ±5–10% of expected range)
- Do different targets have similar quality? (Large differences suggest some outputs need more data)

**Models:**
- Can you load and run inference on the trained model? (Proves reproducibility)
- Does inference speed suggest your approach is practical? (Some models are too slow for real-time use)

---

## Next Steps

1. **Run this workflow** on your target allocation (JetStream2 or Anvil or any other resources)
2. **Collect the outputs** from a full 50-epoch run with your actual data
3. **Extract the key metrics** from run_summary.json and test_metrics.json
4. **Scale to your problem size** using the throughput baseline
5. **Write your allocation request** with concrete evidence, not guesses
6. **Submit with confidence** you're not asking for resources blindly; you're requesting based on validated measurement