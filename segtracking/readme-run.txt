installSegTracker;
cd external/TSP/optical_flow_celiu/mex
mex -O -largeArrayDims Coarse2FineTwoFrames.cpp GaussianPyramid.cpp OpticalFlow.cpp
cd ../../../..
stateInfo = swSegTracker('scene','config/scene.ini','params','config/params.ini');