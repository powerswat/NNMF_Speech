function [V_eTot, V_hTot, Phi] = makeVmat(paths, saveFileName, monoMode, dataType)

for i=1:length(paths)
    if(exist(saveFileName,'file'))
        V_eTot = 0;
        V_hTot = 0;
        Phi = 0;
        display('^^^Skipping^^^');
        break;
    end
    
    % Convert the wav file into mono
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
    S_w = stft(x, 512, 512, 128, 16000);
    S_n = stft(x_e, 512, 512, 128, 16000);
    
    % Separate the spectra into a magnitude part(V) and a phase part(Phi)
    V_w = abs(S_w);
    Phi_w = angle(S_w);
    V_n = abs(S_n);
    Phi_n = angle(S_n);
        
    % Generate filter matrices Z_e and Z_h
    M = size(V_w,1);
    N = size(V_w,2);
    K = round(M/3);
   
    Z_h = [zeros(K, N);ones(M-K, N)];
    Z_e = [ones(K, N);zeros(M-K, N)];
    
    V_hw = exp(idct(dct(log(V_w)).*Z_h));
    V_ew = exp(idct(dct(log(V_w)).*Z_e));
    V_hn = exp(idct(dct(log(V_n)).*Z_h));
    V_en = exp(idct(dct(log(V_n)).*Z_e));
    
    if(dataType==1)
        L = round(size(V_w,1)/2);
        Z_n = [[eye(L) zeros(L,M-L)]; zeros(M-L,M)];
        Z_w = [zeros(L,M);[zeros(M-L,L) eye(M-L)]];
    
        V_Zw_Vew = Z_w * V_ew;
        V_Ze_Ven = Z_n * V_en;
        V_Zw_Vhw = Z_w * V_hw;
        V_Zn_Vhn = Z_n * V_hn;
        Phi_w_Zw = Z_w * Phi_w;
        Phi_n_Zn = Z_n * Phi_n;

        if ~exist('V_eTot', 'var')
            V_eTot = V_Zw_Vew + V_Ze_Ven;
            V_hTot = V_Zw_Vhw + V_Zn_Vhn;
            Phi = Phi_w_Zw + Phi_n_Zn;
        else
            V_eExst = V_eTot;
            V_hExst = V_hTot;
            V_eTot = [V_eExst, V_Zw_Vew + V_Ze_Ven];
            V_hTot = [V_hExst, V_Zw_Vhw + V_Zn_Vhn];
            Phi_exst = Phi;
            Phi = [Phi_exst, Phi_w_Zw + Phi_n_Zn];
        end
    else
        if ~exist('V_eTot', 'var')
            V_eTot = V_en;
            V_hTot = V_hn;
            Phi = Phi_n;
        else
            V_eExst = V_eTot;
            V_hExst = V_hTot;
            V_eTot = [V_eExst, V_en];
            V_hTot = [V_hExst, V_hn];
            Phi_exst = Phi;
            Phi = [Phi_exst, Phi_n];
        end
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

end