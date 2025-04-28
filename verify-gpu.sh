#!/bin/bash
if ! nvidia-smi &>/dev/null; then
  echo "Error: NVIDIA drivers not properly installed!"
  echo "Verify with:"
  echo "1. nvidia-smi"
  echo "2. docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi"
  exit 1
fi
