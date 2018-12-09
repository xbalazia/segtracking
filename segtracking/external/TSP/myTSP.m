% The following script is a demonstration of Temporal Superpixels.
% Prior to running the script, please complete the following steps:
% 1) Install the GNU Scientific Library (http://www.gnu.org/software/gsl/)
% 2) In the current directory, run "compile_MEX". Warnings for the
%    compilation of the optical flow can be safely ignored. If GSL is
%    installed in a directory that cannot be found by Matlab, you may need
%    to edit compile_MEX.m to point to the right locations.
%
% An explanation of the parameters can be found in TSP.m. The script will
% first calculate all optical flows between frames (all but 1 are already
% included for your convenience).
%
% All work using this code should cite:
% J. Chang, D. Wei, and J. W. Fisher III. A Video Representation Using
%    Temporal Superpixels. CVPR 2013.
%
% Written by Jason Chang and Donglai Wei 2013/06/20

%% infer the TSPs

% parameters for TSPs
K = 800;
imgFolder = sceneInfo.imgFolder;
tmpFolder = sceneInfo.tmpFolder; 
[~, fe]=strtok(sceneInfo.imgFileFormat,'.');
filePattern = dir([imgFolder '*' fe]);

files = dir(filePattern); 
xlsfiles = {files.name}
[~,idx] = sort(xlsfiles)
files = files(idx)

dispOn = false;

% infer the TSPs
[sp_labels] = TSP(K, imgFolder, tmpFolder, files, dispOn);

% save the results
outfile=fullfile(tmpFolder,sprintf('sp-K%d.mat',K));
save(fullfile(tmpFolder,outfile),'sp_labels','-v7.3');


%% view the results
% load('results/sp_labels_girl.mat');
% load('results/sp_labels_girl_demo.mat'); % precomputed one
% 
% % root = 'sequences/girl/';
% 
% % view the TSPs
% view_sp_gui(sp_labels, root);