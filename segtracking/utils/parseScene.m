function sceneInfo = parseScene(sceneFile)
% read .ini file containing essential scene information

sceneInfo =[];

ini=IniConfig();


try ini.ReadFile(sceneFile);
catch err,    fprintf('Error reading %s. %s',sceneFile,err.message);
end

% make sure ini contains all necessary fields
%assert(ini.IsKeys('Scene','frameRate'),'Need frameRate');
assert(ini.IsKeys('Scene','imgFolder'),'Need imgFolder');
assert(ini.IsKeys('Scene','tmpFolder'),'Need tmpFolder');
assert(ini.IsKeys('Scene','detFolder'),'Need detFolder');
assert(ini.IsKeys('Scene','trkFolder'),'Need trkFolder');
assert(ini.IsKeys('Scene','visFolder'),'Need visFolder');
assert(ini.IsKeys('Scene','database'),'Need database');
assert(ini.IsKeys('Scene','detector'),'Need detector');

%sceneInfo.frameRate = ini.GetValues('Scene','frameRate');
sceneInfo.imgFolder = ini.GetValues('Scene','imgFolder');
sceneInfo.tmpFolder = ini.GetValues('Scene','tmpFolder');
sceneInfo.detFolder = ini.GetValues('Scene','detFolder');
sceneInfo.trkFolder = ini.GetValues('Scene','trkFolder');
sceneInfo.visFolder = ini.GetValues('Scene','visFolder');
sceneInfo.database = ini.GetValues('Scene','database');
sceneInfo.detector = ini.GetValues('Scene','visFolder');

% Default file format: %06d.jpg
[sceneInfo.imgFileFormat,s]=ini.GetValues('Scene','imgFileFormat');
if ~s, sceneInfo.imgFileFormat='%06d.jpg'; end


% if no frame nums, determine from images
[sceneInfo.frameNums,s]=ini.GetValues('Scene','frameNums');
if ~s
    [~, fe]=strtok(sceneInfo.imgFileFormat,'.');    
    imglisting=dir([sceneInfo.imgFolder, '/', sceneInfo.database, '/', '*', fe]);
    sceneInfo.frameNums=1:length(imglisting);
end

% image dimensions
[sceneInfo.imgFolder '/' sceneInfo.database '/']
[sceneInfo.imgHeight, sceneInfo.imgWidth, ~]= ...
    size(imread([sceneInfo.imgFolder '/' sceneInfo.database '/' sprintf(sceneInfo.imgFileFormat,sceneInfo.frameNums(1))]));

% generic target size, will be determined based on detections
sceneInfo.targetSize=20; 


% ground truth available?
sceneInfo.gtAvailable = 0;
if ini.IsKeys('Scene','gtFile')
    sceneInfo.gtFile = ini.GetValues('Scene','gtFile');
    sceneInfo.gtAvailable = 1;
end

% sequence name and ID (scenario)
[sceneInfo.sequence,s]=ini.GetValues('Scene','sequence');
sceneInfo=getScenarioFromSequence(sceneInfo);

%%%%%%%%%%%%%%%%%%%
% old stuff, ignore
sceneInfo.yshift=0;