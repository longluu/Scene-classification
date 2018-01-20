% This program shows the morphing effects on amplitude and phase of the
% classified images
%
% Clear all variables, figures and command space
clear;clc;close all

% Read the training and classifying results
baseDir = 'C:\Users\Long Luu\Documents\MATLAB\Fall 2013 courses\Exp_method_for_perception\Final project-Scene classification\';
grayImageAllDir = 'SceneDatabase\ConvertedGray\GraySceneAll';
load(fullfile(baseDir,'trainingResult\resultTraining.mat'))
load(fullfile(baseDir,'trainingResult\resultClassification.mat'))

% Choose a pair from the database
indexNatural = find(strcmp('Natural',classTestImage));
indexManmade = find(strcmp('ManMade',classTestImage));
nNatural = length(indexNatural);
nManmade = length(indexManmade);
indexMorphNatural = indexNatural(round(rand*(nNatural-1)+1));
indexMorphManmade = indexManmade(round(rand*(nManmade-1)+1));
sceneNatural = imread(fullfile(baseDir,grayImageAllDir,allImages(indexMorphNatural).name));
sceneManmade = imread(fullfile(baseDir,grayImageAllDir,allImages(indexMorphManmade).name));

% %% Show the effects on subjective quality of morphing
% % Morph the amplitude
% percentMorph = [0.2 0.8];
% sceneMorph = sceneMorphingAmplitude(sceneNatural,sceneManmade,percentMorph);
% figure
% subplot(1,4,1)
% imshow(sceneNatural)
% subplot(1,4,2)
% imshow(sceneMorph(:,:,1))
% subplot(1,4,3)
% imshow(sceneMorph(:,:,2))
% subplot(1,4,4)
% imshow(sceneManmade)
% title('Morphing the amplitude')
% 
% % Morph the phase
% sceneMorph = sceneMorphingPhase(sceneNatural,sceneManmade,percentMorph);
% figure
% subplot(1,4,1)
% imshow(sceneNatural)
% subplot(1,4,2)
% imshow(sceneMorph(:,:,1))
% subplot(1,4,3)
% imshow(sceneMorph(:,:,2))
% subplot(1,4,4)
% imshow(sceneManmade)
% title('Morphing the phase')

% %% Show the effects of morphing on Gabor space
% % Get the morphed scenes
% percentMorph = 0:0.05:1;
% sceneMorphNaturalAmplitude = sceneMorphingAmplitude(sceneNatural,sceneManmade,percentMorph);
% sceneMorphManmadeAmplitude = sceneMorphingAmplitude(sceneManmade,sceneNatural,percentMorph);
% sceneMorphNaturalPhase = sceneMorphingPhase(sceneNatural,sceneManmade,percentMorph);
% sceneMorphManmadePhase = sceneMorphingPhase(sceneManmade,sceneNatural,percentMorph);
% 
% % Reshape for gist computation
% imageSize = param.imageSize(1);
% sceneMorphNaturalAmplitude = reshape(sceneMorphNaturalAmplitude, ...
%     [imageSize imageSize 1 size(sceneMorphNaturalAmplitude,3)]);
% sceneMorphManmadeAmplitude = reshape(sceneMorphManmadeAmplitude, ...
%     [imageSize imageSize 1 size(sceneMorphManmadeAmplitude,3)]);
% sceneMorphNaturalPhase = reshape(sceneMorphNaturalPhase, ...
%     [imageSize imageSize 1 size(sceneMorphNaturalPhase,3)]);
% sceneMorphManmadePhase = reshape(sceneMorphManmadePhase, ...
%     [imageSize imageSize 1 size(sceneMorphManmadePhase,3)]);
% 
% % Compute the gist
% gistNaturalAmplitude = LMgist(sceneMorphNaturalAmplitude,'',param);
% gistManmadeAmplitude = LMgist(sceneMorphManmadeAmplitude,'',param);
% gistNaturalPhase = LMgist(sceneMorphNaturalPhase,'',param);
% gistManmadePhase = LMgist(sceneMorphManmadePhase,'',param);
% gistNatural = LMgist(sceneNatural,'',param);
% gistNatural = repmat(gistNatural,size(gistNaturalPhase,1),1);
% gistManmade = LMgist(sceneManmade,'',param);
% gistManmade = repmat(gistManmade,size(gistManmadePhase,1),1);
% 
% % Compute the distance from the gist
% distanceNaturalAmplitude = sum((gistNaturalAmplitude - gistNatural).^2,2);
% distanceManmadeAmplitude = sum((gistManmadeAmplitude - gistManmade).^2,2);
% distanceNaturalPhase = sum((gistNaturalPhase - gistNatural).^2,2);
% distanceManmadePhase = sum((gistManmadePhase - gistManmade).^2,2);
% 
% % Plot it out
% amplitueFig = figure;
% set(gca,'FontSize',15)
% h1 = plot((1-percentMorph)*100,distanceNaturalAmplitude,'ro-','MarkerSize',8,'MarkerFaceColor','red');
% hold on
% h2 = plot((1-percentMorph)*100,distanceManmadeAmplitude,'bs--','MarkerSize',8,'MarkerFaceColor','blue');
% xlabel('Percent preserved (%)')
% ylabel('Distance to seed image')
% title('Effect of amplitude morphing')
% legend([h1,h2],'Mandmade','Natural','Location','NorthEast')
% 
% phaseFig = figure;
% set(gca,'FontSize',15)
% h1 = plot((1-percentMorph)*100,distanceNaturalPhase,'bs-','MarkerSize',8,'MarkerFaceColor','blue');
% hold on
% h2 = plot((1-percentMorph)*100,distanceManmadePhase,'ro-','MarkerSize',8,'MarkerFaceColor','red');
% xlabel('Percent preserved (%)')
% ylabel('Distance to seed image')
% title('Effect of phase morphing')
% legend([h1,h2],'Mandmade','Natural','Location','NorthEast')

%% Create animated gif files of morphing effect
% Get the morphed scenes
percentMorph = 0:0.025:1;
sceneMorphNaturalAmplitude = sceneMorphingAmplitude(sceneNatural,sceneManmade,percentMorph);
sceneMorphManmadeAmplitude = sceneMorphingAmplitude(sceneManmade,sceneNatural,percentMorph);
sceneMorphNaturalPhase = sceneMorphingPhase(sceneNatural,sceneManmade,percentMorph);
sceneMorphManmadePhase = sceneMorphingPhase(sceneManmade,sceneNatural,percentMorph);

% Write to gif file
filename = 'sceneMorphManmadeAmplitude';
for n = 1:size(sceneMorphNaturalAmplitude,3)
imshow(sceneMorphManmadeAmplitude(:,:,n))
title(['Morph index:' num2str(percentMorph(n))])
drawnow
frame = getframe(1);
im = frame2im(frame);
[A,map] = rgb2ind(im,256); 
	if n == 1;
		imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',0.1);
	else
		imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',0.1);
	end
end