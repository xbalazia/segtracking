function stateInfo=swSegTracker(varargin)
% This code accompanies the publication
%
% Joint Tracking and Segmentation of Multiple Targets
% A. Milan, L. Leal-Taixe, K. Schindler and I. Reid
% CVPR 2015
%

fprintf('-------------------------------------------------------------------------------------\n');

% parse input parameters
p = inputParser;
addOptional(p,'scene','config/scene.ini');
addOptional(p,'params','config/params.ini');

parse(p,varargin{:});


% add paths
addpath(genpath('./utils'))
addpath(genpath('./external'))

% get scene information and parameters
sceneFile = p.Results.scene;
sceneInfo = parseScene(sceneFile);
opt=parseOptions(p.Results.params);

stateInfo = [];


% do entire sequence in small batches (default 50)
allframeNums=sceneInfo.frameNums;
FF=length(allframeNums);
fromframe=1; toframe=min(FF,opt.winSize);
wincnt=0;allwins=[];
allstInfo=[];
while toframe<=FF
    wincnt=wincnt+1;
    fprintf('Working on subwindow... from %4d to %4d = %4d frames\n',fromframe,toframe,length(fromframe:toframe));
    
    opt.frames=fromframe:toframe;
    
    % DO TRACKING ON SUBWINDOW HERE
    stateInfo=segTracking(sceneFile,opt);
    
    allstInfo=[allstInfo stateInfo];
    allwins(wincnt,:)=[fromframe, toframe];
    
    
    % now adjust new time frame
    % if already at end, break
    if toframe==FF,        break;    end
    
    % otherwise slide window and make bigger if needed
    % at the end
    fromframe=fromframe+opt.winSize-opt.winOverlap;
    newend=toframe+opt.winSize-opt.winOverlap;
    if newend > FF-opt.minWinSize
        toframe=FF;
    else
        toframe=newend;
    end
end

%% finish up
sceneInfo=parseScene(sceneFile);
K=opt.nSP;

% superpixel info
load(sprintf('%ssp-K%d.mat',sceneInfo.tmpFolder,K));

% parse detections
fprintf('Parsing detections\n');
detections=parseDetections(sceneInfo,opt);
stateInfo=stitchTempWins(allstInfo,allwins,detections,sp_labels);
stateInfo.frameNums=uint16(stateInfo.frameNums);
stateInfo.splabeling=uint16(stateInfo.splabeling);
stateInfo.detlabeling=uint16(stateInfo.detlabeling);

% evaluation
try gtInfo=convertTXTToStruct(sceneInfo.gtFile);
    printFinalEvaluation(stateInfo, gtInfo, sceneInfo, struct('track3d',char(howToTrack(sceneInfo.scenario))));
catch err
    fprintf('Evaluation skipped. %s\n',err.message);
end

% print tracks
fprintf('Printing tracks\n');
trkFolder = sceneInfo.trkFolder;
if ~exist(trkFolder,'dir')
    mkdir(trkFolder);
end
delete([trkFolder '*.txt']);

[nFrames, nSubjects] = size(stateInfo.Xi);
for s=1:nSubjects
    fileName = fullfile(trkFolder,sprintf('subject%d.txt',s));
    file = fopen(fileName,'w');
    for f = 1:nFrames
        if stateInfo.Xi(f,s)>0
            w = round(stateInfo.W(f,s));
            h = round(stateInfo.H(f,s));
            %x = round(stateInfo.Xi(f,s)-w/2);
            %y = round(stateInfo.Yi(f,s)-h);
            x = round(stateInfo.X(f,s)-w/2);
            y = round(stateInfo.Y(f,s)-h);
            % frame number, subject number, x, y, w, h, confidence (1), 3d coordinate x (0), 3d coordinate y (0)
            fprintf(file, sprintf('%d,%d,%d,%d,%d,%d,%d,%d,%d\n',f,s,x,y,w,h,1,0,0));
        end
    end
    fclose(file);
end

