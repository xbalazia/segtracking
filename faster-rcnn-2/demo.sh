#!/usr/bin/env bash

python3 demo.py --net vgg16 \
                --checkpoint $CHECKPOINT \
                --cuda --load_dir data/pretrained_model