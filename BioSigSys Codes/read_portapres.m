%-------------------------------------------------------------------------%
% Function: Read Portapres Data
% Written by: Rémi Dagenais
% Date: 2021-11-21
% INPUT -> Portapres data file containing BP waveform
% OUTPUT -> Data.structure
%           data.time
%           data.BP
% DESCRIPTION -> Extract the blood pressure waveform obtained from the
% Portapres
%-------------------------------------------------------------------------%

function [varargout] = read_portapres(varargin)
count = 0;
for q = 1:nargin
    if contains(varargin{q},'.txt');
        fid = fopen(varargin{q},'r');
        tline = 0;
        w = 0;
        while tline ~= -1
            w = w+1;
            tline = fgetl(fid);
            if tline ~= -1
                c = strsplit(tline,';');
            end
            if w > 2 && length(c) == 2
                time(w-2) = str2double(c(1));
                BP(w-2) = str2double(c(2));
            end
        end
        
        if exist('time','var') == 0
            fprintf("File %i - Not suported.\n",q);
            count = count +1;
        else
            fclose(fid);
            varargout{q}.time = time;
            varargout{q}.BP = BP;
            clear time BP;
        end
    else
        fprintf("File %i - Not suported.\n",q);
        count = count +1;
        
    end
end
if (q-count)>1
    fprintf("%i files extracted successfully.\n",q-count);
else
    fprintf("%i file extracted successfully.\n",q-count);
end
end