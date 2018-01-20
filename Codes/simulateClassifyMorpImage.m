% This program simulates the classification of morphed images using the
% Gabor gists computed in sceneClassifyTraining.m and computes the
% performance of the classification for comparison with human result
%
%
% Clear all variables, figures and command space
clear;clc;close all

% Read in the training result and testing grayscale images
baseDir = 'C:\Users\Long Luu\Documents\MATLAB\Fall 2013 courses\Exp_method_for_perception\Final project-Scene classification\';
imageNaturalDir = 'SceneDatabase\ConvertedGray\GraySceneAll\NaturalScene';
imageManmadeDir = 'SceneDatabase\ConvertedGray\GraySceneAll\ManmadeScene';
imageNatural = dir(fullfile(baseDir,imageNaturalDir,'*.jpg'));
imageManmade = dir(fullfile(baseDir,imageManmadeDir,'*.jpg'));
grayImageAllDir = 'SceneDatabase\ConvertedGray\GraySceneAll';
allImages = dir(fullfile(baseDir,grayImageAllDir,'*.jpg'));
load(fullfile(baseDir,'trainingResult\resultTraining.mat'))

% Set up the parameters for simulation
nImageNatural = length(imageNatural);
nImageManmade = length(imageManmade);
if ~exist('param','var')
    param.imageSize = [256 256]; 
    param.orientationsPerScale = [4 4 4 4];
    param.numberBlocks = 1;
    param.fc_prefilt = 4;
end
percentMorph = 0:0.05:1;
nImages = 400;% min([nImageNatural nImageManmade]);
nCorrectNatural = zeros(1,length(percentMorph));
nCorrectManmade = zeros(1,length(percentMorph));
indexNaturalTest = randperm(nImageNatural);
indexManmadeTest = randperm(nImageManmade);
isMorphAmplitude = 0;

% Start the simulation
fprintf('Classifying image number (total %d): ',nImages)
for ii = 1 : nImages
    % Display the counter
    if ii>1
      for j=0:log10(ii-1)
          fprintf('\b'); % delete previous counter display
      end
    end
    fprintf('%d', ii);
    pause(.05); % allows time for display to update
        
    % Pick the test images
    tempImageManmade = imread(fullfile(baseDir,imageManmadeDir,imageManmade(indexManmadeTest(ii)).name));
    tempImageNatural = imread(fullfile(baseDir,imageNaturalDir,imageNatural(indexNaturalTest(ii)).name));
    
    % Compute the morphed image with amplitude or phase morphing
    if isMorphAmplitude
        testImageMorphManmade = sceneMorphingAmplitude(tempImageManmade,tempImageNatural,percentMorph);     
        testImageMorphNatural = sceneMorphingAmplitude(tempImageNatural,tempImageManmade,percentMorph);     
        morphType = 'Amplitude';
    else
        testImageMorphManmade = sceneMorphingPhase(tempImageManmade,tempImageNatural,percentMorph);     
        testImageMorphNatural = sceneMorphingPhase(tempImageNatural,tempImageManmade,percentMorph);     
        morphType = 'Phase';
    end
    
    % Compute the gist and classify the morphed images
    for jj = 1 : length(percentMorph)
        imageGistManmade = LMgist(testImageMorphManmade(:,:,jj),'',param);
        classImageManmade = classify(imageGistManmade,gistTrained,classTrainImage,'quadratic');
        imageGistNatural = LMgist(testImageMorphNatural(:,:,jj),'',param);
        classImageNatural = classify(imageGistNatural,gistTrained,classTrainImage,'quadratic');        
        if strcmp(classImageManmade,'ManMade')
            nCorrectManmade(jj) = nCorrectManmade(jj) + 1;
        end
        if  strcmp(classImageNatural,'Natural')
            nCorrectNatural(jj) = nCorrectNatural(jj) + 1;
        end   
    end
end
fprintf('/nSimulation completed/n')

% Display the result
percentCorrectManmade = nCorrectManmade*100/nImages;
percentCorrectNatural = nCorrectNatural*100/nImages;
simFig = figure;
set(gca,'FontSize',15)
h1 = plot((1-percentMorph)*100,percentCorrectManmade,'bo-','MarkerSize',8,'MarkerFaceColor','blue');
hold on
h2 = plot((1-percentMorph)*100,percentCorrectNatural,'rs-','MarkerSize',8,'MarkerFaceColor','red');
xlabel('Percent preserved (%)')
ylabel('Percent classified as seed image (%)')
legend([h1,h2],'Mandmade','Natural','Location','NorthWest')
export_fig(simFig,['MorphingSimulation_' morphType '_' num2str(nImages) '_' num2str(length(percentMorph)) '.jpeg'],'-transparent','-m2')
save(['morphSimResult_' morphType '_' num2str(nImages) '_' num2str(length(percentMorph))],...
        'percentMorph', 'percentCorrectNatural', 'percentCorrectManmade','morphType','nImages');
        
% Plot both the amplitude and phase information
if ~exist('percentCorrectManmade','var')
    simFig = figure;
    figPos = [0.01, 0.01, 0.98, 0.98];
    set(simFig,'Units','normalized','Position',figPos)

    load morphSimResult_Amplitude_1216_21.mat    
    subplot(1,2,1)
    set(gca,'FontSize',15)
    h1 = plot((1-percentMorph)*100,percentCorrectManmade,'bs-','MarkerSize',8,'MarkerFaceColor','blue');
    hold on
    h2 = plot((1-percentMorph)*100,percentCorrectNatural,'ro-','MarkerSize',8,'MarkerFaceColor','red');
    xlabel('Percent preserved (%)')
    ylabel('Percent classified as seed image (%)')
    title('Amplitude morphing')
    set(gca,'YLim',[0 110])
    legend([h1,h2],'Mandmade','Natural','Location','SouthEast')
    
    load morphSimResult_Phase_1216_21.mat    
    subplot(1,2,2)
    set(gca,'FontSize',15)
    h1 = plot((1-percentMorph)*100,percentCorrectManmade,'bs-','MarkerSize',8,'MarkerFaceColor','blue');
    hold on
    h2 = plot((1-percentMorph)*100,percentCorrectNatural,'ro-','MarkerSize',8,'MarkerFaceColor','red');
    xlabel('Percent preserved (%)')
    ylabel('Percent classified as seed image (%)')
    title('Phase morphing')
    set(gca,'YLim',[0 110])    
    legend([h1,h2],'Mandmade','Natural','Location','SouthEast')

    export_fig(simFig,['MorphingSimulation_' num2str(nImages) '_' num2str(length(percentMorph)) '.jpeg'],'-transparent','-m1')
end