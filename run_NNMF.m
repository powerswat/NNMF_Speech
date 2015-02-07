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

[V_eTrTot, V_hTrTot, Phi_tr] = makeVmat(paths, saveTrFileName, monoMode, 1);

% Save the intermediate results
if(length(V_eTrTot)>1)
    save(saveTrFileName,'V_eTrTot','V_hTrTot','Phi_tr');
else
    load(saveTrFileName);
end

% Decompose the training/testing V matrices
dcmpPath = ['D:\Temp\NNMF\', inputTag,'\decompose'];    
ensureDirExists(dcmpPath,1);
if(exist([dcmpPath,'\WH_Tr.mat'],'file'))
    display('^^^Skipping^^^');
    load([dcmpPath,'\WH_Tr.mat']);
else
    [W_eTr,H_eTr] = nmf_kl_con(V_eTrTot, 50, 'win', 8);
    [W_hTr,H_hTr] = nmf_kl_con(V_hTrTot, 100, 'win', 1);
    save([dcmpPath,'\WH_Tr.mat'],'W_eTr','H_eTr','W_hTr','H_hTr');
end

% Generate testing V matrices
[files,paths] = findFiles(fullfile(basePath,'inputs', inputTag, testSet), '.wav', 1);
[V_eTsTot, V_hTsTot, Phi_ts] = makeVmat(paths, saveTsFileName, monoMode, 2);
if(length(V_eTsTot)>1)
    save(saveTsFileName,'V_eTsTot','V_hTsTot','Phi_ts');
end

% Test the testing V matrices
testTstMat(dcmpPath, paths, saveTsFileName, Phi_tr);
