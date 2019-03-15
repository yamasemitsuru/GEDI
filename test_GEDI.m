%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   test_GEDI
%   Test code for GEDI
%
%   Yamamoto K.,
%   Created : 12 Nov. 2018
%   Modified: 26 Dec. 2018
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Environment settings
% Root
DirRoot = [getenv('HOME') '/Desktop/GEDI_Software/'];
chdir(DirRoot);

% Sounds
DirData = [DirRoot 'wav_sample/'];

% Package of dynamic compressive gammachirp filterbank
% Please download the "GCFBv211pack" and put into the "thirdparty" directory 
%DirGCFB = [DirRoot 'thirdparty/GCFBv210pack/'];
DirGCFB = [DirRoot 'thirdparty/GCFBv211pack/'];
StrPath = path;
if ~contains(StrPath,'GCFBv211pack/') == 1
    addpath(genpath(DirGCFB));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GEDI and materials
% Parameters of dcGC filterbank
GCparam.Ctrl    = 'dynamic';
GCparam.NumCh   = 100;
GCparam.fs      = 48000;

% Parameter settings for materials
ParamSNR = [-6 -3 0 3]; %SNR between clean speech and noise
SPL = 63; % sound pressure level

% Parameter settings for materials
fs = 16000;
Conditions = [1.17 0.5 20000 1.62 fs]; % [k q m sigma_s fs]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Start simulation
Pcorrects = zeros(1,length(ParamSNR));

for i = 1:length(ParamSNR)
    
    % Index number of a sample speech file
    idxSp = i;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Test signal (enhanced/Unprocessed speech); the speech intelligiblity is calculated
    % Name of wav-file (example: '*/GEDI_Software/wav_sample/sample_sp1')
    strTest = [DirData 'sample_sp' num2str(idxSp)];
    % Read wav-file of test speech
    [SndTest, ~] = audioread([strTest '.wav']);
    disp(strTest);
    
    %% Reference signal (Clean speech)
    % Name of wav-file
    strClean = [DirData 'sample_sp_clean'];
    % Read wav-file of clean speech
    [SndClean, ~] = audioread([strClean '.wav']);
    disp(strClean);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Pre-processing with a half-cosine function
    TimeHalfCos     = 0.02;    % [sec]    
    LenSndClean     = length(SndClean);
    LenHalfCos      = round(TimeHalfCos * fs);
    SigHalfCos      = hann(LenHalfCos*2);
    SigHalfCosUp    = SigHalfCos(1:LenHalfCos)';
    CompHalfCosFunc = [SigHalfCosUp ones(1,LenSndClean-LenHalfCos*2) fliplr(SigHalfCosUp)];
    SndClean    = SndClean .* CompHalfCosFunc';
    SndTest     = SndTest  .* CompHalfCosFunc';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Speech intelligibility prediction by GEDI
    Result = GEDI(SndTest, SndClean, GCparam, Conditions, SPL);
    Pcorrect = Result.Pcorrect;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Pcorrects(idxSp) = Pcorrect;
    disp('==========================================');
    disp(['Percent correct:' num2str(Pcorrect) '(%)']);
    disp('==========================================');
    
end

%% Plot results
figure
plot(ParamSNR,Pcorrects);
xlim([-0.5+min(ParamSNR) max(ParamSNR)+0.5]);
ylim([-0.5+0 100+0.5]);
xlabel('SNR (dB)');
ylabel('Percent correct (%)')
legend('Unprocessed')
title('Examples of GEDI');