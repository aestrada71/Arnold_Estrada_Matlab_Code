%Script to calculate the wieghts and volumes needed to make the solution 
%needed to perform image-guided pO2 measurements in mice using new two-photon porph.

%% Given Parameters

targetPorphConcentration = 20e-6;  % Moles/liter of blood plasma
porphMolecWt = 64500;               % grams / mole
%albuminMolecWt = 66432;             % grams / mole
stockPorphSolnVolume = 5;          % ml
%stockFluorSolnVolume = 10;          % ml
totalInjectionVol = 0.2;            % ml
porphInjectionVol = 0.2;           % ml
fluorInjectionVol = 0.00;           % ml
totalBloodVol = 77;                 % ml / kg of body weight
%endogenousAlbuminConcentration = 30;% mg / ml blood
hematocrit = 0.40;                  % percent
%targetAlbuminToPorphRatio = 1.8     % ratio of albumin molecules / porph molecules

typicalWeight = 30;                 % grams



%% Calculations
animalBloodVolume = (typicalWeight /1000) * (totalBloodVol);  %ml
plasmaVolume =  animalBloodVolume * (1-hematocrit)  % ml
injectedPorphMass_mol = targetPorphConcentration * (plasmaVolume/1000);
injectedPorphMass = injectedPorphMass_mol * porphMolecWt % grams
stockPorphWtByVol = injectedPorphMass / porphInjectionVol  %grams / ml of soln

% need to figure out how much albumin to add.
%targetAlbuminMass_mol = injectedPorphMass_mol * targetAlbuminToPorphRatio; %mol
%totalEndogenousAlbumin_mg = animalBloodVolume * endogenousAlbuminConcentration; % mg
%totalEndogenousAlbumin_mol = totalEndogenousAlbumin_mg * (1/1000) * (1/albuminMolecWt);  % mol
%neededAlbuminMass_mol = targetAlbuminMass_mol - totalEndogenousAlbumin_mol
%stockBSAWtByVol = (neededAlbuminMass_mol * albuminMolecWt) / porphInjectionVol  %grams / ml of soln