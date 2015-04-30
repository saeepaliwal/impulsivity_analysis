function stats = run_hgf(subject_type,subject_num,run_num,resp_var, resp_model, stats, PAPER)
% This function will run the full grid of binary perceptual variables
% against response variables for the perceptual and response variable
% specified.
% Usg: model_grid_fun(1,1);
% The function saves a stats_MG_<g>_<i>.mat file in the current directory.
%
% -------------------------------------------------------------------------
% Author: Saee Paliwal, TNU

% Run various HGF models for all the data

load Final_trace.mat
path(path,genpath(pwd));

perf = stats{subject_type}.data{subject_num}.performance;
%time = stats{subject_type}.data{subject_num}.reaction;

% Pull out NaNs for modelling
%time(isnan(time)) = 0;
%time = tapas_sgm(time,1); % map to small/large space

P = cT.P(1:length(perf));

%% Run perceptual variables
if PAPER
    allU = make_winning_perceptual_variable(subject_type,subject_num, stats);
else
    allU = make_perceptual_variable(subject_type, subject_num,stats);
end
num_u = length(allU);

%% Construct response variables
if PAPER
    allY = make_winning_response_variable(subject_type, subject_num,stats);
else
    allY = make_response_variable(subject_type, subject_num,stats);
end

%% Run model grid
for k = 1:num_u
	for v = run_num
		% Set percept
		u = allU{k};
        %u = allU{k}(1:100);
		
		% Set response
		responses = allY{resp_var};
		
		% Fit model to input data
		pars = tapas_fitModel(responses, u, 'tapas_hgf_binary_config', resp_model, 'tapas_quasinewton_optim_config');
		
		% Simulate reponses
		sim = tapas_simModel(u, 'tapas_hgf_binary', pars.p_prc.p, 'tapas_softmax_binary',pars.p_obs.be);
		pars.y = sim.y;
		
		% Save to stats
		stats{subject_type}.hgf.bin(v,k,subject_num) = pars;
		stats{subject_type}.hgf.bin_FE(v,k, subject_num) = pars.F;
		
		rw_pars = tapas_fitModel(responses, u, 'tapas_rw_binary_config', 'tapas_softmax_binary_config', 'tapas_quasinewton_optim_config');
		
		stats{subject_type}.rw(v,k, subject_num) = rw_pars;
		stats{subject_type}.rw_FE(v,k, subject_num) = rw_pars.F;
		
	end
end

