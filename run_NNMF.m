function [] = run_NNMF(intputTag, trainSet, testSet, monoMode)

if ~exist('inputTag', 'var') || isempty(intputTag), inputTag = 'clean_cg03'; end
if ~exist('trainSet', 'var') || isempty(trainSet), trainSet = 'train\subtrain'; end
if ~exist('testSet', 'var') || isempty(testSet), testSet = 'train\subdev'; end
if ~exist('monoMode', 'var') || isempty(monoMode), monoMode = 0; end

% Read a wav file from the base path
basePath = 'D:\Temp\explains';
[files,paths] = findFiles(fullfile(basePath,'inputs', inputTag, trainSet), '.wav', 1);

% Save the parameter information
trParams = [inputTag, '_', trainSet];
tsParams = [inputTag, '_', testSet];
saveTrFileName = ['D:\Temp\NNMF\', trParams,'\subtrain.mat'];
saveTsFileName = ['D:\Temp\NNMF\', tsParams,'\subdev.mat'];
saveTrPath = ['D:\Temp\NNMF\', trParams];
saveTsPath = ['D:\Temp\NNMF\', tsParams];
ensureDirExists(saveTrPath,1);
ensureDirExists(saveTsPath,1);

[V_eTrTot, V_hTrTot] = makeVmat(paths, saveTrFileName, monoMode);
[V_eTsTot, V_hTsTot] = makeVmat(paths, saveTsFileName, monoMode);

% Save the intermediate results
if(length(V_eTrTot)>1)
    save(saveTrFileName,'V_eTrTot','V_hTrTot');
else
    load(saveTrFileName);
end
if(length(V_eTsTot)>1)
    save(saveTsFileName,'V_eTsTot','V_hTsTot');
else
    load(saveTsFileName);
end

% Decompose the training/testing V matrices
dcmpPath = ['D:\Temp\NNMF\', inputTag,'\decompose'];
ensureDirExists(dcmpPath,1);
if(exist([dcmpPath,'\WH_Tr.mat'],'file'))
    display('^^^Skipping^^^');
    load([dcmpPath,'\WH_Tr.mat']);
else
    [W_eTr,H_eTr] = nmf_kl_con(V_eTrTot, 46);
    [W_hTr,H_hTr] = nmf_kl_con(V_hTrTot, 46);
    save([dcmpPath,'\WH_Tr.mat'],'W_eTr','H_eTr','W_hTr','H_hTr');
end
if(exist([dcmpPath,'\WH_Ts.mat'],'file'))
    display('^^^Skipping^^^');
    load([dcmpPath,'\WH_Ts.mat']);
else
    [W_eTs,H_eTs] = nmf_kl_con(V_eTsTot, 46);
    [W_hTs,H_hTs] = nmf_kl_con(V_hTsTot, 46);
    save([dcmpPath,'\WH_Ts.mat'],'W_eTs','H_eTs','W_hTs','H_hTs');
end

a = 1;