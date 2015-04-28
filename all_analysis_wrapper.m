% This is the workflow for all tables/statistics/figures in the gambling
% paper

clear
addpath(genpath('<DATA_PATH>'));

%% Reproduce best model from paper
% Set this flag if you want to run the 
% winning model from Paliwal, Petzschner et al, 2014
PAPER = 1;

% Speficy which steps (as labelled) need to be done:
done(1) = 1;
done(2) = 1;
done(3) = 1;
done(4) = 1;
done(5) = 1;
done(6) = 1;
done(7) = 1;
done(8) = 1;

% Specify the following variables in your matlab environment

analysis_name = ANALYSIS_NAME;
data_dir = DATA_DIRECOTRY
subject_dir = LIST_OF_SUBJECT_DIRECTORIES
subject_type = 1:length(subject_dir);
analysis_dir = [PATH_TO_RESULTS_FOLDER analysis_name];
if exist(analysis_dir) == 0
    mkdir(analysis_dir)
end

% If the data import into matlab is already completed, specify the path to that mat file
% The questionnaire struct is subject-specific questionaire values
% The questionnaire struct must have a labels field, which should be the same 
% as the stats{subject_type}.labels field, to ensure subject-to-questinonaire matching
if done(1)
    stats_struct = STATS_STRUCT;
    questionnaire_struct = QUESTIONNAIRE_STRUCT
end
%% Step 1: Pull behavioral information and run behavioral ANOVAs
% N.B: stats struct has the following structure: stats{subject_type}.fields
if ~done(1)
    for i = 1:length(subject_dir)
        stats{i} = output2mat(subject_dir{i})
    end
    data_name = [data_dir 'stats_' analysis_name]
    save(data_name,'stats')
    
    % Now run all significant correlations:
    % all_significant_correlations
    
    % Add BIS
    add_BIS = 0;
    if ~add_BIS
        load([data_dir 'bis_struct']);
        for j = 1:length(subject_type)
            if sum(strcmp(stats{j}.labels, questionnaire_struct{j}.labels) == 0)>0
                error('Labels don''t match up! Check your data');
            else
                stats{j}.BIS_Total = bis_struct{j}.BIS_Total;
            end
        end
    end
else
    load(stats_struct)
end

%% Step 2: Run all models:
if ~done(2)
    for g = subject_type
        for i = 1:length(stats{g}.labels)
            stats = run_all_models(i,stats, subject_type(g), PAPER);
        end
    end
end
data_name = [data_dir 'stats_' analysis_name]
save(data_name,'stats')

% This can be run on Brutus using the run_models.sh script

%% Step 3: Collect all model info

if ~done(3)
    for s = subject_type
        collect_model_info(analysis_name, s,stats, PAPER);
    end
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

%% Step 5: Run all regressions on best model pars

if ~done(5)
	regs = all_regressions(analysis_name,printbeta,subject_type,stats, PAPER);
    data_name = [data_dir 'regs_' analysis_name];
    save(data_name,'regs')
end
%% Step 6: Print all tables:

if ~done(6)
	printtable(analysis_name,printbeta);
end


%% Step 7: Run cluster analysis

if ~done(7)
	run_GMM(analysis_name)
end

%% Step 8: Run a pdf of all tables

if ~done(8)
	!pdflatex alltables.tex
	!open -a Preview alltables.pdf
	copyfile('./alltables.pdf',['../all_analyses/' sprintf('%s',analysis_name) '/' sprintf('%s',analysis_name) '.pdf']);
end





