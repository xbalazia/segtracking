#!/usr/bin/env bash

python3 demo.py --net vgg16 \
                --checksession 1 --checkepoch 6 --checkpoint 10021 \
                --cuda --load_dir data/pretrained_model