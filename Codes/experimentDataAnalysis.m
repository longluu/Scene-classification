% Analyze the experimental result of scene classification task to be
% compared to the simulation results
%
% Clear out old stuff
clear; close all;clc

% Define parameters that describe the experiment that was run.
subject = {'LL','DJ','AH','LT','NB'};
nSubjects = length(subject);
baseDir = 'C:\Users\Long Luu\Documents\MATLAB\Fall 2013 courses\Exp_method_for_perception\Final project-Scene classification\experimental result';

% Now we can extract the data into a MxNxP matrix along with the headers
% for each column of data.  Each row represents a particular stimulus and
% all its measurements.  Each column represents a particular
% parameter/measurement for a set of stimuli.  P represents a set of data
% for a given run of the experiment or data file.
grandDataAmplitude = [];
grandDataPhase = [];
isBootstrapSD = 1;
nBootstrapSample = 5000;

%% Analyze for individual subjects
for ii = 1 : nSubjects
    % Analyze amplitude and phase morphing data separately
    resultFig = figure;
    figPos = [0.01, 0.01, 0.98, 0.98];
    set(resultFig,'Units','normalized','Position',figPos)
    hold on
    for jj = 1 : 2
        [data, columnHeaders] = SceneClassExtractData( subject{ii}, jj);
        if strcmp(subject{ii}, 'LL')
            if jj == 1
                isAmplitude = 1;
            else
                isAmplitude = 0;
            end
        else
            load(fullfile(baseDir,subject{ii},['SceneClassification-' num2str(jj) '.mat']))
            if params.isMorphAmplitude
                isAmplitude = 1;
            else
                isAmplitude = 0;
            end
        end

        % Group data into variables specific to the experiment
        % Scene type: 1 for natural, -1 for manmade
        % Morphing value: for 0 to 1
        % Subject response: 1 for natural, -1 for manmade
        dataSceneType = data(:,1);
        dataMorphPercent = data(1:size(data,1)/2,2);
        dataResponse = data(:,3:end);

        % Compare the response and the scene types
        dataResponse = (dataResponse == repmat(dataSceneType,1,size(dataResponse,2)));
        if isAmplitude
            grandDataAmplitude = [grandDataAmplitude dataResponse];
        else
            grandDataPhase = [grandDataPhase dataResponse];
        end
        
        % Take the average and standard error of the response
        percentCorrect = nanmean(dataResponse,2) * 100;
        if isBootstrapSD == 1
            percentCorrectSD = zeros(1,length(dataMorphPercent));            
            for kk = 1 : 2*length(dataMorphPercent)
                bootstrapSamples = bootstrp(nBootstrapSample,@nanmean,dataResponse(kk,:));
                percentCorrectSD(kk) = std(bootstrapSamples)*100;
            end
        else
           percentCorrectSD = nanstd(dataResponse,0,2) * 100/sqrt(size(dataResponse,2));
        end
        percentCorrectManmade = percentCorrect(data(:,1)==-1);
        percentCorrectSDManmade = percentCorrectSD(data(:,1)==-1);
        percentCorrectNatural = percentCorrect(data(:,1)==1);
        percentCorrectSDNatural = percentCorrectSD(data(:,1)==1);
            
        % Plot the result
        if isAmplitude
            subplot(1,2,jj)
            set(gca,'FontSize',15)
            hold on
            h1 = errorbar((1-dataMorphPercent)*100,percentCorrectManmade,percentCorrectSDManmade,'bs-','MarkerSize',8,'MarkerFaceColor','blue');
            h2 = errorbar((1-dataMorphPercent)*100,percentCorrectNatural,percentCorrectSDNatural,'ro-','MarkerSize',8,'MarkerFaceColor','red');
            xlabel('Percent preserved (%)')
            ylabel('Percent classified as seed image (%)')
            title('Amplitude morphing')
            set(gca,'XLim',[-5 105], 'YLim', [0 110])
            legend([h1,h2],'Mandmade','Natural','Location','SouthEast')
        else
            subplot(1,2,jj)
            set(gca,'FontSize',15)
            hold on            
            h1 = errorbar((1-dataMorphPercent)*100,percentCorrectManmade,percentCorrectSDManmade,'bs-','MarkerSize',8,'MarkerFaceColor','blue');
            h2 = errorbar((1-dataMorphPercent)*100,percentCorrectNatural,percentCorrectSDNatural,'ro-','MarkerSize',8,'MarkerFaceColor','red');
            xlabel('Percent preserved (%)')
            ylabel('Percent classified as seed image (%)')
            title('Phase morphing')
            set(gca,'XLim',[-5 105], 'YLim', [0 110])
            legend([h1,h2],'Mandmade','Natural','Location','SouthEast')
        end  
    end
