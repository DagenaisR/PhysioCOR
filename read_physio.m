%-------------------------------------------------------------------------%
% Function: read_physio
% Written by: Rémi Dagenais
% Date: 2022-02-24
% INPUT -> PMU filename (without extension)
% OUTPUT -> physio.
%                  ecg.
%                      time
%                      channelI
%                      channelII
%                      channelIII
%                      channelIV
%                  resp.
%                       time
%                       signal
%                       idxPeak
%                  puls.
%                       time
%                       signal
%                       idxPeak
%                  ext.
%                      time
%                      trigger
% DESCRIPTION -> Extract the physiological recordings from the Siemens PMU
% log files into a MATLAB structure. Can also use the structure to generate
% a .txt file.
% Modifications:
%-------------------------------------------------------------------------%
function [out] = read_physio(varargin)

direc = pwd;

if nargin ==1 %Open all files containing the filename
    files = dir(fullfile(direc,[varargin{1} '.*']));
    
    if isempty(files)
        out.output = sprintf('The files were not found in the PWD.\n');
    end
    
    count=1;
    for q = 1:numel(files)
        ext{q} = files(q).name(numel(varargin{1})+2:end);
        fid = fopen(files(q).name,'r');
        
        switch ext{q}
            
            case 'ecg'
                tline = 0;
                w = 1;
                while tline ~= -1
                    tline = fgetl(fid);
                    dummy.lines{w} = tline; w = w+1;
                end
                
                idx_s = strfind(dummy.lines{1},'6002'); idx_s = idx_s(end)+5;
                idx_e = strfind(dummy.lines{1},'5003'); idx_e = idx_e(end)-2;
                data = dummy.lines{1}(idx_s:idx_e);
                ecg = str2double(strsplit(data,' ')); ecg = ecg';
                fclose(fid)
                
                out.ecg.channelI   = ecg(1:4:end-3)-2048;
                out.ecg.channelII  = ecg(2:4:end-2)-10240;
                out.ecg.channelIII = ecg(3:4:end-1)-18432;
                out.ecg.channelIV  = ecg(4:4:end)-26624;
                out.ecg.time = linspace(0,numel(out.ecg.channelI)/400,numel(out.ecg.channelI))'; 

                
                info{count,1} = 'ecg';
                time{count,1} = out.ecg.time;
                sig{count,1} = out.ecg.channelI;
                sig{count,2} = out.ecg.channelII;
                sig{count,3} = out.ecg.channelIII;
                sig{count,4} = out.ecg.channelIV;
                marker{count,1} = zeros(numel(time{count}),1);
                
                count = count+1; %update
                
            case 'ext'
                clear idx_s idx_e data idx_peaks idxPeak signal
                
                tline = 0;
                w = 1;
                while tline ~= -1
                    tline = fgetl(fid);
                    dummy.lines{w} = tline; w = w+1;
                end
                
                idx_s = strfind(dummy.lines{1},'280'); idx_s = idx_s(end)+4;
                idx_e = strfind(dummy.lines{1},'5003'); idx_e = idx_e(end)-2;
                data = dummy.lines{1}(idx_s:idx_e);
                trigger = str2double(strsplit(data,' ')); trigger = trigger';
                fclose(fid);
                
                trigger(trigger == 6000) = [];
                %Extract trigger signal (5000)
                idx_trigger = find(trigger == 5000);
                
                out.ext.time   = idx_trigger/400;
                out.ext.trigger = ones(numel(idx_trigger),1)*5000;
                out.ext.signal = trigger;
                
                info{count,1} = 'ext';
                time{count,1} = linspace(0,out.ext.time(end),out.ext.time(end)*400);
                sig{count,1} = zeros(numel(time{count}),1); sig{count}(idx_trigger) = 5000;
                marker{count,1} = idx_trigger;
                
                count = count+1; %update
            case 'ext2'
                
            case 'puls'
                clear idx_s idx_e data idx_peaks idxPeak signal
                
                tline = 0;
                w = 1;
                while tline ~= -1
                    tline = fgetl(fid);
                    dummy.lines{w} = tline; w = w+1;
                end
                
                idx_s = strfind(dummy.lines{1},'6002'); idx_s = idx_s(end)+5;
                idx_e = strfind(dummy.lines{1},'5003'); idx_e = idx_e(end)-2;
                data = dummy.lines{1}(idx_s:idx_e);
                puls = str2double(strsplit(data,' ')); puls = puls';
                fclose(fid);
                
                %Extract peaks signal (5000)
                idx_peaks = find(puls == 5000);
                for q = 1:numel(idx_peaks)
                    if idx_peaks(q) > 101
                        idxPeak = find(max(puls(idx_peaks(q)-100:idx_peaks(q)-2)) == puls(idx_peaks(q)-100:idx_peaks(q)-2));
                        idxPeakPulse(q) = idx_peaks(q)+idxPeak(1)-100; clear idxPeak;
                    else
                        idxPeak = find(max(puls(1:idx_peaks(q)-2)) == puls(1:idx_peaks(q)-2));
                        idxPeakPulse(q) = idx_peaks(q)+idxPeak(1); clear idxPeak;
                    end
                end
                signal = puls; signal(idx_peaks) = [];
                timePulse = linspace(0,numel(signal)/400,numel(signal));
                
                out.puls.time   = timePulse';
                out.puls.signal = signal;
                out.puls.idxPeaks = idxPeakPulse-[1:1:numel(idx_peaks)];
                
                info{count,1} = 'puls';
                time{count,1} = out.puls.time;
                sig{count,1} = out.puls.signal;
                marker{count,1} = out.puls.idxPeaks;
                
                count = count+1; %update
                
            case 'resp'
                clear idx_s idx_e data idx_peaks idxPeak signal
                tline = 0;
                w = 1;
                while tline ~= -1
                    tline = fgetl(fid);
                    dummy.lines{w} = tline; w = w+1;
                end
                
                idx_s = strfind(dummy.lines{1},'6002'); idx_s = idx_s(end)+5;
                idx_e = strfind(dummy.lines{1},'5003'); idx_e = idx_e(end)-2;
                data = dummy.lines{1}(idx_s:idx_e);
                resp = str2double(strsplit(data,' ')); resp = resp';
                fclose(fid);
                
                 %Extract peaks signal (5000)
                idx_peaks = find(resp == 5000);
                for q = 1:numel(idx_peaks)
                    if idx_peaks(q) > 101
                        idxPeak = find(max(resp(idx_peaks(q)-100:idx_peaks(q)-2)) == resp(idx_peaks(q)-100:idx_peaks(q)-2));
                        idxPeakResp(q) = idx_peaks(q)+idxPeak(1)-100; clear idxPeak;
                    else
                        idxPeak = find(max(resp(1:idx_peaks(q)-2)) == resp(1:idx_peaks(q)-2));
                        idxPeakResp(q) = idx_peaks(q)+idxPeak(1); clear idxPeak;
                    end
                end
                signal = resp; signal(idx_peaks) = [];
                timeResp = linspace(0,numel(signal)/400,numel(signal));
                
                out.resp.time   = timeResp';
                out.resp.signal = signal;
                out.resp.idxPeaks = idxPeakResp-[1:1:numel(idx_peaks)];
                
                info{count,1} = 'resp';
                time{count,1} = out.resp.time;
                sig{count,1} = out.resp.signal;
                marker{count,1} = out.resp.idxPeaks;
                
                count = count+1; %update
                
            case 'pmu'
               
        end

    end
    

    
elseif nargin > 1
    out.output = sprintf('Only enter the based filename without extension.\n');
else
    
end

% output a single txt file
size_l = max(cellfun('size',time,1));
t = linspace(0,size_l/400,size_l)';
Z = zeros(numel(t),1);
for q = 1:numel(info)
    for w = 1:numel(sig(q,:))
        sig_1{q,w} = Z;
        sig_1{q,w}(1:numel(sig{q,w}),1) =  sig{q,w};
    end
end

out_name = strsplit(files(1).name,'.');
txt_name = [out_name{1} '.txt'];
txt_info = ['Time (s)' string(info)'];
txt_array = [t cell2mat(sig_1')];

fid = fopen(txt_name,'w');
fprintf(fid,'%s\t',txt_info);
fprintf(fid,'\n');
for q = 1:size(txt_array,1)
    fprintf(fid,'%d\t',txt_array(q,:));
    fprintf(fid,'\n');
end
fclose(fid);

end