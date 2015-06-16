% This is the workflow for all tables/statistics/figures in the gambling
% Variables you will need to specify in your workspace:
%       1. ANALYSIS_NAME := what you would like to call your analysis
%
%       2. OUTPUT_DIRECTORY := where you would like your outputfiles that contain
%         data to be stored, if they need to be on an internal server, say
%         (make sure this ends in a slash, i.e. '/home/user/mydata/' )
%
%       3. LIST_OF_SUBJECT_DIRECTORIES := where your subject-specific raw data
%       is stored (also please make sure this ends in a slash)
%
%       4. PATH_TO_RESULTS_FOLDER := where you would like to store your
%       results that do not contain sensitive patient data 
%       (again, please make sure this ends in a slash)
%
% Optional additions:
%
%       5. QUESTIONNAIRE_STRUCT := full path to questionnaire struct
% If your raw data has already been processed into a struct, you must speficy
%       6. STATS_STRUCT := full path to stats struct
%       
% The questionnaire struct is subject-specific questionnaire values
% The questionnaire struct must have a labels field, which should be the same 
% as the stats{subject_type}.labels field, to ensure subject-to-questionnaire matching
% If you want to only run the winning model from the paper, set the PAPER flag to 1

addpath(genpath(DATA_DIRECTORY));
addpath(genpath(pwd));

% Make the results folder if it does not exist
if ~exist(PATH_TO_RESULTS_FOLDER)
    mkdir(PATH_TO_RESULTS_FOLDER);
end

%% Reproduce best model from paper
% Set this flag if you want to run the 
% winning model from Paliwal, Petzschner et al, 2014
PAPER = 1;

% Speficy which steps (as labelled) need to be done:
% 1 is done, 0 is to be done 
done(1) = 1;
done(2) = 0;
done(3) = 1;
done(4) = 1;
done(5) = 1;
done(6) = 1;
done(7) = 1;
done(8) = 1;


% Specify the following variables in your matlab environment
analysis_name = ANALYSIS_NAME;
data_dir = OUTPUT_DIRECTORY;
results_dir = PATH_TO_RESULTS_FOLDER;

if ~iscell(LIST_OF_SUBJECT_DIRECTORIES)
    subject_dir = {LIST_OF_SUBJECT_DIRECTORIES};
else
    subject_dir = LIST_OF_SUBJECT_DIRECTORIES;
end

subject_type = 1:length(subject_dir);

% Pull in final game trace
load game_trace.mat

% If the data import into matlab is already completed, specify the path to that mat file
if done(1)
    stats_struct = STATS_STRUCT;
end
%% Step 1: Pull behavioral information and run behavioral ANOVAs
% N.B: stats struct has the following structure: stats{subject_type}.fields
if ~done(1)
    stats = {};
    for i = 1:length(subject_dir)
        stats{i} = output2mat(subject_dir{i})
    end
    if exist('QUESTIONNAIRE_STRUCT')
        questionnaire_struct = QUESTIONNAIRE_STRUCT;
        qval = load(QUESTIONNAIRE_STRUCT);
        tmp = fieldnames(qval);
        qline = ['getfield(qval,''' sprintf('%s',tmp{:}) ''')'];
        qstruct = eval(qline);
        for j = 1:length(subject_type)
            if length(qstruct)< j
                continue;
            else
                if sum(strcmp(stats{j}.labels, qstruct{j}.labels) == 0)>0
                    error('Labels don''t match up! Check your data');
                else
                    stats{j}.BIS_Total = qstruct{j}.BIS_Total;
                end
            end
        end
    end
    
    data_name = [data_dir 'stats_' analysis_name];
    save(data_name,'stats');
else
    load(stats_struct)
end

%% Step 2: Run all models:
if ~done(2)
    for g = subject_type
        if isfield(stats{g},'hgf')
            stats{g} = rmfield(stats{g},'hgf');
        end
        if isfield(stats{g},'rw')
            stats{g} = rmfield(stats{g},'rw');
        end
        for i = 1:length(stats{g}.labels)
            P = game_trace(1:length(stats{g}.data{i}.performance));
            stats = run_all_models(i,stats, subject_type(g), PAPER,P);
        end
    end
end
data_name = [data_dir 'stats_' analysis_name];
save(data_name,'stats');

%% Step 3: Collect all model info
if ~done(3)
    for s = subject_type
        [kappa_all,omega_all,theta_all,beta_all,binFEgrid] = collect_model_info(s,stats, PAPER);
    end
    pars.kappa = kappa_all;
    pars.omega = omega_all;
    pars.theta = theta_all;
    pars.beta_all = beta_all;
    pars.FE = binFEgrid;
    %     eval(['' analysis_name '_pars = pars;']);
    if PAPER
        parameter_workspace = [results_dir 'parameter_workspace_winning ' analysis_name];
    else
        parameter_workspace = [results_dir 'parameter_workspace'];
    end
    %     save(parameter_workspace,[analysis_name '_pars']);
    save(parameter_workspace,'pars');
end

%% Step 4: Run all BMS analysis
if ~done(4)
	% Run model comparison
    if ~PAPER
        BMS_analysis(analysis_name);
        
        % Do not pre-select a winning model
        idxx = 0;
        idxy = 0;
        
        % Pick best parameters
        winningmodel = pick_best_pars(analysis_name, subject_type, idxx, idxy);
    else
        winningmodel = 1;
    end


    if ~PAPER
        if winningmodel == 1 | winningmodel == 4
            printbeta = 1;
        else
            printbeta = 0;
        end
    else
        printbeta = 0;
    end
end
%% Step 5: Run all regressions on best model pars

if ~done(5)
	regs = all_regressions(analysis_name,printbeta,subject_type,stats, PAPER, parameter_workspace);
    data_name = [results_dir 'regs_' analysis_name];
    save(data_name,'regs');
end
%% Step 6: Print all tables:

if ~done(6)
	printtable(analysis_name,printbeta);
end

%% Step 7: Print all figures from paper:

if ~done(7)
    all_figures
end

%% Step 8: Run a pdf of all tables

if ~done(7)
	!pdflatex alltables.tex
	!open -a Preview alltables.pdf
	copyfile('./alltables.pdf',[PATH_TO_RESULTS_FOLDER sprintf('%s',analysis_name) '/' sprintf('%s',analysis_name) '.pdf']);
end

% CREATE A TEMPLATE OF ALL THE FIGURES AND TABLES


