function [] = run_NNMF(intputTag, testSet, monoMode)

if ~exist('inputTag', 'var') || isempty(intputTag), inputTag = 'clean_cg03'; end
if ~exist('testSet', 'var') || isempty(testSet), testSet = 'train\subtrain'; end
if ~exist('monoMode', 'var') || isempty(monoMode), monoMode = 0; end

% Read a wav file grom the base path
basePath = 'D:\Temp\explains';
[files,paths] = findFiles(fullfile(basePath,'inputs', inputTag, testSet), '.wav', 1);

for i=1:length(paths)
    [x fs] = wavread(paths{i});
    if (monoMode == 0)
        x = x(:,1);
    else
        x = mean(x, 2);
    end 
    
    % Generate a narrow band test signal
    x_e = resample(x,8000,fs);
    x_e = resample(x_e,fs,8000);
    if(length(x_e)~=length(x))
        len = min(length(x_e),length(x));
        x_e = x_e(1:len,:);
        x = x(1:len,:);
    end
    
    % STFT process for the original wav signal to make a complex Fourier
    % spectra(S)
    S_w = stft(x, 512, 512, 0, 16000);
    S_n = stft(x_e, 512, 512, 0, 16000);
    
    % Separate the spectra into a magnitude part(V) and a phase part(Phi)
    V_w = abs(S_w);
    Phi_w = imag(S_w);
    V_n = abs(S_n);
    Phi_n = imag(S_n);
        
    % Generate filter matrices Z_e and Z_h
    M = length(V_w);
    N = size(V_w,2);
    K = round(M/3);
   
    Z_h = [zeros(K, N);ones(M-K, N)];
    Z_e = [ones(K, N);zeros(M-K, N)];
    V_hw = exp(idct(dct(log(V_w)).*Z_h));
    V_ew = exp(idct(dct(log(V_w)).*Z_e));
    V_hn = exp(idct(dct(log(V_n)).*Z_h));
    V_en = exp(idct(dct(log(V_n)).*Z_e));
    
    L = round(size(V_w,1)/2);
    Z_n = [[eye(L) zeros(L,M-L)]; zeros(M-L,M)];
    Z_w = [zeros(L,M);[zeros(M-L,L) eye(M-L)]];
    
    V_Zw_Vew = Z_w*V_ew;
    V_Ze_Ven = Z_n*V_en;
    V_Zw_Vhw = Z_w*V_hw;
    V_Zn_Vhn = Z_n*V_hn;
    
    if ~exist('V_eTot', 'var')
        V_eTot = V_Zw_Vew+V_Ze_Ven;
        V_hTot = V_Zw_Vhw+V_Zn_Vhn;
    else
        tic;
%         V_eExst = zeros(size(V_eTot,1),size(V_eTot,2));
%         V_hExst = zeros(size(V_hTot,1),size(V_hTot,2));
        V_eExst = V_eTot;
        V_hExst = V_hTot;
%         V_eTot = zeros(size(V_Ze_Ven,1),size(V_Ze_Ven,2)+size(V_eExst,2));
%         V_hTot = zeros(size(V_Zn_Vhn,1),size(V_Zn_Vhn,2)+size(V_hExst,2));
        V_eTot = [V_eExst,V_Zw_Vew+V_Ze_Ven];
        V_hTot = [V_hExst,V_Zw_Vhw+V_Zn_Vhn];
        i
        toc
    end
        
%     subplot(2,3,1);
%     imagesc(20*log10(V_Zw_Vew));
%     colorbar;
%     subplot(2,3,2);
%     imagesc(20*log10(V_Ze_Ven));
%     colorbar;
%     subplot(2,3,3);
%     imagesc(20*log10(V_eTot));
%     colorbar;
%     subplot(2,3,4);
%     imagesc(20*log10(V_Zw_Vhw));
%     colorbar;
%     subplot(2,3,5);
%     imagesc(20*log10(V_Zn_Vhn));
%     colorbar;
%     subplot(2,3,6);
%     imagesc(20*log10(V_hTot));
%     colorbar;
    
%     [W_e,H_e] = nmf_kl_con(V_eTot, 46);
end

save('D:\Temp\NNMF_speech\subtrain.mat','V_eTot','V_hTot');

a = 1;