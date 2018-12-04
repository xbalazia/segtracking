#!/usr/bin/env bash

python3 demo.py --dataset pascal_voc \
				--load_dir data/pretrained_model --net vgg16 --cfg cfgs/vgg16.yml \
				--checksession 1 --checkepoch 6 --checkpoint 10021