function SceneClassification_Driver(params)
% Driver to run the scene classification experiment
%

% Set up screen info
fullScreen = true;
screenInfo = get(0,'ScreenSize');
sceneDimension = screenInfo(3:4);

% Create the GLWindow with screen dimension in pixel.
win = GLWindow('FullScreen', logical(fullScreen), ...
    'SceneDimensions', sceneDimension);

% Get the image information from database
imageNatural = dir('/Users/longluu/Desktop/SceneClassification/ImageDatabase/NaturalScene/*.jpg');
imageManmade = dir('/Users/longluu/Desktop/SceneClassification/ImageDatabase/ManMadeScene/*.jpg');

% Randomize order of natural/manmade scene presentation
nImageNatural = length(imageNatural);
nImageManmade = length(imageManmade);
naturalIndex = randperm(nImageNatural);
manmadeIndex = randperm(nImageManmade);
if ~params.staircase
    % Don't use staircase
    nBlocks = params.nBlocks;
    nTrials = 2 * length(params.morphPercent);
    nMorphPercent  = length(params.morphPercent);
    imageShow = [ones(1,nMorphPercent) (-1)*ones(1,nMorphPercent)];
    morphPercentTrial = [params.morphPercent params.morphPercent];
else
    % Use staircase
    nBlocks = 1;
    nTrials = params.nTrials;
    imageShow = [ones(1,nTrials/2) (-1)*ones(1,nTrials/2)];
    QuestDataNatural = NaN(nTrials/2,4);
    QuestDataManmade = NaN(nTrials/2,4);
end
morphPercentUsed = NaN(1,nTrials);

% Initialize the book-keeping variables
responseData = NaN(nTrials,nBlocks);
imageNameTrialSeed = cell(nTrials,nBlocks);
imageNameTrialSupp = cell(nTrials,nBlocks);

% Open the window
win.open;

