include("Flux.jl")

Stoich_Matrix =
[-1.0	1	0	0	0	0	0	0	0	0	0	0	0	0	0; #Gene
-1	1	0	0	0	0	0	0	0	0	0	0	0	0	0; #RNAP
1	-1	0	0	0	0	0	0	0	0	0	0	0	0	0; #Activated gene
0	-924	0	0	0	0	0	1	0	0	0	0	0	0	0; #NTP
0	1	-1	-1	1	0	0	0	0	0	0	0	0	0	0; #mRNA
0	1848	0	0	616	2	0	0	0	0	0	0	0	0	-1; #Pi
0	0	924	0	0	0	0	0	0	-1	0	0	0	0	0; #NMP
0	0	0	-1	1	0	0	0	0	0	0	0	0	0	0; #ribosome
0	0	0	1	-1	0	0	0	0	0	0	0	0	0	0; #activated ribosome
0	0	0	0	-308	1	0	0	0	0	0	0	0	0	0; #AAtRNA
0	0	0	0	-616	0	0	0	0	0	0	0	1	0	0; #GTP
0	0	0	0	308	-1	0	0	0	0	0	0	0	0	0; #tRNA
0	0	0	0	616	0	0	0	0	0	0	0	0	-1	0; #GDP
0	0	0	0	1	0	0	0	-1	0	0	0	0	0	0; #protein
0	0	0	0	0	-1	1	0	0	0	0	0	0	0	0; #amino acid
0	0	0	0	0	-1	0	0	0	0	1	0	0	0	0; #ATP
0	0	0	0	0	1	0	0	0	0	0	-1	0	0	0] #AMP

RNAP_conc = .15 #uM
Ribo_conc = 1.6 #uM
E_x = 60.0 #nt/sec NOT ACTUAL KE
E_l = 16.5 #aa/sec NOT ACTUAL KE
K_x = .3 #uM
K_l = 57.0 #uM
tau_x = 2.7
tau_l = .8
kd_xh = 8.35 #1/hr
kd_x = kd_xh / 3600 #1/sec
kd_m = log(2) / kd_x
kd_lh = .0099 #1/hr
kd_l = kd_lh = kd_lh /3600 #1/sec
kd_p = log(2) / kd_l
L_x = 1000 #nt (characteristic length of genes)
L_l = 330 #aa (characteristic length of polypeptide)
Lx = 924 #nt (actual length of gene)
Ll = 308 #aa (actual length of polypeptide)
L_factor = L_x/Lx
Lp_factor = L_l/Ll
gene_conc = 5E-3 #uM
kE_x = E_x / L_x *L_factor
kE_l = E_l / L_l * Lp_factor
kI_x = kE_x / tau_x
kI_l = kE_l / tau_l
#v2
kinetic_limit_transcript_unregulated = kE_x * RNAP_conc * gene_conc / (K_x*tau_x+(tau_x+1)*gene_conc) #Fully constrained equation for v2
I_conc = .0001 #mM
n = 1.5
K = .30 #mM
f(I) = I^n / (K^n+I^n)
moon_voigt(I) = (.26 + 300 * f(I))/(1+.26+300*f(I))
#From assuming the change in mRNA concentration is 0 we can derive the following equation for steady state mRNA concentration


#v5
mRNA_conc(I_conc) = kinetic_limit_transcript_unregulated* moon_voigt(I_conc)/kd_x
kinetic_limit_translate(I_conc) = kE_l * Ribo_conc *mRNA_conc(I_conc)/ (K_l*tau_l+ (tau_l+1)*mRNA_conc(I_conc))

#No other data is presented for constraints for equations
largest_bound = 100000.0 #an upper bound for equations with no constraints in uM/hr
lg_bound = largest_bound / (3600) #uM/sec
inf = 999999.99 #unconstrained reaction

Bounds_matrix = [-1*inf inf; #v1 is unbounded by any constraints
kinetic_limit_transcript_unregulated * moon_voigt(I_conc)   kinetic_limit_transcript_unregulated * moon_voigt(I_conc);#kinetic_limit_transcript
0 kd_x;#v3 is  bound by knowing the rate of degradation but not knowing the mRNA concentration present
0 kI_l;#v4 is unbounded by equations
0 kinetic_limit_translate(I_conc);#v5 bounded by the kinetic limit of translation only as an upper bound
0 inf;#v6 is unbounded by any constaints
-1*lg_bound lg_bound;#The constraints for all exchange reactions
-1*lg_bound lg_bound;
-1*lg_bound lg_bound;
-1*lg_bound lg_bound;
-1*lg_bound lg_bound;
-1*lg_bound lg_bound;
-1*lg_bound lg_bound;
-1*lg_bound lg_bound;
-1*lg_bound lg_bound]

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
0 0]
#Maximizing translation rate
Objective_coefficient = [0.0; 0; 0; 0; -1; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0] #maximize the translation rate


translation_rate =zeros(100)
Inducer_conc = zeros(100)
Min_flag = true

for n in 1:100
    optimize = calculate_optimal_flux_distribution(Stoich_Matrix, Bounds_matrix, Species_bounds, Objective_coefficient)
    translation_rate[n] = -1 * optimize[1]
    #saving the optimized translation rate
    Bounds_matrix[2,2] = kinetic_limit_transcript_unregulated * moon_voigt(I_conc*1.122^n)
    Bounds_matrix[5,2] =  kinetic_limit_translate(I_conc*1.122^n)
    Inducer_conc[n]=I_conc*1.122^n
end


using PyPlot

semilogx(Inducer_conc, translation_rate,"black",linewidth=2)
xlabel("Log(Inducer [mM])")
ylabel("Translation rate [uM/s]")

#3c

#reset the Bounds matrix
Bounds_matrix[2,2] = kinetic_limit_transcript_unregulated * moon_voigt(I_conc)
Bounds_matrix[5,2] =  kinetic_limit_translate(I_conc)
trans_rate = zeros(9)
base_line = calculate_optimal_flux_distribution(Stoich_Matrix, Bounds_matrix, Species_bounds, Objective_coefficient)
bl = -1 * base_line[1]
for n in 7:15
    Bounds_matrix[n,:] = [-.001, .001]#altering the bounds by 1/10 of the maximum
    holder = calculate_optimal_flux_distribution(Stoich_Matrix, Bounds_matrix, Species_bounds, Objective_coefficient)#storing the translation rate
    trans_rate[n-6] = -1 * holder[1]
    Bounds_matrix[n,:] = [-1*lg_bound, lg_bound] #resetting that row
end

println(extreme_shadow_price = trans_rate / bl)
