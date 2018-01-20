function SceneClassification(subjectID)
% This program tests the agreement of computer vision algorithm and human
% perception in scene classification task

%% Define the parameters in the experiment
params.fixationToTargetLatency = 0.5;
params.targetToMaskLatency = 0.05;
params.imageSize = 350;
params.fpSize = 30;
params.fpColor = [1 1 1];
params.nBlocks = 1;
params.nTrials = 20; % if we use staircase method
params.morphPercent = log(linspace(1,4,10))/log(4);
params.enableFeedback = 1;
params.staircase = 0;

% Key mappings
params.leftKey = {'d' '1'};             % Keys accepted for left/up/absent response
params.rightKey = {'k' '2'};            % Keys accepted for right/down/present response

% Experiment info
if nargin < 1
    subjectID = 'dummy';
end
params.subject = subjectID;            % Name of the subject.
params.experimentName = 'SceneClassification'; % Root name of the experiment and data file.

%% Run the driver program
SceneClassification_Driver(params);