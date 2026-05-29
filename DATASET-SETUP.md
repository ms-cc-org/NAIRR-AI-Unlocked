# Dataset Setup Guide

**Purpose:** This is a standardized, platform-independent approach to obtaining and staging the temperature dataset for the forecasting workflow. 

---

## Dataset Information

| Property | Value |
|---|---|
| **Name** | Compiled daily temperature and precipitation data for the U.S. cities |
| **Source** | CMU KiltHub |
| **URL** | https://kilthub.cmu.edu/articles/dataset/Compiled_daily_temperature_and_precipitation_data_for_the_U_S_cities/7890488 |
| **Dataset ID** | 7890488 |
| **Size** | ~292 MB |
| **Cities Covered** | 210 U.S. cities |
| **Required Files** | `city_info.csv` + 210 city CSV files |
| **Expected Location in Repo** | `data/temperature-us/` |

---

## Overview

1. **Download** the dataset from the CMU KiltHub link
2. **Extract** the contents (7890488 folder)
3. **Transfer** to the target machine using `rsync`
4. **Verify** the structure matches expectations

This approach ensures dataset consistency across all execution environments (local, JetStream2, Anvil) while keeping the code unchanged.

---

## Step-by-Step Instructions

### On Your Local Machine (Where You Have the Dataset)

#### 1. Download from KiltHub

Visit: https://kilthub.cmu.edu/articles/dataset/Compiled_daily_temperature_and_precipitation_data_for_the_U_S_cities/7890488

Click the download button to get the ZIP file (292 MB). Extract it locally.

### On the Target Machine (JetStream2 or Anvil)

#### 3. Create Directory Structure

From the repository root, create the data directory:

```bash
cd ~/MSCCAM/NAIRR-AI-Unlocked  # or wherever you cloned the repo
mkdir -p data
```

#### 4. Transfer Dataset via rsync

From your local machine, transfer the dataset:

```bash
rsync -avP /path/to/7890488/ ubuntu@<TARGET_IP>:~/MSCCAM/NAIRR-AI-Unlocked/data/temperature-us/
```

**Note:** The trailing slash on the source is important—it copies the *contents* of 7890488 into the `data/temperature-us/` folder, not the folder itself.

**Example:**
```bash
rsync -avP ~/Downloads/7890488/ ubuntu@129.114.104.151:~/MSCCAM/NAIRR-AI-Unlocked/data/temperature-us/
```

For large datasets (292 MB), rsync may take 5–15 minutes depending on network speed. Progress is displayed in real time.

#### 5. Verify Dataset on Target Machine

After the transfer completes, verify the dataset is complete:

```bash
cd ~/MSCCAM/NAIRR-AI-Unlocked

# Count files
ls -1 data/temperature-us/*.csv | wc -l  # Should output 211
```