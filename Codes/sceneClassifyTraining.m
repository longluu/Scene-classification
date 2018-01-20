% This program extracts the gist of a set of images in terms of Gabor
% representation and perform training and classification using discriminant
% analysis
%
% Clear all variables, figures and command space
clear;clc;close all

% Get the information of database of all images and trained images
baseDir = 'C:\Users\Long Luu\Documents\MATLAB\Fall 2013 courses\Exp_method_for_perception\Final project-Scene classification\';
grayImageAllDir = 'SceneDatabase\ConvertedGray\GraySceneAll';
grayNaturalDir = 'SceneDatabase\ConvertedGray\GraySceneNatural';
grayManmadeDir = 'SceneDatabase\ConvertedGray\GraySceneManmade';
allImages = dir(fullfile(baseDir,grayImageAllDir,'*.jpg'));
trainImageNatural = dir(fullfile(baseDir,grayNaturalDir,'*.jpg'));
trainImageManmade = dir(fullfile(baseDir,grayManmadeDir,'*.jpg'));

%% Compute the gist of trained images
nTrainNatural = length(trainImageNatural);
nTrainManmade = length(trainImageManmade);

% Gist extraction parameters
clear param
param.imageSize = [256 256]; % it works also with non-square images
param.orientationsPerScale = [4 4 4 4];
param.numberBlocks = 1;
param.fc_prefilt = 4;
nBases = sum(param.orientationsPerScale) * (param.numberBlocks)^2;
gistTrained = NaN(nTrainNatural+nTrainNatural,nBases);

% Compute the gist
fprintf('Trained image number (total %d): ',nTrainNatural+nTrainNatural)
for ii = 1 : nTrainNatural+nTrainNatural
    % Display the counter
    if ii>1
      for j=0:log10(ii-1)
          fprintf('\b'); % delete previous counter display
      end
    end
    fprintf('%d', ii);
    pause(.05); % allows time for display to update
    
    % Read image and compute gist
    if ii <= nTrainNatural
        tempImageNatural = imread(fullfile(baseDir,grayNaturalDir,trainImageNatural(ii).name));
        gistTrained(ii,:) = LMgist(tempImageNatural,'',param);
    else
        tempImageManmade = imread(fullfile(baseDir,grayManmadeDir,trainImageManmade(ii-nTrainNatural).name));
        gistTrained(ii,:) = LMgist(tempImageManmade,'',param);
    end        
end
fprintf('\nTraining completed\n')

%% Classify all images in the database
% Label the trained images
classTrainImage(1:nTrainNatural,1) = {'Natural'};
classTrainImage(nTrainNatural+1:nTrainNatural+nTrainManmade,1) = {'ManMade'};

% Initialize variables
nAllImage = length(allImages);
classTestImage = cell(1,nAllImage);
fprintf('Classifying image number (total %d): ',nAllImage)
for ii = 1:nAllImage
    % Display the counter
    if ii>1
      for j=0:log10(ii-1)
          fprintf('\b'); % delete previous counter display
      end
    end
    fprintf('%d', ii);
    pause(.05); % allows time for display to update
    
    % Compute the gist of test image
    tempTestImage = imread(fullfile(baseDir,grayImageAllDir,allImages(ii).name));
    gistSample = LMgist(tempTestImage,'',param);

    % Classify the test image
    classTestImage(ii) = classify(gistSample,gistTrained,classTrainImage,'quadratic');
end
fprintf('\nClassification completed\n')

%% Calculate the percent correct of classification (roughly)
fileNameNatural = {'coast';'forest';'mountain';'opencountry'};
fileNameManmade = {'highway';'insidecity';'street';'tallbuilding'};
nCorrectClass = 0;
for ii = 1 : nAllImage
    if ismember(strtok(allImages(ii).name,'_'),fileNameNatural) && ~ismember(allImages(ii).name,{trainImageNatural.name})
        if strcmp(classTestImage{ii},'Natural')
            nCorrectClass = nCorrectClass + 1;
        end
    elseif ismember(strtok(allImages(ii).name,'_'),fileNameManmade)  && ~ismember(allImages(ii).name,{trainImageManmade.name})
        if strcmp(classTestImage{ii},'ManMade')
            nCorrectClass = nCorrectClass + 1;
        end
    end
end
percentClassCorrect = nCorrectClass*100/(nAllImage-nTrainNatural-nTrainManmade);
fprintf('Percent correct classification: %f\n',percentClassCorrect);

% Save the result
resultTrainingDir = fullfile(baseDir,'trainingResult');
if ~exist(resultTrainingDir,'dir')
    mkdir(resultTrainingDir);
end
save(fullfile(resultTrainingDir,'resultTrainingNew.mat'),'gistTrained','classTrainImage','param')
save(fullfile(resultTrainingDir,'resultClassificationNew.mat'),'classTestImage','allImages','percentClassCorrect')