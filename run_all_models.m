 function stats = run_all_models(subject_num, stats, subject_type, win)

if win
   all_vars = {'allswitch'};
else
   all_vars = {'bet_switch';'betupgam';'bugamcash';'allswitch'};
end

for j = 1:length(all_vars)
    analysis_name = all_vars{j};
    resp_var = j;
    if win
        % Run models with beta = 1/sigma2
        run_num = 1
        stats = run_hgf(subject_type,subject_num,analysis_name,run_num,resp_var,'tapas_softmax_binary_invsig2_config', stats,win);
    else
        % Run models with constant beta
        run_num = 1;
        stats = run_hgf(subject_type,subject_num,analysis_name,run_num,resp_var,'tapas_softmax_binary_config', stats,win);
        
        % Run models with beta = 1/sigma2
        run_num = 2
        stats = run_hgf(subject_type,subject_num,analysis_name,run_num,resp_var,'tapas_softmax_binary_invsig2_config', stats,win);
        
        % Run models with beta = 1/exp(mu3)
        run_num = 3;
        stats = run_hgf(subject_type,subject_num,analysis_name,run_num,resp_var,'tapas_softmax_binary_invexpmu3_config',stats,win);
        
        % Run models with x = sigma1, beta = constant
        run_num = 4;
        stats = run_hgf(subject_type,subject_num,analysis_name,run_num,resp_var,'tapas_softmax_binary_sig1_config',stats,win);
    end
end
% 
% if win
%     name = ['stats_winning' sprintf('%d',subject_type) '_subject' sprintf('%d',subject_num)]
% else
%     name = ['stats_type' sprintf('%d',subject_type) '_subject' sprintf('%d',subject_num)]
% end
% save(name,'stats')