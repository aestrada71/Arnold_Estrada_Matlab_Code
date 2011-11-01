Ru_mol_wt = 1169.17;                %g/mol
Ru_mol_wt = 748.62;                %g/mol   -CHEAPER STUFF--
rat_mass = 0.300;                   %kg
total_inj_vol = 2;                  %ml


%% Phase 1 parameters
phase1_time = 5;                    %min
phase1_mass_inj_rate = 400e-9;      % mol/(kg min)
phase1_mass_inj = phase1_mass_inj_rate * rat_mass * phase1_time; %(mol)
phase1_mass_inj_mg = phase1_mass_inj * Ru_mol_wt * 1e3  %(mg)


%% Phase 2 parameters
phase2_time = 10;                    %min
phase2_mass_inj_rate = 60e-9;      % mol/(kg min)
phase2_mass_inj = phase2_mass_inj_rate * rat_mass * phase2_time; %(mol)
phase2_mass_inj_mg = phase2_mass_inj * Ru_mol_wt * 1e3  %(mg)

%% Phase 3 parameters;
phase3_time =  4 * 60;             % min
phase3_mass_inj_rate = 40e-9;      % mol/(kg min)
phase3_mass_inj = phase3_mass_inj_rate * rat_mass * phase3_time; %(mol)
phase3_mass_inj_mg = phase3_mass_inj * Ru_mol_wt * 1e3;  %(mg)

%% Mass Totals
total_mass_inj = phase1_mass_inj +phase2_mass_inj +phase3_mass_inj; %(mol)
total_mass_inj_mg = total_mass_inj * Ru_mol_wt * 1e3 %(mg)
Ru_soln_concen = total_mass_inj / (total_inj_vol * 1e-3) %(mol/liter)
Ru_soln_mg_per_ml = total_mass_inj_mg / total_inj_vol %mg/ml 

%% Injection rates  (assuming the stock soln from previous step)
phase1_flow_rate = phase1_mass_inj_rate * rat_mass / Ru_soln_concen * 1e6  %(uL / min)
phase2_flow_rate = phase2_mass_inj_rate * rat_mass / Ru_soln_concen * 1e6  %(uL / min)
phase3_flow_rate = phase3_mass_inj_rate * rat_mass / Ru_soln_concen * 1e6  %(uL / min)
