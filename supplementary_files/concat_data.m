% This script is used to create a dataset of aligned versions of studio
% recordings and re-recordings on devices in real-world environments.
% The script concatenates the clean studio recordings of multiple scripts 
% of multiple speakers so that the single long wave file that is created 
% can be played through a loudspeaker in order to obtain device recordings.
%
% Gautham J. Mysore

clear

%% Parameters
data_type = 'clean'; % concatenate the data in this folder
prepend_zeros = 30; % number seconds of zeros to prepend the data with (this would give you time to leave the recording setup after the recording starts)
between_zeros = 5; % number of seconds of zeros to insert between the files (this provides a buffer that can be helpful with the later alignment)
num_speakers = 10; % concatenate the data of this many speakers (of both genders)
num_scripts = 5; % concatenate this many scripts per speaker

%% Concatenate

% go to appropriate directory
eval(['cd ' data_type])

% initializations
fs = 44100;
cat_data = zeros(prepend_zeros*fs,1); % initialize the concatenated data array with zeros
zeros_insert = zeros(between_zeros*fs,1); % zeros to insert between the files
cat_metadata = struct('name',{},'samples',{}); % store the file names and lengths in samples here
samples = []; % store the number of samples per file here
genders = ['f','m'];
count = 0;

% concatenate the data and store the metadata
for g = 1:2
  for m = 1:num_speakers
    for n = 1:num_scripts
      file_prefix = strcat(genders(g),num2str(m),'_script',num2str(n)); % construct the name of the speaker and script
      current_file = strcat(file_prefix,'_',data_type,'.wav'); % construct the appropriate file name
      [x,fs,nbits] = wavread(current_file);
      cat_data = [cat_data;zeros_insert;x]; % concatenate the current data
      count = count+1;
      cat_metadata(count).name = file_prefix;
      cat_metadata(count).samples = length(x);
    end
  end
end

% save the data and metadata
cd ..
wavwrite(cat_data,fs,nbits, 'cat_data_full.wav')
data_length = length(cat_data);
save('cat_metadata_full.mat','cat_metadata','data_length')