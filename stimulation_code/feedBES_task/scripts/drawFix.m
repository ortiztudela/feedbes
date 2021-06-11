function drawFix(w,rect,colorOval,colorCross)
%% Draws a fixation point as in:
%
%    Thaler, L., Schütz, A. C., Goodale, M. A., & % Gegenfurtner, K. R. (2013).
%    What is the best fixation target? The effect of target shape on stability ...
%    of fixational eye movements. Vision Research, 76, 31-42.
%
% Takes in: window pointer, rect of the window, desired color for the
% circle, and desired color of the cross (0 for transparent cross)
% Javier Ortiz-Tudela modifies this on Dec 2018 to enable a transparent
% cross.

%% Parameters of the point

width = 39;  % horizontal dimension of display (cm)
dist = 60; % viewing distance (cm)
dInner = 0.2; % diameter of inner circle (degrees); it is also the cross width
if colorCross==0
    dOutter = 1.5-dInner; % diameter of outer circle (degrees); Javi takes out the width of the cross
else
    dOutter = 1.5; % diameter of outer circle (degrees);
end
ppd = pi * (rect(3)-rect(1)) / atan(width/ dist/2) /360; % pixel per degree
[centX, centY] = RectCenter(rect);
pixCross= dInner*ppd/2; % pixels in the cross from the center

%% Actually draw the point
if colorCross ~= 0
    % Original script provided in the paper. Valid for solid crosses
    Screen('FillOval', w, colorOval, [centX-dOutter/2*ppd, centY-dOutter/2*ppd, centX+dOutter/2*ppd, centY+dOutter/2*ppd], dOutter*ppd);
    Screen('DrawLine', w, colorCross, centX-dOutter/2*ppd, centY,centX+dOutter/2*ppd, centY, dInner*ppd);
    Screen('DrawLine', w, colorCross, centX, centY-dOutter/2*ppd,centX, centY+dOutter/2*ppd, dInner*ppd);
    Screen('FillOval', w, colorOval, [centX-dInner/2*ppd, centY-dInner/2*ppd, centX+dInner/2*ppd, centY+dInner/2*ppd], dInner*ppd);
else
    % Javi's change. Draws four 1/4 circles slightly displaced form the center
    % to create the transparent cross.
    cx=centX+pixCross;cy=centY-pixCross;
    Screen('FillArc',w,colorOval,[cx-dOutter/2 *ppd, cy-dOutter/2*ppd, cx+dOutter/2*ppd, cy+dOutter/2*ppd],1,90)
    cx=centX+pixCross;cy=centY+pixCross;
    Screen('FillArc',w,colorOval,[cx-dOutter/2 *ppd, cy-dOutter/2*ppd, cx+dOutter/2*ppd, cy+dOutter/2*ppd],90,90)
    cx=centX-pixCross;cy=centY+pixCross;
    Screen('FillArc',w,colorOval,[cx-dOutter/2 *ppd, cy-dOutter/2*ppd, cx+dOutter/2*ppd, cy+dOutter/2*ppd],180,90)
    cx=centX-pixCross;cy=centY-pixCross;
    Screen('FillArc',w,colorOval,[cx-dOutter/2 *ppd, cy-dOutter/2*ppd, cx+dOutter/2*ppd, cy+dOutter/2*ppd],270,90)
    
    % Draw inner circle
    Screen('FillOval', w, colorOval, [centX-dInner/2*ppd, centY-dInner/2*ppd, ...
        centX+dInner/2*ppd, centY+dInner/2*ppd], dInner*ppd);
end
end