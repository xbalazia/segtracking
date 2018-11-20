In this code, Checkerboards detector is implemented based on Piotr Dollar's toolbox V3.22 (http://vision.ucsd.edu/~pdollar/toolbox/doc/).
This version is exactly what we used for our CVPR15 paper 'Filtered Channel Features for Pedestrian Detection'.

1. Compilation.
First, run ./external/toolboxCompile.m to compile the toolbox.
And then run the following commands to compile two cpp files added to the toolbox:
cd ./detector/private
mex acfDetect1_my_fastchnftr2_autoTemplates.cpp
mex feature_on_templates2_autoTemplates.cpp

2. Run our detector.
There is a pre-trained model stored in ./models_Caltech/Checkerboards/.
To run our detector on your data, you just run ./detector/acfDemoCal.m, but please make sure you specify the right paths to the code and test data in ./detector/acfDemoCal.m.
'CodePath': path to the code
'testdataDir': path to test images;
'testgtDir': path to test annotations (one txt file per image);
'vbbDir': path to original vbb files (used for evaluation).


It is also possible to run our detector without evaluation and visualize the detections on a given image. 
See the section of "%% run detector on a set of images without evaluation" in ./detector/acfDemoCal.m.
For reasonable visualization, you may discard those low-scoring detections using a threshold.

3. Train your own model.
In ./detector/acfDemoCal.m, training procedure is followed by testing and evaluation.
If you want to train your own model, please specify the paths to your training data:
'opts.posImgDir': path to training images;
'opts.posGtDir': path to training annotations (one txt file per image);
and please also change the parameter of 'versionstr';otherwise, the pre-trained model will be loaded and the training procedure will be skipped.
The trained model, log file, test detections and evaluation curve will be saved in ./models_Caltech/[versionstr]/.

4. Adapt to different filter banks.
You may change the filter definition in ./detector/private/feature_on_templates2_autoTemplates.cpp and ./detector/private/acfDetect1_my_fastchnftr2_autoTemplates.cpp and then re-compile both cpp files
to use other filters for feature computation.
For example, you can try with the InformedHaar filters given in ./InformedHaar_filters.txt, which were proposed in the paper entilted "Informed Haar-like Features Improve Pedestrian Detection".
