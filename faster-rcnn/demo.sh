#!/usr/bin/env bash

export CUDA_VISIBLE_DEVICES=5

DATADIR=/home/balazia/pedtrack/_data
DATABASE=virat500
DETECTOR=faster-rcnn

python3 demo.py --images_dir $DATADIR/images/$DATABASE \
				--detections_file $DATADIR/detections/$DATABASE/$DETECTOR/detections.txt \
				--visualizations_dir $DATADIR/detections/$DATABASE/$DETECTOR/visualizations \
				--models_dir models --net vgg16 --cfg cfgs/vgg16.yml \
				--checksession 1 --checkepoch 6 --checkpoint 10021 \
				--cuda