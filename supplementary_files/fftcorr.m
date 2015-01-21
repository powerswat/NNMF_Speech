function max_index = fftcorr(clean_clip,noisy_clip)

% This function is used to perform FFT based correlation to find the
% location of a clean clip within a noisy clip. The output is the index
% within the noisy clip that corresponds to the end of the clean clip. 
%
% function max_index = fftcorr(clean_clip,noisy_clip)

tic
conv_length = length(clean_clip)+length(noisy_clip)-1; % both signals should be zero padded to this length
zpad_clean_clip = [flip(clean_clip);zeros(conv_length-length(clean_clip),1)]; % flip and zero pad the clean signal
zpad_noisy_clip = [noisy_clip;zeros(conv_length-length(noisy_clip),1)];% zero pad the noisy signal 
fclean_clip = fft(zpad_clean_clip);
fnoisy_clip = fft(zpad_noisy_clip);
fcorr_vec = fnoisy_clip.*fclean_clip; % multiply the spectra
corr_vec = ifft(fcorr_vec);
[~,max_index] = max(corr_vec);
toc