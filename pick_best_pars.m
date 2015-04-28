function winningmodel = pick_best_pars(analysis_name, subject_type, idxx, idxy)

load(['../results/' sprintf('%s',analysis_name) '/bms_results_' sprintf('%d', subject_type)]);
load(['../results/' sprintf('%s', analysis_name) '/parameter_workspace_' sprintf('%d', subject_type)]);


if idxx==0 | idxy==0
    [val idx] = max(allBMS{1}(1:end-3));
    
    idxx = mod(idx,3);
    if idxx==0
        idxx=3;
    end
    idxy = ceil(idx/3);
end

winningmodel = idxy;
omega = squeeze(omega_all(idxy,idxx,:));
theta = squeeze(theta_all(idxy,idxx,:));
bbeta = squeeze(beta_all(idxy,idxx,:));


save (['../results/' sprintf('%s', analysis_name) '/parameter_workspace_' sprintf('%d',subject_type)],'omega_all','theta_all','beta_all','binFEgrid','omega','theta','bbeta');

