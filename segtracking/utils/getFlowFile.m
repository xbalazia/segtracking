function flowFile=getFlowFile(sceneInfo,t)

[~,imgFile,~]=fileparts(getFrameFile(sceneInfo,t));
flowFile = fullfile(sceneInfo.tmpFolder,'TSP_flows/',[imgFile '_flow.mat']);