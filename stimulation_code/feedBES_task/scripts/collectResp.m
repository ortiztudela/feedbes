function [resp,rt]=collectResp(duration,respKeys)
%% Collect keyboard responses for duration
% ----------------------------------------------------------
%
% Javier Ortiz-Tudela
% ortiztudela@psych.uni-frankfurt.com
% LISCO Lab - Goethe University
% ----------------------------------------------------------
%
% Collects a keyboard press and outputs
% 0 if no response is made or the corresponding predefine keycode.
% Closes all if ESC is pressed
% Takes duration in seconds as the response deadline and respkeys as an
% array with the allowed keycodes
%
%% Initialize

% Get current ESC keyCode
KbName('UnifyKeyNames')
escCode=KbName('Escape');

% If infinite time
if duration==-1
    duration=10000;
end

%% Collect keyboard presses
resp=0;
rt=NaN;
t1=GetSecs; t2=GetSecs;
while t2 < (t1+duration)
    t2=GetSecs;
    [keyIsDown, timeSecs, keyCode] = KbCheck;
    if keyIsDown
        rt=timeSecs-t1;
        if keyCode(escCode)==1
            Screen('CloseAll');
            error('Aborted by user')
        end
        for i=1:length(respKeys)
            if keyCode(respKeys(i))==1
                resp=respKeys(i);
                break
            end
        end
    end

    % Break loop if an allowed response was made
    if resp~=0
        break
    end
end
end
