function morphedScene = sceneMorphingAmplitude(scene1,scene2,percentMorph)
% This routine create a morph scene from 2 input scenes with percent of
% morph representing the distance from the second scene. The morphing is
% done on the amplitude spectrum of the two images and keep the phase of
% closest image or take average phase if percentMorph = 0.5.
%
% Input: 
%    scene1,scene2: two grayscale images to be morphed 
%    percentMorph: the distance of morphed image to the first one
% Output:
%    morphedScene: the morphed scene image
%
% Take the Fourier transform of the input images
fftScene1 = fft2(scene1);
fftScene1Amplitude = abs(fftScene1);
fftScene1Phase = angle(fftScene1);

fftScene2 = fft2(scene2);
fftScene2Amplitude = abs(fftScene2);


% Check number of morphed scene
nMorph = length(percentMorph);
morphedScene = NaN(size(scene1,1),size(scene1,2),nMorph);

% Loop through all the morphed values
for ii = 1 : nMorph
    % Take the weighted sum of the FFTs
    fftMorphAmplitude = (1-percentMorph(ii))*fftScene1Amplitude...
                        + percentMorph(ii)*fftScene2Amplitude;

    % Take the inverse FFT of morphed image with the weighted amplitude and
    % the phase preserved
    fftMorphPhase = fftScene1Phase;
    morphedScene(:,:,ii) = abs(ifft2(fftMorphAmplitude.* exp(1i*fftMorphPhase)));
end
morphedScene = uint8(morphedScene);