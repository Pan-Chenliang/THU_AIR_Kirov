%% Lookup-table data in the body-axis system
% Basic aerodynamic table:
%   alpha_bp  : 1-by-13 breakpoint (deg)
%   beta_bp   : 1-by-13 breakpoint (deg), symmetric about zero
%   T         : 13-by-13-by-6, where T(:,:,1:6) = [Fx Fy Fz Mx My Mz]
%
% Control-surface tables (one row per deflection):
%   <surface>_bp : deflection breakpoint (deg)
%   T_<surface>  : N-by-6, columns = [dFx dFy dFz dMx dMy dMz]

importFile = fullfile(fileparts(mfilename("fullpath")), "../data/气动汇总表.xlsx");
importData = readmatrix(importFile, Sheet="基本气动_体轴系", Range="B2:K84");

alpha_bp = importData(1:13, 1).';
importBetaPositive = [0, readmatrix(importFile, Sheet="基本气动_体轴系", Range="F1:K1")];
beta_bp = [-fliplr(importBetaPositive(2:end)), importBetaPositive];

% C is the beta = 0 reference value; E:K are the beta increments.
importTPositive = cat(3, ...
    importData(1:13, 2)  + importData(1:13, 4:10), ...
    importData(15:27, 2) + importData(15:27, 4:10), ...
    importData(29:41, 2) + importData(29:41, 4:10), ...
    importData(43:55, 2) + importData(43:55, 4:10), ...
    importData(57:69, 2) + importData(57:69, 4:10), ...
    importData(71:83, 2) + importData(71:83, 4:10));

% Mirror the positive-sideslip data for beta < 0.
% Fx, Fz, My are even; Fy, Mx, Mz are odd with respect to beta.
importTNegative = importTPositive(:, end:-1:2, :);
importTNegative(:, :, [2 4 6]) = -importTNegative(:, :, [2 4 6]);
T = cat(2, importTNegative, importTPositive);

importControlData = readmatrix(importFile, Sheet="舵效", Range="A1:G49");

ELEV_bp = importControlData(2:8, 1);    T_ELEV = importControlData(2:8, 2:7);
LAILE_bp = importControlData(11:17, 1); T_LAILE = importControlData(11:17, 2:7);
RAILE_bp = importControlData(20:26, 1); T_RAILE = importControlData(20:26, 2:7);
RUDD_bp = importControlData(29:35, 1);  T_RUDD = importControlData(29:35, 2:7);
FLAPS_bp = importControlData(38:40, 1); T_FLAPS = importControlData(38:40, 2:7);
SPOILERS_bp = importControlData(43:49, 1); T_SPOILERS = importControlData(43:49, 2:7);

% Dynamic derivatives and reference geometry.
% Excel notation is preserved: Cma = C_m_alpha_dot, Cnb = C_n_beta_dot.
importDynamicData = readmatrix(importFile, Sheet="动导数", Range="B2:B14");

Cmq = importDynamicData(1);
Cma = importDynamicData(2);
CLq = importDynamicData(3);
CLa = importDynamicData(4);
Clp = importDynamicData(5);
Clr = importDynamicData(6);
Clb = importDynamicData(7);
Cnp = importDynamicData(8);
Cnr = importDynamicData(9);
Cnb = importDynamicData(10);
S   = importDynamicData(11);
c   = importDynamicData(12);
b   = importDynamicData(13);

% Ground-effect model parameters.
% Names match the labels in the "地效" worksheet.
% Geometry, density, and speed are reused from the existing model signals.
importGroundEffectData = readmatrix(importFile, Sheet="地效", Range="B2:B9");

kInduced       = importGroundEffectData(1);
minWingHeight  = importGroundEffectData(2);
alphaFull      = importGroundEffectData(3);
alphaOff       = importGroundEffectData(4);
heightFadeStart = importGroundEffectData(5);
heightOff      = importGroundEffectData(6);
betaFull       = importGroundEffectData(7);
betaOff        = importGroundEffectData(8);

% Do not leave import-only variables in the workspace.
clear importFile importData importControlData importDynamicData importBetaPositive ...
    importTPositive importTNegative importGroundEffectData
