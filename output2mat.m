function stats = output2mat(output_dir)
% Makes stats structure for subjects. 
% Subjects should be a vector of integers
%% Applies various incarnations of the HGF to the gambling paradigm
%
% Pull in candidate trace
% 0 is a loss
% 1 is a real win
% 2 is a fake win
% 3 is a near miss

stats = [];

% Pull all subject names
allnames = dir(output_dir);
isub = [allnames(:).isdir];
subjects = {allnames(isub).name};
subjects(ismember(subjects,{'.','..'})) = [];

% Group variables
allReaction = [];
allBets = [];
allBetSwitch = [];
allPerf = [];
allDiffPerf = [];
allVol = [];
allSwitch = [];
allCashout = [];
allMachine = [];

% Individual Effects: pull out patient-by-patient stats
for i = 1:length(subjects)
    
    stats.labels(i) = subjects(i);
    subject_name = subjects{i};
    subdir = [output_dir '/' subject_name '/1/'];
    datafile = dir([output_dir '/' subject_name '/1/output*_short.txt']);
    datafile = [subdir datafile.name];
    headerfile = dir([output_dir '/' subject_name '/1/header*.txt']);   
    headerfile = [subdir headerfile.name];
    
    
	% Pull data
	[trialnum reaction bets performance switches current_machine cashout gamble didGamble ...
        gambleOutcome grade P lenOfPlay machine toppedUp gambleTime] = ...
        parse_short_output(headerfile,datafile);

	% Summary statistics:
	
	% Variance of bet behaviour
	stats.B_var(i) = var(bets);
	
	% Mean of bet behav
	stats.B_mean(i) = mean(bets);
	
	% Variance of reaction time
	reac_smooth = reaction;
	reac_smooth(isnan(reaction)) = 0;
	stats.RT_var(i) = var(reac_smooth);
    stats.RT_mean(i) = mean(reac_smooth);
	
	% Save trajectories
	stats.data{i}.name = subject_name;
	stats.data{i}.reactionTime = reaction;
	stats.data{i}.bets = bets;
	stats.data{i}.performance = performance;
	stats.data{i}.machineSwitches = switches;
	stats.data{i}.cashout = cashout;
	stats.data{i}.gamble = didGamble;
	stats.data{i}.gambleOutcome = gambleOutcome;
	stats.data{i}.grade = grade;
	stats.data{i}.probabilityTrace = P;
	stats.data{i}.lenOfPlay = lenOfPlay;
	stats.data{i}.machine = machine;
	stats.data{i}.topup = toppedUp;
	stats.data{i}.gambleTime = gambleTime;
    stats.data{i}.current_machine = current_machine;
    
	% Percentage cashouts:
	stats.cashoutPct(i) = sum(nansum(cashout))/length(cashout);
	
	% Percentage switches:
	stats.switchPct(i) = sum(nansum(switches))/length(switches);
	
	% Percentage gamble:
	stats.gamblePct(i) = sum(nansum(didGamble))/sum(nansum(gamble));
	
	% Percentage Big Bets: Added Rike
    
    stats.bigbetPct(i) = length(find(bets==60))/length(bets);

    % Percentage Switch Bets: Added Rike
    
    stats.switchbetPct(i) = 1-(length(find(diff(bets)==0))/length(bets));
    
    % Performance score
	stats.finalPerf(i) = performance(end);
    
	% Length of play
	stats.lenPlay(i) = lenOfPlay;
	
	% All reaction
	allReaction = [allReaction reaction'];
	
	% All Bets
	allBets = [allBets bets];
	
	% All Bet Switch
	allBetSwitch = [allBetSwitch 0 diff(bets)];
	
	% All Performance
	allPerf = [allPerf performance];
	
	% All diff perf
	allDiffPerf = [allDiffPerf 0 diff(performance)];
	
	% All machine
	allMachine = [allMachine machine];
	
	% All Switches
	allSwitch = [allSwitch switches];
	
	% All Cashouts
	allCashout = [allCashout cashout];
	
	clear trialnum reaction bets performance switches cashout gamble gambleOutcome grade P lenOfPlay machine betDeriv bigGamble didGamble toppedUp gambleTime
end


% Aggregate variables
stats.allBets = allBets;
stats.allReaction = allReaction;
stats.allPerf = allPerf;
stats.allDiffPerf = allDiffPerf;
stats.allBetSwitch = +(allBetSwitch~=0);
stats.allSwitches = allSwitch;
stats.allCashout = allCashout;
stats.allMachine = allMachine;

    
    
    
