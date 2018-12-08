#!/usr/bin/env bash

export CUDA_VISIBLE_DEVICES=1

python3 demo.py --data_dir data/ --images_dir data/images-caltech --detections_file data/detections-caltech.txt --visualizations_dir data/visualizations-caltech \
				--models_dir data/models --net vgg16 --cfg cfgs/vgg16.yml --checksession 1 --checkepoch 6 --checkpoint 10021 \
				--cuda