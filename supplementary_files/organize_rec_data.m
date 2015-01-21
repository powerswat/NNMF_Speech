% This script is used to create a dataset of aligned versions of studio
% recordings and re-recordings on devices in real-world environments.
% The input to the script is a device recording of a long file of 
% concatenated speech and associated metadata (created by concat_data.m).
% The script segments this data into files that correspond to individual 
% scripts of individual speakers, aligns them with the original clean 
% versions, normalizes them, and saves them as wave files.
%
% Gautham J. Mysore

clear 

%% PARAMETERS

% Type of recording -
% This should include the name of the device and room. There should be an
% existing concatenated wave file with this name. A folder with this name
% will be created and the new wave files will end with this name.
rec_type = 'ipad_office1'; 

% These parameters should be consistent with the concat_data script
prepend_zeros = 30; % number seconds of zeros with which the clean concatenated data was prepended
between_zeros = 5; % number of seconds of zeros to insert between the files

%% ALIGNMENT

% read the device recording of the concatenated data 
[noisy,fs1,nbits1] = wavread(strcat(rec_type,'.wav'));

% read the clean version of the first script read by the first speaker
% (this is used for an initial alignment)
[clean,fs2,nbits2] = wavread('f1_script1_clean.wav');

% load the metadata of the concatenated studio recording
load cat_metadata_full

% make sure that the sample rates match
if (fs1~=fs2)
  display('Sample rate mismatch')
  break
end

% Trim off the early part of the noisy signal (the part that was prepended
% with zeros), and choose 90 seconds of data after that
noisy_clip = noisy(prepend_zeros*fs1:(prepend_zeros+90)*fs1);

% consider the first 30 seconds of the clean clip
clean_clip = clean(1:30*fs1);

% Perform FFT based correlation. The goal here is to find the clean clip
% within the noisy clip. This will give us the required offset.
display('Initial Alignment')
max_index = fftcorr(clean_clip,noisy_clip);

% aligned start and end samples of the noisy clip
start_sample = ((prepend_zeros-between_zeros)*fs1) + max_index - length(clean_clip) + 1;
end_sample = start_sample+data_length-((prepend_zeros-between_zeros)*fs1)-1;

% This is the entire noisy clip and the early part of it should be aligned
% to the concatenated studio recording (after the first prepend_zeros-between_zeros 
% seconds are trimmed off of it). This will give us our initial alignement. 
noisy_aligned = noisy(start_sample:end_sample);

%% EXTRACT THE DEVICE RECORDING INTO INDIVIDUAL FILES

% We exctract each individual file (keeping the part that corresponds to
% zeros on either side of each file), align it to the corresponding clean
% file, and save it as a .wav file. If we were sure of having no clock 
% drift/latency drift, then we would need no further alginment after what
% was done above. However, there can be some amount of drift in such a long
% recording, so we perform a file level alignment over here.

mkdir(rec_type) % create a folder for the given data type
end_samp = between_zeros*fs1; % intialization

for n = 1:length(cat_metadata)
  
  display(strcat('Aligning:', cat_metadata(n).name))
  
  start_samp = end_samp - (between_zeros*fs1) + 1; % start from the buffer of recorded silence before the clip of interest
  end_samp = start_samp + cat_metadata(n).samples + (2*between_zeros*fs1) - 1; % end at the buffer of recorded silence at the end of the clip of interest
  wav_file_name = strcat(rec_type,'/',cat_metadata(n).name,'_',rec_type,'.wav'); % name of the file to store
  noisy_clip = noisy_aligned(start_samp:end_samp); % the current extracted clip
  clean_clip = wavread(strcat('clean/',cat_metadata(n).name,'_clean.wav')); % the corresponding clean clip

  % Align the exctracted noisy clip with the buffers on either side to the
  % corresponding clean clip using FFT based correlation. The goal here is
  % to find the clean clip within the noisy clip. This will give us the 
  % required offset.
  max_index = fftcorr(clean_clip,noisy_clip);
  
  % aligned start and end samples of the noisy clip
  start_sample = max_index-length(clean_clip)+1;
  end_sample = max_index;
 
  clip = noisy_clip(start_sample:end_sample);
  clip = clip/(max(abs(clip))*1.01); % normalize
  wavwrite(clip,fs1,nbits1,wav_file_name) % store the aligned and normalized deveice recording
end


















