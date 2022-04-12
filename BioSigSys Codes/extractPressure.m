%-------------------------------------------------------------------------%
% Function: Find ABP (Sys, Mean, Dia) from BP signal and systolic idx
% Written by: Rémi Dagenais
% Date: 2021-12-03
% INPUT -> BP signal
%       -> time vector
%       -> systolic idx
%       -> window size
%       -> Resampling rate (optional)
% OUTPUT -> Sys.___
%        ->    .time
%        ->    .pres
%        -> Mean.___
%        ->     .time
%        ->     .pres
%        -> Dia.___
%        ->    .time
%              .pres
% DESCRIPTION -> Will output the pressure values along with time points
% Modification:
% 05/01/2021 -> dia_idx is now a int64 variable.
%-------------------------------------------------------------------------%

function [sys,mea,dia] = extractPressure(BP,time,sys_idx,window,varargin)

if size(sys_idx,2)>1
    sys_idx = int64(sys_idx');
else
    sys_idx = int64(sys_idx);
end

% Systole 
sys.pres = BP(sys_idx);
sys.time = time(sys_idx);

% Find diastole from systole
for q = 1:length(sys_idx)
    idx = find(min(BP(sys_idx(q)-window:sys_idx(q))) == BP(sys_idx(q)-window:sys_idx(q))); 
    dia_idx(q) = idx(end);
    clear idx
end

%Idx is an int vector
if size(dia_idx,2)>1
    dia_idx = int64(dia_idx');
else
    dia_idx = int64(dia_idx);
end
dia.time = time(sys_idx-window+dia_idx);
dia.pres = BP(sys_idx-window+dia_idx);


% Compute Mean
mea.time = diff([0 time(sys_idx)'])./2 + [0 time(sys_idx(1:end-1))']; mea.time = mea.time';
mea.pres = (2*dia.pres + sys.pres)./3;

if nargin>4
   [sy,sty] = resample(sys.pres,sys.time,varargin{1},1,1); sys.pres = sy; sys.time = sty;
   [my,mty] = resample(mea.pres,mea.time,varargin{1},1,1); mea.pres = my; mea.time = mty;
   [dy,dty] = resample(dia.pres,dia.time,varargin{1},1,1); dia.pres = dy; dia.time = dty;
end

% figure
hold on
plot(time,BP,'c-');
plot(sys.time,sys.pres,'r-','linewidth',2);
plot(mea.time,mea.pres,'k-','linewidth',2);
plot(dia.time,dia.pres,'b-','linewidth',2);
hold off
xlabel('Time','fontweight','bold'); ylabel('Pressure','fontweight','bold');
legend('PP Waveform','Systole','MAP','Diastole');
end
