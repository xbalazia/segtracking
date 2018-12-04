#!/usr/bin/env bash

CUDA_VISIBLE_DEVICES=6 python3 trainval_net.py \
                   --dataset pascal_voc --net vgg16 \
                   --bs $BATCH_SIZE --nw $WORKER_NUMBER \
                   --lr $LEARNING_RATE --lr_decay_step $DECAY_STEP \
                   --cuda

python3 demo.py --net vgg16 \
                --checksession 1 --checkepoch 6 --checkpoint 10021 \
                --cuda --load_dir data/pretrained_model