%-------------------------------------------------------------------------%
% Function: Import Caretaker III Data into MATLAB
% Written by: Rémi Dagenais
% Date: 2021-10-10
% INPUT -> varargin{1} = raw_data_file
%          varargin{2} = features_file
% OUTPUT -> caretaker.field = .rawData + .features
% caretaker.Fields -> 
%           time
%           sig 
%           PeakTimePosition
%           TimeStamp
%           TimeMark
%           AveragedPressure
%           InterBeatInterval
%           HeartRate
%           Systole
%           Diastole
%           RSP
%           SPO2
%           MAPNum
%           PeakAmplitude
%           SignalToNoise
%           T01
%           T12
%           T13
%           T01b
%           P2P1Ratio
%           P3P1Ratio
%           P2P11stRatio
%           P2P12ndRatio
%           CalibSystole
%           CalibDiastole
%           NewSNRFactor
%           IntegratedPulseAmplitude
%           NumberOfRawPeaks
%           TriggerOffset
%           ArterialStiffnessFactor
%           SP02HRT
% DESCRIPTION -> Process the caretaker data into a structure.
%-------------------------------------------------------------------------%

function [caretaker] = read_caretaker(varargin)

if nargin == 1
    filename = varargin{1}

    %Convert extension to .txt
    if strcmp(filename,'.dat') == 1
        based_name = strsplit(filename,'(');
        new_filename = sprintf('%s.txt',based_name{1});
        movefile(filename,new_filename);
    else
        filename = filename;
    end
    % Import  data
    data = readmatrix(filename,'NumHeaderLines',1);
    caretaker.time = data(:,1)./500;
    caretaker.sig = data(:,3);

else if nargin == 2
        filename = varargin{1};
        features = varargin{2};

        % Convert extensions to .txt
        if strcmp(filename,'.dat') == 1
            based_name = strsplit(filename,'(');
            new_filename = sprintf('%s.txt',based_name{1});
            movefile(filename,new_filename);

        else
            filename = filename;
        end

        if strcmp(features,'.dat') == 1
            based_name_2 = strsplit(features,'(');
            new_features = sprintf('%s.txt',based_name_2{1});
            movefile(features,new_features);
        else
            features = features;
        end

        %     Import data
        data = readmatrix(filename,'NumHeaderLines',1);
        caretaker.time = data(:,1)./500;
        caretaker.sig = data(:,3);

        % Import features
        parameters = readmatrix(features,'NumHeaderLines',1);

        % format the structure with valid characters
        fid = fopen(features,'r')
        header = fgetl(fid);
        par = strsplit(header,','); par = strrep(par,' ',''); par = strrep(par,'_','');
        par{1} = 'PeakTimePosition'; par{3} = 'TimeMark'; par{4} = 'AveragedPressure'; par{5} = 'InterBeatInterval';
        par{11} = 'MAPNum'; par{12} = 'PeakAmplitude';
        par{14} = 'T01'; par{15} = 'T12'; par{16} = 'T13'; par{17} = 'T01b';
        par{18} = 'P2P1Ratio'; par{19} = 'P3P1Ratio'; par{20} = 'P2P11stRatio'; par{21} = 'P2P12ndRatio';
        par{22} = 'CalibSystole'; par{23} = 'CalibDiastole'; par{24} = 'NewSNRFactor'; par{26} = 'NumberOfRawPeaks'; par{27} = 'TriggerOffset';
        fclose(fid)

        for i = 1:length(par)
            caretaker.(par{i}) = parameters(:,i);
        end

end



end