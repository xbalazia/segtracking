function sceneInfo = parseScene(sceneFile)
% read .ini file containing essential scene information

sceneInfo =[];

ini=IniConfig();

try ini.ReadFile(sceneFile);
catch err
    fprintf('Error reading %s. %s',sceneFile,err.message);
end

% make sure ini contains all necessary fields
assert(ini.IsKeys('Scene','dataFolder'),'Need dataFolder');
assert(ini.IsKeys('Scene','imgFolder'),'Need imgFolder');
assert(ini.IsKeys('Scene','tmpFolder'),'Need tmpFolder');
assert(ini.IsKeys('Scene','detFolder'),'Need detFolder');
assert(ini.IsKeys('Scene','trkFolder'),'Need trkFolder');
assert(ini.IsKeys('Scene','visFolder'),'Need visFolder');
assert(ini.IsKeys('Scene','imgFileFormat'),'Need imgFileFormat');
assert(ini.IsKeys('Scene','database'),'Need database');
assert(ini.IsKeys('Scene','detector'),'Need detector');

dataFolder = ini.GetValues('Scene','dataFolder');
database = ini.GetValues('Scene','database');
detector = ini.GetValues('Scene','detector');
sceneInfo.imgFolder = [dataFolder ini.GetValues('Scene','imgFolder') database '/'];
sceneInfo.tmpFolder = [dataFolder ini.GetValues('Scene','tmpFolder') database '/'];
sceneInfo.detFolder = [dataFolder ini.GetValues('Scene','detFolder') database '/' detector '/'];
sceneInfo.trkFolder = [dataFolder ini.GetValues('Scene','trkFolder') database '/' detector '/'];
sceneInfo.visFolder = [dataFolder ini.GetValues('Scene','visFolder') database '/' detector '/'];
sceneInfo.imgFileFormat = ini.GetValues('Scene','imgFileFormat');

% if no frame nums, determine from images
[sceneInfo.frameNums,s]=ini.GetValues('Scene','frameNums');
if ~s
    [~, fe]=strtok(sceneInfo.imgFileFormat,'.');    
    imglisting=dir([sceneInfo.imgFolder, '*', fe]);
    sceneInfo.frameNums=1:length(imglisting);
end

% image dimensions
[sceneInfo.imgHeight, sceneInfo.imgWidth, ~]= ...
    size(imread([sceneInfo.imgFolder sprintf(sceneInfo.imgFileFormat,sceneInfo.frameNums(1))]));

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