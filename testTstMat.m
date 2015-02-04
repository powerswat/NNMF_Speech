function [V_eTot, V_hTot, Phi] = testTstMat(dcmpPath, paths, saveFileName, Phi_tr, monoMode)

% Read W and H matrices of the training V matrices
load([dcmpPath,'\WH_Tr.mat']);

% Read the testing V matrices
load(saveFileName);

L = round(size(W_eTr,1)/2);
M = size(W_eTr,1);
W_elTr = [W_eTr(1:L,:)];
W_hlTr = [W_hTr(1:L,:)];
V_elTsTot = V_eTsTot(1:L,:);
V_hlTsTot = V_hTsTot(1:L,:);
Phi_lTs = Phi_ts(1:L,:);

K = round(M/3);
N = size(H_eTr,2);
Phi_u = Phi_tr(end-(M-L)+1:end,:);
Phi_l = Phi_tr(1:L, :);
Phi_h = [zeros(K,N);Phi_tr(K+1:end,:)];
%A_phi = exp(1i*Phi_u) * pinv(exp(1i*Phi_tr));    
A_phi = Phi_l' \ Phi_u';

if(exist([dcmpPath,'\WH_Ts.mat'],'file'))
    display('^^^Skipping^^^');
    load([dcmpPath,'\WH_Ts.mat']);
else
    [W_elTs,H_eTs] = nmf_kl_con(V_elTsTot, 46, 'W', W_elTr);
    [W_hlTs,H_hTs] = nmf_kl_con(V_hlTsTot, 46, 'W', W_hlTr);
     save([dcmpPath,'\WH_Ts.mat'],'W_elTs','W_hlTs','H_eTs','H_hTs');
end

N = size(H_eTs,2);

Z_h = [zeros(K, M);ones(M-K, M)];
Z_n = [[eye(L) zeros(L,M-L)]; zeros(M-L,M)];
Z_e = [ones(K, M);zeros(M-K, M)];
Z_w = [zeros(L,M);[zeros(M-L,L) eye(M-L)]];
Z_u = [eye(M-L) zeros(M-L,L-(M-L)); zeros(L,L)];
Z_l = [[eye(L) zeros(L,M-L)]; zeros(M-L,M)];

V_hbTs = W_hTr * H_hTs;
V_ebTs = W_eTr * H_eTs;

V_hTs = Z_w*V_hbTs + Z_n*V_hTsTot;
V_eTs = Z_w*V_ebTs + Z_n*V_eTsTot;

V_test = V_hTs .* V_eTs;
Phi_test = [eye(L); A_phi'] * exp(1i*Phi_lTs);

Z = V_test.*Phi_test;
[x_res] = istft(Z,512,512,128);

a = 3;