try
    % Clear out any previous keypresses.
	FlushEvents;

    % Present the start text and wait for go signal
    win.addText('Hit Any Key To Start', 'Name', 'startText', 'Center', [0 0], ...
        'FontSize', 80, 'Color', [1 1 1]);
    FlushEvents;
    win.enableObject('startText');
    win.draw;
    FlushEvents;
    keepLooping = true;
    while keepLooping
        if ~isempty(GetChar)
            keepLooping = false;
        end
    end
    win.disableObject('startText');
    win.draw
    
    % Add the feedback text
    win.addText('Correct', 'Name', 'correctText', 'Center', [0 params.imageSize/2+100], ...
        'FontSize', 80, 'Color', [0 1 0]);
    win.addText('Incorrect', 'Name', 'incorrectText', 'Center', [0 params.imageSize/2+100], ...
        'FontSize', 80, 'Color', [1 0 0]);
    win.disableObject('correctText');
    win.disableObject('incorrectText');
    
    % Generate a random mask
    imData = rand(params.imageSize, params.imageSize);
    imData = repmat(imData, [1 1 3]);
    
    %% Create two staircase Quest objects
    if params.staircase
        pThreshold      = 0.65;    
        grainStep       = 0.005;
        gamma           = 0.5;
        delta           = 0.01;

        % Quest natural
        tGuessNatural          = 0.5;
        tGuessSdNatural        = 3;  
        betaNatural            = 3;
        qNatural = QuestCreate(tGuessNatural, tGuessSdNatural, pThreshold, betaNatural, delta, gamma, grainStep);

        % Quest manmade
        tGuessManmade          = 0.5;
        tGuessSdManmade        = 3;  
        betaManmade            = 3;
        qManmade = QuestCreate(tGuessManmade, tGuessSdManmade, pThreshold, betaManmade, delta, gamma, grainStep);
        
        % Set counter for data bookkeeping variable
        counterNatural = 0;
        counterManmade = 0;
    end
    
    %% Start the trials
    for blockIndex = 1 : nBlocks
        trialOrder = randperm(nTrials);
        for trialIndex = 1 : nTrials
            % Add a fixation point
            if (params.fpSize > 0)
                win.addOval([0 0], [params.fpSize params.fpSize], params.fpColor, 'Name', 'FixPoint');
            end
            win.enableObject('FixPoint')
            win.draw

            % Wait for some time 
            onsetTime =  mglGetSecs;
            keepLooping = true;
            while keepLooping
                % quit if we reach the required duration
                if (mglGetSecs - onsetTime) > params.fixationToTargetLatency
                    keepLooping = false;
                end
            end

            % Disable fixation point
            win.disableObject('FixPoint')
            win.draw
            
            % Choose the morphing value
            if ~params.staircase
                morphPercent = morphPercentTrial(trialOrder(trialIndex));
            else
                % Update the morphing value using Quest
                if imageShow(trialOrder(trialIndex)) == 1 
                    % Convert between morphing value and internal represenation
                    % morphPercent: the lower the better
                    % internal intensity: the higher the better
                    morphPercent = 1 - QuestQuantile(qNatural); 
                else
                    morphPercent = 1 - QuestQuantile(qManmade);
                end               
                % Curve the morphing value to sensible range
                if morphPercent > 1
                    morphPercent = 1;
                elseif morphPercent < 0;
                    morphPercent = 0;
                end
            end            
            morphPercentUsed(trialOrder(trialIndex)) = morphPercent;

            % Randomly select natural or manmade.
            tempImageNatural = imread(imageNatural(naturalIndex(nTrials*(blockIndex-1)+trialIndex)).name);
            tempImageManmade = imread(imageManmade(manmadeIndex(nTrials*(blockIndex-1)+trialIndex)).name);
            if imageShow(trialOrder(trialIndex)) == 1           
                % Show natural scene
                morphImage = sceneMorphingAmplitude(tempImageNatural, tempImageManmade, morphPercent);           
                morphImage = double(flipud(morphImage))/256;
                win.addImage([0 0], [params.imageSize params.imageSize], repmat(morphImage,[1 1 3]), ...
                                      'Name', 'Target');
                imageNameTrialSeed{trialOrder(trialIndex),blockIndex} = imageNatural(naturalIndex(nTrials*(blockIndex-1)+trialIndex)).name;
                imageNameTrialSupp{trialOrder(trialIndex),blockIndex} = imageManmade(manmadeIndex(nTrials*(blockIndex-1)+trialIndex)).name;       
            else
                % Show manmade scene  
                morphImage = sceneMorphingAmplitude(tempImageManmade, tempImageNatural, morphPercent);           
                morphImage = double(flipud(morphImage))/256;            
                win.addImage([0 0], [params.imageSize params.imageSize], repmat(morphImage,[1 1 3]), ...
                                      'Name', 'Target');
                imageNameTrialSeed{trialOrder(trialIndex),blockIndex} = imageManmade(manmadeIndex(nTrials*(blockIndex-1)+trialIndex)).name; 
                imageNameTrialSupp{trialOrder(trialIndex),blockIndex} = imageNatural(naturalIndex(nTrials*(blockIndex-1)+trialIndex)).name;                
            end

            % Add the masks
            win.addImage([0 0], [params.imageSize params.imageSize], imData, 'Name', 'randImage');

            % Enable the target and disable the mask
            win.enableObject('Target');
            win.disableObject('randImage');
            win.draw

            % Wait for some time 
            onsetTime =  mglGetSecs;
            keepLooping = true;
            while keepLooping
                % quit if we reach the required duration
                if (mglGetSecs - onsetTime) > params.targetToMaskLatency
                    keepLooping = false;
                end
            end

            % Disable the target and enable the mask
            win.enableObject('randImage');
            win.disableObject('Target');
            win.draw

            % Get the subject's response
            keepLooping = true;
            while keepLooping
                % Process any keypresses.
                key = mglGetKeyEvent;
                if ~isempty(key)
                    switch key.charCode
                        % Left/Down
                        case params.leftKey
                            responseData(trialOrder(trialIndex),blockIndex) = -1;
                            keepLooping = false;

                        % Right/Up
                        case params.rightKey
                            responseData(trialOrder(trialIndex),blockIndex) = 1;
                            keepLooping = false;

                        % Abort.
                        case 'q'
                            error('abort');
                    end
                end
            end
            
            % Present the feedback
            responseCorrect = (imageShow(trialOrder(trialIndex)) == responseData(trialOrder(trialIndex),blockIndex));
            if params.enableFeedback == 1
                if responseCorrect
                    textTag = 'correctText';
                else
                    textTag = 'incorrectText';
                end
                
				% Enable the appropriate feedback text.
				win.enableObject(textTag);
				win.draw
                pause(0.5)
				
				% Turn off the feedback text.
				win.disableObject(textTag);
                win.draw
            end
            
            % Disable the mask
            win.disableObject('randImage')
            win.draw
            
            % Update the Quest object and store the data
            if params.staircase
                if imageShow(trialOrder(trialIndex)) == 1 
                    counterNatural = counterNatural + 1;
                    qNatural = QuestUpdate(qNatural, 1-morphPercent, responseCorrect);
                    morphPercentEstimate  = 1 - QuestMean(qNatural);
                    morphPercentEstimateSD = QuestSd(qNatural);
                    QuestDataNatural(counterNatural,1) = morphPercent;
                    QuestDataNatural(counterNatural,2) = responseCorrect;
                    QuestDataNatural(counterNatural,3) = morphPercentEstimate;
                    QuestDataNatural(counterNatural,4) = morphPercentEstimateSD;
                else
                    counterManmade = counterManmade + 1;
                    qManmade = QuestUpdate(qManmade, 1-morphPercent, responseCorrect);
                    morphPercentEstimate  = 1 - QuestMean(qManmade);
                    morphPercentEstimateSD = QuestSd(qManmade);
                    QuestDataManmade(counterManmade,1) = morphPercent;
                    QuestDataManmade(counterManmade,2) = responseCorrect;
                    QuestDataManmade(counterManmade,3) = morphPercentEstimate;
                    QuestDataManmade(counterManmade,4) = morphPercentEstimateSD;
                end
            end
        end
    end
    
    %% Save the data
    % Close everything down.
    ListenChar(0);
    win.close;

    % Figure out some data saving parameters.
    dataFolder = sprintf('/Users/longluu/Desktop/SceneClassification/data/%s', params.subject);
    if ~exist(dataFolder, 'dir')
        mkdir(dataFolder);
    end
    dataFile = sprintf('%s/%s-%d.csv', dataFolder, params.experimentName, GetNextDataFileNumber(dataFolder, '.csv'));

    % Stick the data into a CSV file in the data folder..
    c = CSVFile(dataFile, true);
    c = c.addColumn('Image type', 'd');
    c = c.setColumnData('Image type', imageShow');    
    c = c.addColumn('Percent morphing', 'd');
    c = c.setColumnData('Percent morphing', morphPercentUsed');    
    for i = 1:nBlocks
		cName = sprintf('Response %d', i);
		c = c.addColumn(cName, 'd');
		c = c.setColumnData(cName, responseData(:,i));
    end
    c.write;
    
    % Save the image names used in the experiment
    dataFileImage = sprintf('%s/%s-%d.mat', dataFolder, params.experimentName, GetNextDataFileNumber(dataFolder, '.mat'));
    save(dataFileImage,'imageNameTrialSeed','imageNameTrialSupp');
    
    % Save Quest data
    if params.staircase
        dataFileQuest = sprintf('%s/%s-%d.mat', dataFolder, params.experimentName, GetNextDataFileNumber(dataFolder, '.csv'));
        save(dataFileQuest,'QuestDataNatural','QuestDataManmade');
    end
    
catch e
	ListenChar(0);
	win.close;
	
	if strcmp(e.message, 'abort')
		fprintf('- Experiment aborted, nothing saved.\n');
	else
		rethrow(e);
	end
end
