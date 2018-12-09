function flowFile=getFlowFile(sceneInfo,t)

[~,imgName,~]=fileparts(getFrameFile(sceneInfo,t));
flowFile = [sceneInfo.tmpFolder '/' sceneInfo.database '/TSP_flows/' imgName '_flow.mat'];