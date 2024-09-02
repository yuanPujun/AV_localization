function [hrtf1, hrtf2, hrtf3, hrtf4, hrtf5] = MakeHRTFs(desiredAz)
% Make HTRFs in desiredAz (len=5) left-minus right-positive
% Elevations = 0
% 500 ms AudioFile 24000 data points
% SamplesPerFrame = 24000, one time read the whole AudioFile

load 'ReferenceHRTF.mat' hrtfData sourcePosition
hrtfData = permute(double(hrtfData),[2,3,1]);
sourcePosition = sourcePosition(:,[1,2]);

fileReader = dsp.AudioFileReader('white_noise_500ms.wav','SamplesPerFrame',24000);

for i = 1:length(desiredAz)

    varName = ['hrtf' num2str(i)];

    desiredPosition = [-desiredAz(i) 0];  % minus for default HRTFData

    interpolatedIR  = interpolateHRTF(hrtfData,sourcePosition,desiredPosition, ...
                                      "Algorithm","VBAP");

    leftIR = squeeze(interpolatedIR(:,1,:))';
    rightIR = squeeze(interpolatedIR(:,2,:))';

    leftFilter = dsp.FIRFilter('Numerator',leftIR);
    rightFilter = dsp.FIRFilter('Numerator',rightIR);

    left = [];
    right = [];

    while ~isDone(fileReader)

        audioIn = fileReader();
    
        leftChannel = leftFilter(audioIn(:,1));
        rightChannel = rightFilter(audioIn(:,2));
    
        left = [left; leftChannel];
        right = [right; rightChannel];

    end

    eval([varName ' = [left right];']);
    release(fileReader)

end

end