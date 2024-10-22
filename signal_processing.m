%%
clc
close all
clear
%% Load cases
[files, path_cases] = uigetfile("MultiSelect","on");

if ~iscell(files)
    files = {files};
end

%% Create Struct

% Configuration parameters
rpm =  cell(1, length(files));
propeller = cell(1, length(files));
Uo = cell(1, length(files));

% Store frequency and time data
fields_freq = cell(length(files),1);
fields_time = cell(length(files),1);
fieldnames = cell(length(files),1);
for i=1:length(files)
    [~, nameCase, ~] = fileparts(fullfile(path_cases, files{i}));
    file = dir(fullfile(path_cases, nameCase, 'CBF', strcat(['Spectrum*', nameCase, '.mat'])));
    
    fields_freq{i} = load(fullfile(path_cases, nameCase, 'CBF', file(1).name));
    fields_time{i} = load(fullfile(path_cases, files{i}));
    name = strrep(nameCase, ' ', '_');
    name = strrep(name, '.', '_');
    fieldnames{i} = strcat(['H_',name]);
    
    name_split = split(nameCase, '_');
    rpm{i} = name_split{2};
    if any(strfind(nameCase, 'V'))
        value = split(nameCase, 'V');
        U0{i} = strcat([value{end}, ' m/s']);
    else
        U0{i} = '0 m/s';
    end
    propeller{i} = name_split{1};
end

data_freq = cell2struct(fields_freq, fieldnames, 1);
data_time = cell2struct(fields_time, fieldnames, 1);

%% plot spectrum


labels = cellfun(@(x, y, z) strcat([x, ' - ', y, ' - ', z]), rpm, U0, propeller,  'UniformOutput', false);
g =cell(1, length(files));
for i=1:length(files)
    if i == 2
        hold on
    end
    run = getfield(data_freq, fieldnames{i});
    g{i} = semilogx(run.frequency, run.Spectrum, 'LineWidth',1.5, 'DisplayName',labels{i});
end

hold off

xlabel('f [Hz]')
ylabel('SPL [dB]')
xlim([10, 10000])
grid on
lgd = legend;

set(lgd, 'ItemHitFcn', @(src, event) legendToggle(src, event, g));

function legendToggle(src, event, g)
    % Get clicked item index
    idx = event.Peer.SeriesIndex;
    
    % Change visibility
    if strcmp(g{idx}.Visible, 'on')
        g{idx}.Visible = 'off';  
    else
        g{idx}.Visible = 'on';
    end
end


%% plot time

% % reconstruct time vector
% t0 = data_time.run0000.Signal_00.x_values.start_value;
% increment = data_time.run0000.Signal_00.x_values.increment;
% number_of_values = data_time.run0000.Signal_00.x_values.number_of_values;
% 
% t = t0:increment:increment*number_of_values;
% 
% 
% for i=1:length(files)
% 
%     % eval(strcat(['signal_', fieldnames{i}, '(:,1)= t;']));
%     eval(strcat(['signal_', fieldnames{i}, '= data_time.', fieldnames{i},'.Signal_00.y_values.values;']));
% 
% 
%     % t0 = data_time.run0000.Signal_00.x_values.start_value;
%     % deltaT = data_time.run0000.Signal_00.x_values.increment;
%     % tf = deltaT*data_time.run0000.Signal_00.x_values.number_of_values;
%     % 
%     % time_vector = t0:deltaT:tf;
%     % signal = data_time.run0000.Signal_00.y_values.values;
% 
% end