%-------------------------------------------------------------------------%
% Function: Import PPG100C MRI data to MATLAB
% qritten by: Rémi Dagenais
% Date: 2022-01-16
% INPUT -> filename = raw_data_file
% OUTPUT -> ppg.field = .rawData
% ppg.Fields->    
%     time
%     pulse
%     der
% DESCRIPTION -> Process the Biopac PPG100C MRI data into a structure.
%-------------------------------------------------------------------------%

function [ppg] = read_PPG(filename)

if (exist(filename,'file') == 2)
    fid = fopen(filename,'r');
    tline = 0;
    q = 0;
    while tline~=-1
        q = q+1;
        tline = fgetl(fid);
        if (tline ~= -1)
            c = strsplit(tline,'\t');
        end
        if (length(c)>1) && (q > 9) %skip header (9 lines)
            ppg.time(q-9) = str2double(c(1));
            ppg.pulse(q-9) = str2double(c(2));
        end
    end
    ppg.time = ppg.time'*60;
    ppg.pulse = ppg.pulse';
    ppg.der = diff(ppg.pulse);
    ppg.time = ppg.time(1:end-1);
    ppg.pulse = ppg.pulse(1:end-1);
    
    fprintf('The file %s was extracted properly into a sructure.\n',filename);
else
    fprintf('The file %s was not found in the directory. Make sure to enter .txt at the end of the file. \n',filename);
end
end