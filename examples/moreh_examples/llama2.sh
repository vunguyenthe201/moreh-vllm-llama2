#!/bin/bash

export MODEL_PATH=/app/models/llama-2-70b-hf/
export VLLM_USE_V1=1

export VLLM_ROCM_USE_AITER=1
export VLLM_ROCM_USE_AITER_LINEAR=1 

# export VLLM_SERVER_DEV_MODE=1

export HIP_VISIBLE_DEVICES=0,1,2,3
# export VLLM_TORCH_PROFILER_DIR=/workspace/trace/moreh-vllm 
export AITER_LOG_LEVEL=DEBUG 
vllm serve ${MODEL_PATH} \
    --port 8001 \
    --disable-log-requests \
    --tensor-parallel-size 4 \
    --trust-remote-code \
    --max-model-len 4096 \
    --gpu-memory-utilization 0.90 \
    --num-scheduler-steps 1 \
    --block-size 16 \
    --max-num-batched-tokens 4096 \
    --no-enable-prefix-caching \
    --enable-chunked-prefill \
    --compilation-config '{"full_cuda_graph": false}' \
    --quantization fp8 \

