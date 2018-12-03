run external/toolboxCompile.m
cd detector/private
mex acfDetect1_my_fastchnftr2_autoTemplates.cpp
mex feature_on_templates2_autoTemplates.cpp
cd ../../channels/private
mex mexgrid_sum.cpp
cd ../..
run detector/acfDemoCal.m