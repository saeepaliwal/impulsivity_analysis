function BMS_analysis(analysis_name, subject_type)

load(['../results/' sprintf('%s',analysis_name) '/parameter_workspace_' sprintf('%d',subject_type)])

%% BMS analysis
%{
for i = percept
	allbinFE = squeeze(binFEgrid(i,:,:))';
	[allBMS{1},allBMS{2},allBMS{3}] = spm_BMS([allbinFE]);
end


%}

[allBMS{1},allBMS{2},allBMS{3}] = spm_BMS(binFEgrid);


save (['../results/' sprintf('%s',analysis_name) '/bms_results_' sprintf('%d',subject_type)], 'allBMS');