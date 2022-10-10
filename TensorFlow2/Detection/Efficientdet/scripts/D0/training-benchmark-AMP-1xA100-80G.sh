#!/bin/bash
# Copyright (c) 2022, NVIDIA CORPORATION. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

bs=200
ep=1
lr=2.2
wu=25
ema=0.999
momentum=0.93

mkdir -p /tmp/training-benchmark-1xAMP-A100-80G
rm -rf /tmp/training-benchmark-1xAMP-A100-80G/*
mpirun -np 1 --allow-run-as-root --bind-to none \
-map-by slot -x LD_LIBRARY_PATH -x PATH \
-mca pml ob1 -mca btl ^openib \
-x CUDA_VISIBLE_DEVICES=0 \
python3 train.py \
--training_file_pattern=/workspace/coco/train-* \
--val_file_pattern=/workspace/coco/val-* \
--val_json_file=/workspace/coco/annotations/instances_val2017.json \
--model_name=efficientdet-d0 \
--model_dir=/tmp/training-benchmark-1xAMP-A100-80G \
--backbone_init=/workspace/checkpoints/efficientnet-b0-joc \
--batch_size=$bs \
--num_epochs=$ep \
--use_xla=True \
--amp=True \
--lr=$lr \
--warmup_epochs=$wu \
--benchmark=True \
--benchmark_steps=500 \
--enable_map_parallelization=False \
--hparams="moving_average_decay=$ema,momentum=$momentum" \
2>&1 | tee /tmp/training-benchmark-1xAMP-A100-80G/train-benchmark.log