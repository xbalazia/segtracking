#!/usr/bin/env bash

python3 demo.py --net vgg16 \
                --checkepoch $EPOCH --checkpoint $CHECKPOINT \
                --cuda --load_dir data/pretrained_model