function flowFile=getFlowFile(sceneInfo,t)

imgFile=getFrameFile(sceneInfo,t);
[~,imgFile,~]=fileparts(imgFile);
imgFile
t
flowFile = [sceneInfo.tmpFolder '/TSP_flows/' imgFile '_flow.mat'];