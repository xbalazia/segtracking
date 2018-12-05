#!/usr/bin/env bash

export CUDA_VISIBLE_DEVICES=1

python3 demo.py --dataset pascal_voc --image_dir data/images \
				--load_dir data/pretrained_model --net vgg16 --cfg cfgs/vgg16.yml \
				--checksession 1 --checkepoch 6 --checkpoint 10021 \
				--cuda