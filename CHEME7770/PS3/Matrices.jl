using LinearAlgebra
include("Flux.jl")

Stoichiometric_matrix = [-1.0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0; #asparate
1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0; #Argininosuccinate
0 1 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0; #fumarate
0 1 -1 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0; #arginine
0 0 1 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0; #urea
0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0; #ornithine
0 0 0 -1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0; #carbamoyl phosphate
-1 0 0 1 -1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0; #citrulline
-1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0; #ATP
1 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0; #AMP
1 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0; #PPi
0 0 -1 0 -2 2 0 0 0 0 0 0 0 -1 0 0 0 0 0 0; #H2O
0 0 0 1 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0; #Pi
0 0 0 0 1.5 -1.5 0 0 0 0 0 0 0 0 0 1 0 0 0 0; #NADPH
0 0 0 0 1.5 -1.5 0 0 0 0 0 0 0 0 0 0 1 0 0 0; #H+
0 0 0 0 2 -2 0 0 0 0 0 0 0 0 0 0 0 1 0 0; #O2
0 0 0 0 -1.5 1.5 0 0 0 0 0 0 0 0 0 0 0 0 -1 0; #NADP+
0 0 0 0 -1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 -1] #NO
#Stoichiometric array as defined by the KEGG diagram
#The columns in the Stoichiometric matrix represent each reaction with the first 6 representing v1 to v5 with v5 forward reaction being the 5th column and the reverse being the 6th
Atom_matrix = [4.0 10 4 6 1 5 1 6 10 10 0 0 0 21 0 0 21 0; #C
7 18 4 14 4 12 4 13 16 14 4 2 3 30 1 0 29 0; #H
1 4 0 4 2 2 1 3 5 5 0 0 0 7 0 0 7 1; #N
4 6 4 2 1 2 5 3 13 7 7 1 4 17 0 2 17 1; #O
0 0 0 0 0 0 1 0 3 1 2 0 1 3 0 0 3 0] #P
#Empirical formulas taken from KEGG
#The columns in the Atom Matrix are from each of the metabolites with the order being the same as the order of the rows in the Stoichiometric Matrix
E = Atom_matrix * Stoichiometric_matrix

#kcat for each enzyme
kcat_flux_v1 = 203.0 #sec^-1
kcat_flux_v2 = 34.5 #sec^-1
kcat_flux_v3 = 249.0 #sec^-1
kcat_flux_v4 = 88.1 #sec^-1
kcat_flux_v5 = 13.7 #sec^-1
#Enzyme base concentration
enzyme_base_conc = .01 #umol/gDW
wet_fraction = .798 #Wet fraction of a cell
mass_of_cell = 2.3E-9 #g
volume_of_cell = 3.7E-13 #L
enzyme_base_conc1 = enzyme_base_conc / wet_fraction * mass_of_cell / volume_of_cell  #umol/L

#Km
Km_v5_arg = 4.4 #umol/L
Km_v5_NADPH = .3 #umol/L
Km_v4_orn = 360.0 #umol/L
Km_v3_arg = 1500.0 #umol/L
Km_v1_asp = 900.0 #umol/L
Km_v1_ATP = 51.0 #umol/L


#substrate concentration
asp_conc = 14900 #umol/L
orn_conc = 4490.0 #umol/L
arg_conc = 255.0 #umol/L
ATP_conc = 4670.0 #umol/L
NADPH_conc = 65.4 #umol/L

#Saturation calculations
Saturation_v1 = (asp_conc/(asp_conc+Km_v1_asp))*(ATP_conc/(ATP_conc+Km_v1_ATP))
Saturation_v3 = (arg_conc/(arg_conc+Km_v3_arg))
Saturation_v4 = (orn_conc/(orn_conc+Km_v4_orn))
Saturation_v5 = (arg_conc/(arg_conc+Km_v5_arg))*(NADPH_conc/(NADPH_conc+Km_v5_NADPH))

#upper bound calculations
upper_bound_v1 = kcat_flux_v1 * Saturation_v1 * enzyme_base_conc1
upper_bound_v2 = kcat_flux_v2 * enzyme_base_conc1
upper_bound_v3 = kcat_flux_v3 * Saturation_v3 * enzyme_base_conc1
upper_bound_v4 = kcat_flux_v4 * Saturation_v4 * enzyme_base_conc1
upper_bound_v5 = kcat_flux_v5 * Saturation_v5* enzyme_base_conc1
upper_bound_b = 10000 / wet_fraction * mass_of_cell / volume_of_cell /3600 #umol/L

Default_bounds = [0.0 upper_bound_v1;
 0 upper_bound_v2;
 0 upper_bound_v3;
 0 upper_bound_v4;
 0 upper_bound_v5;
 0 upper_bound_v5;
 0 upper_bound_b;
 0 upper_bound_b;
 0 upper_bound_b;
 0 upper_bound_b;
 0 upper_bound_b;
 0 upper_bound_b;
 0 upper_bound_b;
 0 upper_bound_b;
 0 upper_bound_b;
 0 upper_bound_b;
 0 upper_bound_b;
 0 upper_bound_b;
 0 upper_bound_b;
 0 upper_bound_b]

Species_bounds = [0.0 0;
0 0;
0 0;
0 0;
0 0;
0 0;
0 0;
0 0;
0 0;
0 0;
0 0;
0 0;
0 0;
0 0;
0 0;
0 0;
0 0;
0 0]

Objective_coefficient = [0.0; 0; 0; 0; 0; 0; 0; 0; 0; -1; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0]

optimize = calculate_optimal_flux_distribution(Stoichiometric_matrix, Default_bounds, Species_bounds, Objective_coefficient)
println("Below is the E matrix for each reaction within this system")
println(E[:,1:6])
umolL = optimize[1]
umolgdw = umolL * wet_fraction / mass_of_cell * volume_of_cell
println("This system outputs ", -1*umolgdw, " umol/gDw/s of Urea")
