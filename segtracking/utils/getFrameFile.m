function filename=getFrameFile(sceneInfo,t)
% get the file name for one specific frame

filename=[sceneInfo.imgFolder '/' sceneInfo.database '/' sprintf(sceneInfo.imgFileFormat,sceneInfo.frameNums(t))];

end