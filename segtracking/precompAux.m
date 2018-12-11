function [flowinfo, iminfo, sp_labels, ISall, IMIND, seqinfo, SPPerFrame] = precompAux(sceneInfo,K,frames)
% precomp auxiliary data

%%%%%% superpixels
try load(sprintf('%ssp-K%d.mat',sceneInfo.tmpFolder,K));
catch err
    fprintf('Oops, we need superpixels. This may take a while...\n');
    myTSP;
end

F=length(frames);
sp_labels=sp_labels(:,:,frames);
scenario=sceneInfo.scenario;

%%%%%% optic flow
% clear flowinfo iminfo
fprintf('seqinfo/flowinfo:');
seqInfoDir = fullfile(sceneInfo.tmpFolder,'seqinfo');
if ~exist(seqInfoDir,'dir'), mkdir(seqInfoDir); end
fifile=sprintf('%s/flowinfo-%04d-%d-%d.mat',seqInfoDir,scenario,frames(1),frames(end));
try load(fifile)
catch
    for t=2:F
        fprintf('.');
        flow=load(getFlowFile(sceneInfo,t));
        flowinfo(t).flow=flow.flow;
    end
    save(fifile,'flowinfo','-v7.3');
end
fprintf('OK\n');

% all images in one array
fprintf('seqinfo/iminfo:');
iifile=sprintf('%s/iminfo-%04d-%d-%d.mat',seqInfoDir,scenario,frames(1),frames(end));
try load(iifile)
catch
    for t=1:F
        fprintf('.');
        im=getFrame(sceneInfo,t);
        iminfo(t).img=im;
    end
    save(iifile,'iminfo','-v7.3');
end
fprintf('OK\n');

%%%%% Iunsp
% independent superpixels for each frame
fprintf('Iunsp:');
iUnspDir = fullfile(sceneInfo.tmpFolder,'Iunsp');
if ~exist(iUnspDir,'dir'), mkdir(iUnspDir); end
Iunsplfile=sprintf('%s/%04d-%d-%d-K%d.mat',iUnspDir,scenario,frames(1),frames(end),K);
try load(Iunsplfile)
catch
    Iunsp=unspliceSeg(sp_labels);
    %     fprintf('!!!!! UNSPLICE\n');
    %     Iunsp=sp_labels;
    save(Iunsplfile,'Iunsp','-v7.3');
end
fprintf('OK\n');

%%%%% ISall
% all info about superpixel in one single matrix
fprintf('ISall:');
isAllDir = fullfile(sceneInfo.tmpFolder,'ISall');
if ~exist(isAllDir,'dir'), mkdir(isAllDir); end
ISallfile=sprintf('%s/%04d-%d-%d-K%d.mat',isAllDir,scenario,frames(1),frames(end),K);
try load(ISallfile)
catch
    [ISall,IMIND]=combineAllIndices(sp_labels,Iunsp,sceneInfo,flowinfo,iminfo);
    save(ISallfile,'ISall','IMIND','-v7.3');
end
fprintf('OK\n');

%%%%%%%% concat sequence info into struct array
fprintf('seqinfo:');
clear seqinfo SPPerFrame
sifile=sprintf('%s/%04d-%d-%d-K%d.mat',seqInfoDir,scenario,frames(1),frames(end),K);
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
fprintf('OK\n');
