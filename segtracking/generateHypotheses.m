%%
% initsolfile=sprintf('/home/amilan/research/projects/dctracking/data/init/dptracking/startPT-pir-s%04d.mat',scenario);
% load(initsolfile);

% global opt detections
DPHyp=[];
hypothesesMFTDP=[];
hypothesesMFTH=[];

hypsFolder=[sceneInfo.tmpFolder 'hyps'];
if ~exist(hypsFolder,'dir')
    mkdir(hypsFolder);
end

fprintf('DPHyp:');
hfile=sprintf('%s/DPHyp-%04d-%d-%d.mat',hypsFolder,scenario,frames(1),frames(end));
try load(hfile);
catch
    pOpt=getPirOptions;
    opt.cutToTA=0;
    startPT=runDP(sceneInfo, detections,pOpt,opt);
    if isfield(startPT,'stateVec')
        startPT=rmfield(startPT,'stateVec');
    end
    startPT.opt=opt;
    hypotheses=getHypsFromDP(startPT, frames,F,sceneInfo,opt);
    DPHyp=hypotheses;
    save(hfile,'DPHyp','startPT');
end
fprintf('OK\n');

fprintf('MFTHyp:');
hfile=sprintf('%s/MFTHyp-%04d-%d-%d-%d.mat',hypsFolder,scenario,frames(1),frames(end),opt.maxMFTHyp);
try load(hfile)
catch err
    generateHypothesesMFT;save(hfile,'hypothesesMFTH');
end
fprintf('OK\n');

fprintf('MFTDPHyp:');
hfile=sprintf('%s/MFTDPHyp-%04d-%d-%d-%d.mat',hypsFolder,scenario,frames(1),frames(end),opt.maxMFTDPHyp);
try load(hfile)
catch err
    generateHypothesesMFTDP;save(hfile,'hypothesesMFTDP');
end
fprintf('OK\n');

hypotheses=DPHyp;
hypotheses=[hypotheses hypothesesMFTDP];
hypotheses=[hypotheses hypothesesMFTH];


if opt.gthyp
    fprintf('*******************\nWARNING: USING GT!!!\n*******************\n');
    startPT=gtInfo;
    hypGT=getHypsFromDP(gtInfo, frames, F, sceneInfo,opt);
    hypotheses=[hypotheses hypGT];
end

%%
%  startPT=gtInfo;
% opt=getDCOptions;
% opt.track3d=0;
% opt=getAuxOpt('aa',opt,sceneInfo,length(sceneInfo.frameNums));
% sceneInfo=computeImBordersOnGroundPlane(opt,sceneInfo,detections);
% splines=getSplineProposals(alldpoints,200,F);
% startPT=getStateFromSplines(splines, startPT, 1);