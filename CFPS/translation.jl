include("Flux.jl")

Stoich_Matrix =
[-1.0	1	0	0	0	0	0	0	0	0	0	0	0	0	0; #Gene
-1	1	0	0	0	0	0	0	0	0	0	0	0	0	0; #RNAP
1	-1	0	0	0	0	0	0	0	0	0	0	0	0	0; #Activated gene
0	-714	0	0	0	0	0	1	0	0	0	0	0	0	0; #NTP
0	1	-1	-1	1	0	0	0	0	0	0	0	0	0	0; #mRNA
0	1428	0	0	476	2	0	0	0	0	0	0	0	0	-1; #Pi
0	0	714	0	0	0	0	0	0	-1	0	0	0	0	0; #NMP
0	0	0	-1	1	0	0	0	0	0	0	0	0	0	0; #ribosome
0	0	0	1	-1	0	0	0	0	0	0	0	0	0	0; #activated ribosome
0	0	0	0	-238	1	0	0	0	0	0	0	0	0	0; #AAtRNA
0	0	0	0	-476	0	0	0	0	0	0	0	1	0	0; #GTP
0	0	0	0	238	-1	0	0	0	0	0	0	0	0	0; #tRNA
0	0	0	0	476	0	0	0	0	0	0	0	0	-1	0; #GDP
0	0	0	0	1	0	0	0	-1	0	0	0	0	0	0; #protein
0	0	0	0	0	-1	1	0	0	0	0	0	0	0	0; #amino acid
0	0	0	0	0	-1	0	0	0	0	1	0	0	0	0; #ATP
0	0	0	0	0	1	0	0	0	0	0	-1	0	0	0] #AMP

RNAP_conc = .11256E-6 #uM
Ribo_conc = 10.9E-6 #uM
E_x = 60.0 #nt/sec NOT ACTUAL KE
E_l = 16.5 #aa/sec NOT ACTUAL KE
K_x = .02911 #uM
K_l = 57.0 #uM
tau_x = 1
tau_l = 1
#kd_xh = 8.35 #1/hr
kd_x = .000411 #1/sec
kd_m = log(2) / kd_x
#kd_lh = .0099 #1/hr
#kd_l = kd_lh = kd_lh /3600 #1/sec
#kd_p = log(2) / kd_l
L_x = 1000 #nt (characteristic length of genes)
L_l = 330 #aa (characteristic length of polypeptide)
Lx = 714 #nt (actual length of gene)
Ll = 238 #aa (actual length of polypeptide)
L_factor = L_x/Lx
Lp_factor = L_l/Ll
gene_conc = 3.76E-8 #M
kE_x = E_x / L_x *L_factor
kE_l = E_l / L_l * Lp_factor
kI_x = kE_x / tau_x
kI_l = kE_l / tau_l
#v2
kinetic_limit_transcript_unregulated = kE_x * RNAP_conc * gene_conc / (K_x+gene_conc) #Fully constrained equation for v2

#From assuming the change in mRNA concentration is 0 we can derive the following equation for steady state mRNA concentration


#v5
mRNA = 1E-2 #Umol
kinetic_limit_translate = kE_l * Ribo_conc *mRNA/ (K_l+ mRNA)

#No other data is presented for constraints for equations
lg_bound = 1.88E2 #Moler/sec
inf = 999999.99 #unconstrained reaction

Bounds_matrix = [-1*inf inf; #v1 is unbounded by any constraints
0  kinetic_limit_transcript_unregulated;#kinetic_limit_transcript
0 kd_x;#v3 is  bound by knowing the rate of degradation but not knowing the mRNA concentration present
0 kI_l;#v4 is unbounded by equations
0 kinetic_limit_translate;#v5 bounded by the kinetic limit of translation only as an upper bound
0 inf;#v6 is unbounded by any constaints
-1*lg_bound lg_bound;#amino acid#The constraints for all exchange reactions
-1*lg_bound lg_bound;#nNTP
-1*lg_bound lg_bound;#prot
-1*lg_bound lg_bound;#NMP
-1*lg_bound lg_bound;#ATP
-1*lg_bound lg_bound;#AMP
-1*lg_bound 9.999999999999;#GTP
-1*lg_bound lg_bound;#GDP
-1*lg_bound lg_bound]#Pi

Species_bounds = [gene_conc gene_conc; #gene
RNAP_conc RNAP_conc;#RNAP_conc
0 0;#Activated gene
.9E-3 .9E-3;#NTP
0 0;#mRNA
0 0;#Pi
0 0;#NMP
Ribo_conc Ribo_conc;#ribosome
0 0;#activated ribosome
0 0;#AAtRNA
.0015 .0015;#GTP
0 0;#tRNA
0 0;#GDP
0 0;#protein
0 0;#amino acid
.0015 .0015;#ATP
0 0]#AMP
#Maximizing translation rate
Objective_coefficient = [0.0; 0; 0; 0; -1; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0] #maximize the translation rate

optimize = calculate_optimal_flux_distribution(Stoich_Matrix, Bounds_matrix, Species_bounds, Objective_coefficient)



translation_rate =zeros(100)
Min_flag = true

for n in 1:100
    optimize = calculate_optimal_flux_distribution(Stoich_Matrix, Bounds_matrix, Species_bounds, Objective_coefficient)
    translation_rate[n] = -1 * optimize[1]
    #saving the optimized translation rate


end