%     export_fig(resultFig,['Subject_' subject{ii} '.jpeg'],'-transparent','-m2')    
end

%% Analyze for grand mean result
% Get the result for amplitude
percentCorrectAmplitude = nanmean(grandDataAmplitude,2) * 100;
if isBootstrapSD == 1
    percentCorrectAmplitudeSD = zeros(1,2*length(dataMorphPercent));            
    for kk = 1 : 2*length(dataMorphPercent)
        bootstrapSamples = bootstrp(nBootstrapSample,@nanmean,grandDataAmplitude(kk,:));
        percentCorrectAmplitudeSD(kk) = std(bootstrapSamples)*100;
    end
else
   percentCorrectAmplitudeSD = nanstd(grandDataAmplitude,0,2) * 100/sqrt(size(grandDataAmplitude,2));
end
percentCorrectAmplitudeManmade = percentCorrectAmplitude(data(:,1)==-1);
percentCorrectSDAmplitudeManmade = percentCorrectAmplitudeSD(data(:,1)==-1);
percentCorrectAmplitudeNatural = percentCorrectAmplitude(data(:,1)==1);
percentCorrectSDAmplitudeNatural = percentCorrectAmplitudeSD(data(:,1)==1);

% Get the result for phase
percentCorrectPhase = nanmean(grandDataPhase,2) * 100;
if isBootstrapSD == 1
    percentCorrectPhaseSD = zeros(1,2*length(dataMorphPercent));            
    for kk = 1 : 2*length(dataMorphPercent)
        bootstrapSamples = bootstrp(nBootstrapSample,@nanmean,grandDataPhase(kk,:));
        percentCorrectPhaseSD(kk) = std(bootstrapSamples)*100;
    end
else
   percentCorrectPhaseSD = nanstd(grandDataPhase,0,2) * 100/sqrt(size(grandDataPhase,2));
end
percentCorrectPhaseManmade = percentCorrectPhase(data(:,1)==-1);
percentCorrectSDPhaseManmade = percentCorrectPhaseSD(data(:,1)==-1);
percentCorrectPhaseNatural = percentCorrectPhase(data(:,1)==1);
percentCorrectSDPhaseNatural = percentCorrectPhaseSD(data(:,1)==1);

% Plot it
resultFig = figure;
figPos = [0.01, 0.01, 0.98, 0.98];
set(resultFig,'Units','normalized','Position',figPos)
hold on

subplot(1,2,1)
set(gca,'FontSize',15)
hold on
h1 = errorbar((1-dataMorphPercent)*100,percentCorrectAmplitudeManmade,...
    percentCorrectSDAmplitudeManmade,'bs-','MarkerSize',8,'MarkerFaceColor','blue');
h2 = errorbar((1-dataMorphPercent)*100,percentCorrectAmplitudeNatural,...
    percentCorrectSDAmplitudeNatural,'ro-','MarkerSize',8,'MarkerFaceColor','red');
xlabel('Percent preserved (%)')
ylabel('Percent classified as seed image (%)')
title('Amplitude morphing')
set(gca,'XLim',[-5 105], 'YLim', [0 110])
legend([h1,h2],'Mandmade','Natural','Location','SouthEast')
box on

subplot(1,2,2)
set(gca,'FontSize',15)
hold on            
h1 = errorbar((1-dataMorphPercent)*100,percentCorrectPhaseManmade,...
    percentCorrectSDPhaseManmade,'bs-','MarkerSize',8,'MarkerFaceColor','blue');
h2 = errorbar((1-dataMorphPercent)*100,percentCorrectPhaseNatural,...
    percentCorrectSDPhaseNatural,'ro-','MarkerSize',8,'MarkerFaceColor','red');
xlabel('Percent preserved (%)')
ylabel('Percent classified as seed image (%)')
title('Phase morphing')
set(gca,'XLim',[-5 105], 'YLim', [0 110])
legend([h1,h2],'Mandmade','Natural','Location','SouthEast')
box on

export_fig(resultFig,'SubjectAll.jpeg','-transparent','-m1')    
