% Audiovisual Localization Task
% Response Type: Mouse Click
% 2 visual precision * 5*5 AV locations, repeat 1 time
% 50 trials in total
% First created by Pujun Yuan
% 2024-09-02
% Edition times: 1

%% Clear the workspace and the screen
clear;clc;sca;

%% Setup

% Open Window and Get Parameters
PsychDefaultSetup(2)
Screen('Preference','SkipSyncTests',1);
screens = Screen('Screens');
screenNumber = max(screens);
[window,windowRect] = Screen('OpenWindow',screenNumber,0,[0,0,800,450]);
[screenXpixels,screenYpixels] = Screen('WindowSize',window);
[xCenter,yCenter] = RectCenter(windowRect);
ifi = Screen('GetFlipInterval',window);

Screen('TextSize', window, 20);

% Enable altialiasing
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% KeyPress
KbName('UnifyKeyNames');
k1 = KbName('1!');
k2 = KbName('2@');
k3 = KbName('3#');
k4 = KbName('4$');
k5 = KbName('5%');
kEsc = KbName('escape');
kSpace = KbName('space');

% === Screen parameters === %
inch = 27;  % screen size
dist = 26;  % viewsing distance
ratio = 9/16;  % highth:width ratio

% === Visual Stimulus parameters settings === %
dotstdX = [2,14];  % two levels of std along x axis
dotstdY = 2.5;
dotsize = 0.43;
azimuth = [-10,-5,0,5,10];
dotstdX_pix = deg2pix(dotstdX,inch,screenXpixels,dist,ratio);
dotstdY_pix = deg2pix(dotstdY,inch,screenXpixels,dist,ratio);
dotsize_pix = deg2pix(dotsize,inch,screenXpixels,dist,ratio);
locations = xCenter + deg2pix(azimuth,inch,screenXpixels,dist,ratio);
dura = 0.5;       

baseRect = [0 0 dotsize_pix screenYpixels];

% === Auditory Stimulus parameters settings === %

[hrtf1, hrtf2, hrtf3, hrtf4, hrtf5] = MakeHRTFs(azimuth);

InitializePsychSound;
dev = PsychPortAudio('GetDevices');
freq = 48000;

pahandles = zeros(1, 5);
hrtf = {hrtf1, hrtf2, hrtf3, hrtf4, hrtf5};

for i = 1:5
    pahandles(i) = PsychPortAudio('Open', [], 1, 1, freq, 2);
    PsychPortAudio('FillBuffer', pahandles(i), hrtf{i}');
end

% === Generate Trials === %
trials = genTrials(1,[2,5,5]);  % 2 visual precision; 5*5 AV locations
ntrials = size(trials,1);

% Set Functions
drawfix = @()DrawFixAt(window,xCenter,yCenter);
flip = @()Screen('Flip',window);
flipAfter = @(t)Screen('Flip',window,t-ifi/2);
drawdots = @(x,y,stdx)DrawDotsAt(window,x,y,stdx,dotstdY_pix,dotsize_pix);
startaudio = @(pahandle,t)PsychPortAudio('Start', pahandle, 1, t-ifi/2, 1);

% Main Output Tables
out_av = table('Size',[ntrials 6], ...
    'VariableTypes',{'double','double','double','double','double','double'}, ...
    'VariableNames',{'vStd','vPosition','aPosition','Response','RT','Disper'});

%% PsychPortAudio Warm-Up

silence = zeros(2, freq);
psilence = PsychPortAudio('Open', [], 1, 1, freq, 2);
PsychPortAudio('FillBuffer', psilence, silence);
PsychPortAudio('Start', psilence, 1, 0, 1);
PsychPortAudio('Stop', psilence, 1, 1);

%% Main Experiment

for i = 1:ntrials

    vStd = trials(i,1);
    vPostion = trials(i,2);
    aPosition = trials(i,3);
    rt = nan;
    resp = nan;

    drawfix()
    vbl = flip();
    
    dispersion = drawdots(locations(vPostion),yCenter,dotstdX_pix(vStd));
    start = startaudio(pahandles(aPosition), vbl+1);
    vbl = flipAfter(vbl+1);
    
    vbl = flipAfter(vbl+dura);
     
    % set Mouse position
    SetMouse(xCenter ,yCenter, window);
    
    % Wait for subject respond
    x0 = xCenter;
    y0 = yCenter;
    centeredRect = CenterRectOnPoint(baseRect, x0, y0);
    Screen('FillRect', window, [0 0 255], centeredRect);
    vbl = Screen('Flip', window);
    
    while 1
        
        [x, y, buttons] = GetMouse;
        
        if buttons(1) == 1
            centeredRect = CenterRectOnPoint(baseRect, x, yCenter);
            Screen('FillRect', window, [0 0 255], centeredRect);
            vbl = Screen('Flip', window);
        end
        
        [keyIsDown, t, KeyCode] = KbCheck;
        if keyIsDown && KeyCode(kSpace)
            rt = t - start;
            resp = x;
            break
        elseif keyIsDown && KeyCode(kEsc)
            sca;
            PsychPortAudio('Close')
            error 'Experiment Terminated'
        end
        
    end
    
    vbl = flip();
    
    vbl = flipAfter(vbl+1);
    
    row = {dotstdX(vStd),azimuth(vPostion),azimuth(aPosition),resp,rt,dispersion};
    out_av(i,:) = row;

end

% Save Data

if ~exist('mc_data', 'dir')
    mkdir("mc_data")
end

save('./mc_data/test', 'out_av');

% Clear the screen.
PsychPortAudio('Close');
sca;  
