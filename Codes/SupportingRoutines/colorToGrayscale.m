% This program converts all the images in the database into grayscale
%
% Clear all variables, figures and command space
clear;clc;close all

% Read the original color scenes
baseDir = 'C:\Users\Long Luu\Documents\MATLAB\Fall 2013 courses\Exp_method_for_perception\Final project-Scene classification\';
originalImageDir = 'SceneDatabase\OriginalColor';
grayscaleImageDir = 'SceneDatabase\ConvertedGray';
allImages = dir(fullfile(baseDir,originalImageDir,'spatial_envelope_256x256_static_8outdoorcategories\*.jpg'));
trainImageNatural = dir(fullfile(baseDir,originalImageDir,'TrainImageNatural\*.jpg'));
trainImageManmade = dir(fullfile(baseDir,originalImageDir,'TrainImageManMade\*.jpg'));

% Convert all color scenes to grayscale
nAllImages = length(allImages);
graySceneAllDir = fullfile(baseDir,grayscaleImageDir,'GraySceneAll');
if ~exist(graySceneAllDir,'dir')
    mkdir(graySceneAllDir)
end
fprintf('Classifying image number (total %d): ',nAllImages)
for ii = 1 : nAllImages
    % Display the counter
    if ii>1
      for j=0:log10(ii-1)
          fprintf('\b'); % delete previous counter display
      end
    end
    fprintf('%d', ii);
    pause(.05); % allows time for display to update
    
    % Convert
    clear colorScene
    clear grayScene
    colorScene = imread(fullfile(baseDir,originalImageDir,'spatial_envelope_256x256_static_8outdoorcategories',allImages(ii).name));
    grayScene = rgb2gray(colorScene);

    % Save to folders    
    imwrite(grayScene,fullfile(graySceneAllDir,allImages(ii).name))
end
fprintf('\nConversion completed for all scenes\n')

% Convert all color natural scenes to grayscale
nTrainImageNatural = length(trainImageNatural);
graySceneNaturalDir = fullfile(baseDir,grayscaleImageDir,'GraySceneNatural');
if ~exist(graySceneNaturalDir,'dir')
    mkdir(graySceneNaturalDir)
end
fprintf('Classifying image number (total %d): ',nTrainImageNatural)
for ii = 1 : nTrainImageNatural
    % Display the counter
    if ii>1
      for j=0:log10(ii-1)
          fprintf('\b'); % delete previous counter display
      end
    end
    fprintf('%d', ii);
    pause(.05); % allows time for display to update
    
    % Convert
    clear colorScene
    clear grayScene
    colorScene = imread(fullfile(baseDir,originalImageDir,'TrainImageNatural',trainImageNatural(ii).name));
    grayScene = rgb2gray(colorScene);

    % Save to folders    
    imwrite(grayScene,fullfile(graySceneNaturalDir,trainImageNatural(ii).name))
end
fprintf('\nConversion completed for natural scenes\n')

% Convert all color manmade scenes to grayscale
nTrainImageManmade = length(trainImageManmade);
graySceneManmadeDir = fullfile(baseDir,grayscaleImageDir,'GraySceneManmade');
if ~exist(graySceneManmadeDir,'dir')
    mkdir(graySceneManmadeDir)
end
fprintf('Classifying image number (total %d): ',nTrainImageManmade)
for ii = 1 : nTrainImageManmade
    % Display the counter
    if ii>1
      for j=0:log10(ii-1)
          fprintf('\b'); % delete previous counter display
      end
    end
    fprintf('%d', ii);
    pause(.05); % allows time for display to update
    
    % Convert
    clear colorScene
    clear grayScene
    colorScene = imread(fullfile(baseDir,originalImageDir,'TrainImageManmade',trainImageManmade(ii).name));
    grayScene = rgb2gray(colorScene);

    % Save to folders    
    imwrite(grayScene,fullfile(graySceneManmadeDir,trainImageManmade(ii).name))
end
fprintf('\nConversion completed for manmade scenes\n')