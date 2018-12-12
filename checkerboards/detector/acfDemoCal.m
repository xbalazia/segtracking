% Demo for aggregate channel features object detector on Caltech dataset.
%
% (1) Download data and helper routines from Caltech Peds Website
%  www.vision.caltech.edu/Image_Datasets/CaltechPedestrians/
%  (1a) Download Caltech files: set*.tar and annotations.zip
%  (1b) Copy above files to dataDir/data-USA/ and untar/unzip contents
%  (1c) Download evaluation code (routines necessary for extracting images)
% (2) Set dataDir/ variable below to point to location of Caltech data.
% (3) Launch "matlabpool open" for faster training if available.
% (4) Run demo script and enjoy your newly minted fast ped detector!
%
% Note: pre-trained model files are provided (delete to re-train).
% Re-training may give slightly variable results on different machines.
%
% Piotr's Image&Video Toolbox      Version 3.22
% Copyright 2013 Piotr Dollar & Ron Appel.  [pdollar-at-caltech.edu]
% Please email me if you find bugs, or have suggestions or questions!
% Licensed under the Simplified BSD License [see external/bsd.txt]

%% set up environment
clc;
CodePath = '/home/balazia/pedtrack/checkerboards/';
addpath(genpath(CodePath));
ModelPath = [CodePath 'data/models/Checkerboards/'];
database = 'caltech';
DataPath = '/home/balazia/pedtrack/_data/';
ImagesPath = [DataPath 'images/' database '/'];
DetectionsFile = [DataPath 'detections/' database '/checkerboards/detections.txt'];

%% set up parameters for training detector (see acfTrain_my)
opts = acfTrain_my();
opts.posGtDir = [CodePath 'data/annotations'];
opts.posImgDir = [CodePath 'data/images/train'];
opts.name = ModelPath;

opts.modelDs=[96 36]; opts.modelDsPad=[120 60];
opts.pPyramid.smooth=0; opts.pPyramid.pChns.pColor.smooth=0; 

opts.pJitter=struct('flip',1);
opts.pBoost.pTree.fracFtrs=1;
opts.nWeak=[32 512 1024 2048 4096]; %opts.nWeak=[32 512 1024 2048 4096];
pLoad={'lbls',{'person'},'ilbls',{'people'},'squarify',{3,.41}};
opts.pLoad = [pLoad 'hRng',[50 inf], 'vRng',[1 1] ];

opts.pPyramid.pChns.shrink = 6; opts.stride =6;opts.pPyramid.nApprox = 0;
opts.cascThr = -1; opts.pPyramid.pChns.cbin = [2,5,5];
opts.pPyramid.pChns.pGradHist.softBin = 1;
opts.pPyramid.pChns.pGradHist.clipHog = Inf;
opts.nNeg=10000;opts.nAccNeg = 50000; opts.nPerNeg = 25;
opts.pPyramid.pChns.pGradHist.binSize=opts.pPyramid.pChns.shrink;
opts.pPyramid.pChns.NNRadius= 1;
opts.pPyramid.nOctUp = 1;
opts.pBoost.pTree.maxDepth =4;
opts.pBoost.discrete=0;

%% train detector (see acfTrain)
if(1)
    detector = acfTrain_my(opts);
end

%% modify detector (see acfModify)
if(0)
    detector = acfModify_my(detector,'cascThr',-1,'cascCal',0.1);
    detector.opts.pPyramid.nPerOct = 10;

    save([opts.name 'detector.mat'],'detector');

    sprintf('time=\t'); fix(clock)
    newline;
end

%% test detector and evaluate (see acfTest_my)
if(0)
    tstart = tic; [miss,~,gt,dt] = acfTest_my(...
      'name', opts.name, ...
      'imgDir', [CodePath 'data/images/test'] , ...
      'gtDir', [CodePath 'data/annotations'], ...
      'pLoad', [pLoad, 'hRng',[50 inf], 'vRng', [.65 1], 'xRng', [5 635], 'yRng',[5 475]], 'show',2);
    telapsed = toc(tstart);

    fid = fopen([ModelPath 'AcfCaltechLog.txt'],'a'); 
    fprintf(fid,'\n test time = %f seconds = %f hours\n', telapsed, telapsed/3600);
    fclose(fid);

    sprintf('time=\t'); fix(clock)
    newline;
    savefig([ModelPath 'curve'],'pdf');
    close;
end

%% run detector on a set of images without evaluation
if(1)
    imgNms = bbGt('getFiles',{ImagesPath});
    tic, bbs = acfDetect_my(imgNms,detector,DetectionsFile); toc
    % visualize detection results on one single image
    %k=48;
    %I=imread(imgNms{k});
    %figure(1); im(I); bbApply('draw',bbs{k}); pause(.1);
end

%% optionally show top false positives ('type' can be 'fp','fn','tp','dt')
if(0), bbGt('cropRes',gt,dt,imgNms,'type','fn','n',50,...
    'show',3,'dims',opts.modelDs([2 1]));
end
