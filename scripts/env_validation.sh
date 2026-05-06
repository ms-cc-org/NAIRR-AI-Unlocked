#!/usr/bin/env bash

python -c "import sys; print(f'Python: {sys.version}')" || { echo "Python not found error"; exit 1; }

for lib in pandas numpy jupyter nbconvert ipykernel torch tqdm joblib sklearn; do
    python -c "import $lib" 2>/dev/null && echo "done installing $lib" || { echo "$lib is missing";
    exit 1; }
done

python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda}')"