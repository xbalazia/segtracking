function [flowinfo, iminfo, sp_labels, ISall, IMIND, seqinfo, SPPerFrame] = ...
    precompAux(scenario,sceneInfo,K,frames)
% precomp auxiliary data
%%%%%% superpixels

tmpFolder = [sceneInfo.tmpFolder '/' sceneInfo.database '/'];
createTempFolders(tmpFolder)
F=length(frames);
    spfile=fullfile(tmpFolder,sprintf('sp-K%d.mat',K));
    try
        load(spfile);
        sp_labels=sp_labels(:,:,frames);
    catch err
        fprintf('Oops, we need superpixels. This may take a while...\n');
        thisd=pwd;
        TSPd=fullfile('external','TSP');
        myTSP;
    end

% sp_labels=sp_labels+1;



%%%%%% optic flow
% clear flowinfo iminfo
fprintf('flow');
seqInfoDir = fullfile(tmpFolder,'seqinfo');
if ~exist(seqInfoDir,'dir'), mkdir(seqInfoDir); end
fifile=fullfile(seqInfoDir,sprintf('flowinfo-%04d-%d-%d.mat',scenario,frames(1),frames(end)));
try load(fifile)
catch
    for t=2:F
        fprintf('.');
        flow=load(getFlowFile(sceneInfo,t));
        flowinfo(t).flow=flow.flow;
    end
    save(fifile,'flowinfo','-v7.3');
end

% all images in one array
fprintf('\nimage info');
iifile=fullfile(seqInfoDir,sprintf('iminfo-%04d-%d-%d.mat',scenario,frames(1),frames(end)));
try load(iifile)
catch
    for t=1:F
        fprintf('.');
        im=getFrame(sceneInfo,t);
        iminfo(t).img=im;
    end
    save(iifile,'iminfo','-v7.3');
end

fprintf('\n');

%%%%% Iunsp
% independent superpixels for each frame
fprintf('Iunsp');
iunspDir = fullfile(tmpFolder,'Iunsp');
if ~exist(iunspDir,'dir'), mkdir(iunspDir); end
Iunsplfile=fullfile(iunspDir,sprintf('%04d-%d-%d-K%d.mat',scenario,frames(1),frames(end),K));
try load(Iunsplfile)
catch
    Iunsp=unspliceSeg(sp_labels);
    %     fprintf('!!!!! UNSPLICE\n');
    %     Iunsp=sp_labels;
    save(Iunsplfile,'Iunsp','-v7.3');
end

%%%%% ISall
% all info about superpixel in one single matrix
fprintf('\nISall');
isallDir = fullfile(tmpFolder,'ISall');
if ~exist(isallDir,'dir'), mkdir(isallDir); end
ISallfile=fullfile(isallDir,sprintf('%04d-%d-%d-K%d.mat',scenario,frames(1),frames(end),K));
try load(ISallfile)
catch
    [ISall,IMIND]=combineAllIndices(sp_labels, Iunsp, sceneInfo, flowinfo, iminfo);
    save(ISallfile,'ISall','IMIND','-v7.3');
end
fprintf('\n');

%%%%%%%% concat sequence info into struct array
fprintf('seqinfo');
clear seqinfo SPPerFrame
sifile=fullfile(seqInfoDir,sprintf('%04d-%d-%d-K%d.mat',scenario,frames(1),frames(end),K));
try load(sifile)
catch
    for t=1:F
        fprintf('.');
        im=getFrame(sceneInfo,t);
        thisF=sp_labels(:,:,t);
        
        % vector of superpixels for each frame
        seqinfo(t).segF=unique(thisF(:));
%         seqinfo(t).nSeg=getNeighboringSuperpixels(sp_labels(:,:,t)+1);

        % vector of neighbors for each SP
        seqinfo(t).nSegUnsp = getNeighboringSuperpixels(Iunsp(:,:,t)+1);
        
        % weights for neighrbos
        seqinfo(t).nWeights = getNeighborWeights(seqinfo(t).nSegUnsp,Iunsp(:,:,t)+1,im);
        
        % how many superpixels in each frame?
        SPPerFrame(t)=numel(unique(sp_labels(:,:,t)));
    end
    save(sifile,'seqinfo','SPPerFrame','-v7.3');
end
fprintf('\n');
