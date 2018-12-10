function sceneInfo = parseScene(sceneFile)
% read .ini file containing essential scene information

sceneInfo=[];

ini=IniConfig();


try ini.ReadFile(sceneFile);
    catch err,    fprintf('Error reading %s. %s',sceneFile,err.message);
end

% make sure ini contains all necessary fields
assert(ini.IsKeys('Scene','img'),'Need img');
assert(ini.IsKeys('Scene','tmp'),'Need tmp');
assert(ini.IsKeys('Scene','det'),'Need det');
assert(ini.IsKeys('Scene','trk'),'Need trk');
assert(ini.IsKeys('Scene','vis'),'Need vis');
assert(ini.IsKeys('Scene','database'),'Need database');
assert(ini.IsKeys('Scene','detector'),'Need detector');

img = ini.GetValues('Scene','img');
tmp = ini.GetValues('Scene','tmp');
det = ini.GetValues('Scene','det');
trk = ini.GetValues('Scene','trk');
vis = ini.GetValues('Scene','vis');
database = ini.GetValues('Scene','database');
detector = ini.GetValues('Scene','detector');

sceneInfo.imgFolder = [img database '/'];
sceneInfo.tmpFolder = [tmp database '/'];
sceneInfo.detFolder = [det database '/' detector '/'];
sceneInfo.trkFolder = [trk database '/' detector '/'];
sceneInfo.visFolder = [vis database '/' detector '/'];

% Default file format: %06d.jpg
[sceneInfo.imgFileFormat,s]=ini.GetValues('Scene','imgFileFormat');
if ~s, sceneInfo.imgFileFormat='%06d.jpg'; end


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
sceneInfo.scenario=0; %getScenarioFromSequence(sceneInfo)

%%%%%%%%%%%%%%%%%%%
% old stuff, ignore
sceneInfo.yshift=0;