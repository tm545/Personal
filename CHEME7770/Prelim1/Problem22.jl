using LinearAlgebra

#Parameters
gene_number = 200 #copies per cell
char_length_gene = 1000 #nucleotides
char_length_polypeptide = 333 #amino acids
RNAP_number = 1150 #number per cell
Ribosome_number = 45000 #number per cell
doubling_time = 40 #min
weight_cell = 2.8E-13 #g/cell
water_fraction = .7
deg_mRNA = 2.1 #min
deg_prot = 24 #hrs
elongation_transcript = 60 #nt/s
kE_average_transcript = elongation_transcript / char_length_gene
elongation_translate = 16.5 #aa/s
kE_average_translate = elongation_translate / char_length_polypeptide
Kx = .24 #nmol/gDW
Kl = 454.64 #nmol/gDW
TI_X = 42 #sec (average initiation time of transcription)
TI_l = 15 #sec (average initiation time of translation)
Av_number = 6.02E23 #number/mol
I_on = 10 #mM
I_off = 0

#conversions to correct units
conversion = 1E9 / Av_number / weight_cell / (1-water_fraction) #conversion from copies per cell to nmol/gDW
gene_gDW = gene_number * conversion
RNAP_gDW = RNAP_number * conversion
Ribosome_gDW = Ribosome_number * conversion
mu = log(2)/ (doubling_time * 60) #in seconds
kd_m = log(2) / (deg_mRNA * 60) #in seconds
kd_p =  log(2) / (deg_prot* 3600) #in seconds
kI_X = 1 / TI_X
kI_l = 1 / TI_l


#Length factors
L1 = 1200 #nt
L2 = 2400 #nt
L3 = 600 #nt
Length_factor_1 = char_length_gene / L1
Length_factor_2 = char_length_gene / L2
Length_factor_3 = char_length_gene / L3
Lp1 = 400 #aa
Lp2 = 800 #aa
Lp3 = 200 #aa
Lp_factor_1 = char_length_polypeptide / Lp1
Lp_factor_2 = char_length_polypeptide / Lp2
Lp_factor_3 = char_length_polypeptide / Lp3
#kE calculation for each gene all in (sec^-1)
kE_1 = kE_average_transcript * Length_factor_1
kE_2 = kE_average_transcript * Length_factor_2
kE_3 = kE_average_transcript * Length_factor_3
kEp_1 = kE_average_translate * Lp_factor_1
kEp_2 = kE_average_translate * Lp_factor_2
kEp_3 = kE_average_translate * Lp_factor_3
#Tau calculation for each gene
Tau_1 = kE_1 / kI_X
Tau_2 = kE_2 / kI_X
Tau_3 = kE_3 / kI_X
Tau_p1 = kEp_1 / kI_l
Tau_p2 = kEp_2 / kI_l
Tau_p3 = kEp_3 / kI_l

#Initial values
M1 = 0.0
M2 = 0.0
M3 = 0.0
P1 = 0.0
P2 = 0.0
P3 = 0.0

#kinetic limits of transcription and translation
r_x1 = kE_1 * RNAP_gDW * gene_gDW / (Kx*Tau_1 + (Tau_1 + 1)*gene_gDW)
r_x2 = kE_2 * RNAP_gDW * gene_gDW / (Kx*Tau_2 + (Tau_2 + 1)*gene_gDW)
r_x3 = kE_3 * RNAP_gDW * gene_gDW / (Kx*Tau_3 + (Tau_3 + 1)*gene_gDW)
r_l1 = kEp_1 * Ribosome_gDW * M1 / (Kl*Tau_p1 + (Tau_p1 + 1)*M1)
r_l2 = kEp_2 * Ribosome_gDW * M2 / (Kl*Tau_p2 + (Tau_p2 + 1)*M2)
r_l3 = kEp_3 * Ribosome_gDW * M3 / (Kl*Tau_p1 + (Tau_p3 + 1)*M3)


#initial moon voigt parameters
f(j,k,n) = j^(n)/(k^(n)+j^(n))
W_background = 10E-7
W11= W_background
W22 = W_background
W33 = W_background
k_I = .3 #mM
K_else = .0001 #nmol/gDW
K_12 = K_else
K_13 = K_else
K_23 = .001
W_I1 = 100.0
W_12 = 10.0
W_13 = 5.0
W_23 = 25.0
n=1.5
n1=10.0
#u1_off = (W_background / (1+W_background))#without inducer
#u1_on = (W_background + W_I1*f(I_on,k_I))/(1+W_background + W_I1*f(I_on,k_I))#with inducer
#u2 = (W_background + W_12*f(P1,K_else))/(1+W_background + W_12*f(P1,K_else))
#u3 = (W_background + W_13*f(P1,K_else))/(1+W_background + W_13*f(P1,K_else) + W_23 * f1(P2,K_else))

include("Problem2_attemp2.jl")
#I could not figure out how to write a function to cycle through all my reactions rates (mostly in writing a preturbed reaction rate depending on which parameter I'm altering so I hard coded everything) and perturb a parameter so I apologize for everything below
#I'm cycling through 20 time points and calculating sensitivity caoefficients for each point and storing them inside matrices to then time average
window1=(X[10:29,1:6])#phase 1 window
M1_1 = window1[:,1]
P1_1 = window1[:,2]
M2_1 = window1[:,3]
P2_1 = window1[:,4]
M3_1 = window1[:,5]
P3_1 = window1[:,6]
window2=(X[70:89,1:6])#early phase 2 window
M1_2 = window2[:,1]
P1_2 = window2[:,2]
M2_2 = window2[:,3]
P2_2 = window2[:,4]
M3_2 = window2[:,5]
P3_2 = window2[:,6]
window3=(X[320:339,1:6])#late phase 2 window
M1_3 = window3[:,1]
P1_3 = window3[:,2]
M2_3 = window3[:,3]
P2_3 = window3[:,4]
M3_3 = window3[:,5]
P3_3 = window3[:,6]

#Initialize the sensitivty coefficent matrices for all states and parameters
fd_m1_w1=zeros(34,20)
fd_m2_w1=zeros(34,20)
fd_m3_w1=zeros(34,20)
fd_p1_w1=zeros(34,20)
fd_p2_w1=zeros(34,20)
fd_p3_w1=zeros(34,20)
fd_m1_w2=zeros(34,20)
fd_m2_w2=zeros(34,20)
fd_m3_w2=zeros(34,20)
fd_p1_w2=zeros(34,20)
fd_p2_w2=zeros(34,20)
fd_p3_w2=zeros(34,20)
fd_m1_w3=zeros(34,20)
fd_m2_w3=zeros(34,20)
fd_m3_w3=zeros(34,20)
fd_p1_w3=zeros(34,20)
fd_p2_w3=zeros(34,20)
fd_p3_w3=zeros(34,20)
#Parameter matrix to call from
Par = [kE_average_transcript char_length_gene L1 L2 L3 RNAP_gDW gene_gDW  Kx kI_X W11 W_I1 I_on k_I n W22 W_12 K_12 W33 W_13 K_13 W_23 K_23 n1 kE_average_translate char_length_polypeptide Lp1 Lp2 Lp3 Ribosome_gDW Kl kI_l kd_m kd_p mu]
#Calculation of each state in terms of the parameters within the par matrix and their own states
calc_state_m1_w1(x) = Par[1] * Par[2]/Par[3] * Par[6] * Par[7] / (Par[8]*Par[1]*Par[2]/(Par[3]*Par[9])+(1 + Par[1]*Par[2]/(Par[3]*Par[9]))*Par[7]) * (Par[10] + Par[11]*f(0, Par[13], Par[14]))/ (1+Par[10] + Par[11]*f(0, Par[13], Par[14])) - (Par[32]+Par[34])*M1_1[x]
calc_state_m1_w2(x) = Par[1] * Par[2]/Par[3] * Par[6] * Par[7] / (Par[8]*Par[1]*Par[2]/(Par[3]*Par[9])+(1 + Par[1]*Par[2]/(Par[3]*Par[9]))*Par[7]) * (Par[10] + Par[11]*f(Par[12], Par[13], Par[14]))/ (1+Par[10] + Par[11]*f(Par[12], Par[13], Par[14])) - (Par[32]+Par[34])*M1_2[x]
calc_state_m1_w3(x) = Par[1] * Par[2]/Par[3] * Par[6] * Par[7] / (Par[8]*Par[1]*Par[2]/(Par[3]*Par[9])+(1 + Par[1]*Par[2]/(Par[3]*Par[9]))*Par[7]) * (Par[10] + Par[11]*f(Par[12], Par[13], Par[14]))/ (1+Par[10] + Par[11]*f(Par[12], Par[13], Par[14])) - (Par[32]+Par[34])*M1_3[x]
calc_state_m2_w1(x) =  Par[1] * Par[2]/Par[4] * Par[6] * Par[7] / (Par[8]*Par[1]*Par[2]/(Par[4]*Par[9])+(1 + Par[1]*Par[2]/(Par[4]*Par[9]))*Par[7]) * (Par[15]+Par[16]*f(P1_1[x],Par[17], Par[14]))/(1+Par[15]+Par[16]*f(P1_1[x],Par[17], Par[14])) - (Par[32]+Par[34])*M2_1[x]
calc_state_m2_w2(x) =  Par[1] * Par[2]/Par[4] * Par[6] * Par[7] / (Par[8]*Par[1]*Par[2]/(Par[4]*Par[9])+(1 + Par[1]*Par[2]/(Par[4]*Par[9]))*Par[7]) * (Par[15]+Par[16]*f(P1_2[x],Par[17], Par[14]))/(1+Par[15]+Par[16]*f(P1_2[x],Par[17], Par[14])) - (Par[32]+Par[34])*M2_2[x]
calc_state_m2_w3(x) =  Par[1] * Par[2]/Par[4] * Par[6] * Par[7] / (Par[8]*Par[1]*Par[2]/(Par[4]*Par[9])+(1 + Par[1]*Par[2]/(Par[4]*Par[9]))*Par[7]) * (Par[15]+Par[16]*f(P1_3[x],Par[17], Par[14]))/(1+Par[15]+Par[16]*f(P1_3[x],Par[17], Par[14])) - (Par[32]+Par[34])*M2_3[x]
calc_state_m3_w1(x) = Par[1] * Par[2]/Par[5] * Par[6] * Par[7] / (Par[8]*Par[1]*Par[2]/(Par[5]*Par[9])+(1 + Par[1]*Par[2]/(Par[5]*Par[9]))*Par[7]) * (Par[18]+Par[19]*f(P1_1[x],Par[20], Par[14]))/(1+Par[18]+Par[19]*f(P1_1[x],Par[20], Par[14])+Par[21]*f(P2_1[x],Par[22], Par[23])) - (Par[32]+Par[34])*M3_1[x]
calc_state_m3_w2(x) = Par[1] * Par[2]/Par[5] * Par[6] * Par[7] / (Par[8]*Par[1]*Par[2]/(Par[5]*Par[9])+(1 + Par[1]*Par[2]/(Par[5]*Par[9]))*Par[7]) * (Par[18]+Par[19]*f(P1_2[x],Par[20], Par[14]))/(1+Par[18]+Par[19]*f(P1_2[x],Par[20], Par[14])+Par[21]*f(P2_2[x],Par[22], Par[23])) - (Par[32]+Par[34])*M3_2[x]
calc_state_m3_w3(x) = Par[1] * Par[2]/Par[5] * Par[6] * Par[7] / (Par[8]*Par[1]*Par[2]/(Par[5]*Par[9])+(1 + Par[1]*Par[2]/(Par[5]*Par[9]))*Par[7]) * (Par[18]+Par[19]*f(P1_3[x],Par[20], Par[14]))/(1+Par[18]+Par[19]*f(P1_3[x],Par[20], Par[14])+Par[21]*f(P2_3[x],Par[22], Par[23])) - (Par[32]+Par[34])*M3_3[x]
calc_state_p1_w1(x) = Par[24] * Par[25]/Par[26] *Par[29] * calc_state_m1_w1(x) / (Par[30]*Par[24]*Par[25]/(Par[26]*Par[31])+(1+(Par[24]*Par[25]/(Par[26]*Par[31])))*calc_state_m1_w1(x)) - (Par[33]+Par[34])*P1_1[x]
calc_state_p1_w2(x) = Par[24] * Par[25]/Par[26] *Par[29] * calc_state_m1_w2(x) / (Par[30]*Par[24]*Par[25]/(Par[26]*Par[31])+(1+(Par[24]*Par[25]/(Par[26]*Par[31])))*calc_state_m1_w2(x)) - (Par[33]+Par[34])*P1_2[x]
calc_state_p1_w3(x) = Par[24] * Par[25]/Par[26] *Par[29] * calc_state_m1_w3(x) / (Par[30]*Par[24]*Par[25]/(Par[26]*Par[31])+(1+(Par[24]*Par[25]/(Par[26]*Par[31])))*calc_state_m1_w3(x)) - (Par[33]+Par[34])*P1_3[x]
calc_state_p2_w1(x) = Par[24] * Par[25]/Par[27] *Par[29] * calc_state_m2_w1(x) / (Par[30]*Par[24]*Par[25]/(Par[27]*Par[31])+(1+(Par[24]*Par[25]/(Par[27]*Par[31])))*calc_state_m2_w1(x)) - (Par[33]+Par[34])*P2_1[x]
calc_state_p2_w2(x) = Par[24] * Par[25]/Par[27] *Par[29] * calc_state_m2_w2(x) / (Par[30]*Par[24]*Par[25]/(Par[27]*Par[31])+(1+(Par[24]*Par[25]/(Par[27]*Par[31])))*calc_state_m2_w2(x)) - (Par[33]+Par[34])*P2_2[x]
calc_state_p2_w3(x) = Par[24] * Par[25]/Par[27] *Par[29] * calc_state_m2_w3(x) / (Par[30]*Par[24]*Par[25]/(Par[27]*Par[31])+(1+(Par[24]*Par[25]/(Par[27]*Par[31])))*calc_state_m2_w3(x)) - (Par[33]+Par[34])*P2_3[x]
calc_state_p3_w1(x) = Par[24] * Par[25]/Par[28] *Par[29] * calc_state_m3_w1(x) / (Par[30]*Par[24]*Par[25]/(Par[28]*Par[31])+(1+(Par[24]*Par[25]/(Par[28]*Par[31])))*calc_state_m3_w1(x)) - (Par[33]+Par[34])*P3_1[x]
calc_state_p3_w2(x) = Par[24] * Par[25]/Par[28] *Par[29] * calc_state_m3_w2(x) / (Par[30]*Par[24]*Par[25]/(Par[28]*Par[31])+(1+(Par[24]*Par[25]/(Par[28]*Par[31])))*calc_state_m3_w2(x)) - (Par[33]+Par[34])*P3_2[x]
calc_state_p3_w3(x) = Par[24] * Par[25]/Par[28] *Par[29] * calc_state_m3_w3(x) / (Par[30]*Par[24]*Par[25]/(Par[28]*Par[31])+(1+(Par[24]*Par[25]/(Par[28]*Par[31])))*calc_state_m3_w3(x)) - (Par[33]+Par[34])*P3_3[x]
calc_state_m1_w1(x) = Par[1] * Par[2]/Par[3] * Par[6] * Par[7] / (Par[8]*Par[1]*Par[2]/(Par[3]*Par[9])+(1 + Par[1]*Par[2]/(Par[3]*Par[9]))*Par[7]) * (Par[10] + Par[11]*f(0, Par[13], Par[14]))/ (1+Par[10] + Par[11]*f(0, Par[13], Par[14])) - (Par[32]+Par[34])*M1_1[x]
calc_state_m1_w2(x) = Par[1] * Par[2]/Par[3] * Par[6] * Par[7] / (Par[8]*Par[1]*Par[2]/(Par[3]*Par[9])+(1 + Par[1]*Par[2]/(Par[3]*Par[9]))*Par[7]) * (Par[10] + Par[11]*f(Par[12], Par[13], Par[14]))/ (1+Par[10] + Par[11]*f(Par[12], Par[13], Par[14])) - (Par[32]+Par[34])*M1_2[x]
calc_state_m1_w3(x) = Par[1] * Par[2]/Par[3] * Par[6] * Par[7] / (Par[8]*Par[1]*Par[2]/(Par[3]*Par[9])+(1 + Par[1]*Par[2]/(Par[3]*Par[9]))*Par[7]) * (Par[10] + Par[11]*f(Par[12], Par[13], Par[14]))/ (1+Par[10] + Par[11]*f(Par[12], Par[13], Par[14])) - (Par[32]+Par[34])*M1_3[x]
calc_state_m2_w1(x) =  Par[1] * Par[2]/Par[4] * Par[6] * Par[7] / (Par[8]*Par[1]*Par[2]/(Par[4]*Par[9])+(1 + Par[1]*Par[2]/(Par[4]*Par[9]))*Par[7]) * (Par[15]+Par[16]*f(calc_state_p1_w1(x),Par[17], Par[14]))/(1+Par[15]+Par[16]*f(calc_state_p1_w1(x),Par[17], Par[14])) - (Par[32]+Par[34])*M2_1[x]
calc_state_m2_w2(x) =  Par[1] * Par[2]/Par[4] * Par[6] * Par[7] / (Par[8]*Par[1]*Par[2]/(Par[4]*Par[9])+(1 + Par[1]*Par[2]/(Par[4]*Par[9]))*Par[7]) * (Par[15]+Par[16]*f(calc_state_p1_w2(x),Par[17], Par[14]))/(1+Par[15]+Par[16]*f(calc_state_p1_w2(x),Par[17], Par[14])) - (Par[32]+Par[34])*M2_2[x]
calc_state_m2_w3(x) =  Par[1] * Par[2]/Par[4] * Par[6] * Par[7] / (Par[8]*Par[1]*Par[2]/(Par[4]*Par[9])+(1 + Par[1]*Par[2]/(Par[4]*Par[9]))*Par[7]) * (Par[15]+Par[16]*f(calc_state_p1_w3(x),Par[17], Par[14]))/(1+Par[15]+Par[16]*f(calc_state_p1_w3(x),Par[17], Par[14])) - (Par[32]+Par[34])*M2_3[x]
calc_state_m3_w1(x) = Par[1] * Par[2]/Par[5] * Par[6] * Par[7] / (Par[8]*Par[1]*Par[2]/(Par[5]*Par[9])+(1 + Par[1]*Par[2]/(Par[5]*Par[9]))*Par[7]) * (Par[18]+Par[19]*f(calc_state_p1_w1(x),Par[20], Par[14]))/(1+Par[18]+Par[19]*f(calc_state_p1_w1(x),Par[20], Par[14])+Par[21]*f(calc_state_p2_w1(x),Par[22], Par[23])) - (Par[32]+Par[34])*M3_1[x]
calc_state_m3_w2(x) = Par[1] * Par[2]/Par[5] * Par[6] * Par[7] / (Par[8]*Par[1]*Par[2]/(Par[5]*Par[9])+(1 + Par[1]*Par[2]/(Par[5]*Par[9]))*Par[7]) * (Par[18]+Par[19]*f(calc_state_p1_w2(x),Par[20], Par[14]))/(1+Par[18]+Par[19]*f(calc_state_p1_w2(x),Par[20], Par[14])+Par[21]*f(calc_state_p2_w2(x),Par[22], Par[23])) - (Par[32]+Par[34])*M3_2[x]
calc_state_m3_w3(x) = Par[1] * Par[2]/Par[5] * Par[6] * Par[7] / (Par[8]*Par[1]*Par[2]/(Par[5]*Par[9])+(1 + Par[1]*Par[2]/(Par[5]*Par[9]))*Par[7]) * (Par[18]+Par[19]*f(calc_state_p1_w3(x),Par[20], Par[14]))/(1+Par[18]+Par[19]*f(calc_state_p1_w3(x),Par[20], Par[14])+Par[21]*f(calc_state_p2_w3(x),Par[22], Par[23])) - (Par[32]+Par[34])*M3_3[x]
#Finite difference for all states in each window calculated
function fd_mRNA1_w1(Parameters)
   for p in 1:34
      for t in 1:20
         A0 = calc_state_m1_w1(t)#unperturbed
         Parameters[p] = (Parameters[p]) * 1.05
         A1 = calc_state_m1_w1(t)#perturbed
         unperturb(Parameters[p])
         fd_m1_w1[p,t] = A1-A0 #difference in state by perturbation of parameter
      end
      fd_m1_w1[p,:]/(Parameters[p]*.05)#dividing by the h portion of finite difference
   end

   return fd_m1_w1
end
function fd_mRNA1_w2(Parameters)
   for p in 1:34
      for t in 1:20
         A0 = calc_state_m1_w2(t)
         Parameters[p] = (Parameters[p])*1.05
         A1 = calc_state_m1_w2(t)
         Parameters[p] = (Parameters[p]) / 1.05
         fd_m1_w2[p,t] = (A1-A0)/(A0*.05)
      end
   end
   return fd_m1_w2
end
function fd_mRNA1_w3(Parameters)
   for p in 1:34
      for t in 1:20
         A0 = calc_state_m1_w3(t)
         Parameters[p] = (Parameters[p]) * 1.05
         A1 = calc_state_m1_w3(t)
         Parameters[p] = (Parameters[p]) / 1.05
         fd_m1_w3[p,t] = (A1-A0)/(A0*.05) #finite difference with scalar term
      end
   end
   return fd_m1_w3
end
function fd_mRNA2_w1(Parameters)
   for p in 1:34
      for t in 1:20
         A0 = calc_state_m2_w1(t)
         Parameters[p] = (Parameters[p]) * 1.05
         A1 = calc_state_m2_w1(t)
         Parameters[p] = (Parameters[p]) / 1.05
         fd_m2_w1[p,t] = A1-A0
      end
      fd_m2_w1[p,:]/(Parameters[p]*.05)
   end
   return fd_m2_w1
end
function fd_mRNA2_w2(Parameters)
   for p in 1:34
      for t in 1:20
         A0 = calc_state_m2_w2(t)
         Parameters[p] = (Parameters[p]) * 1.05
         A1 = calc_state_m2_w2(t)
         Parameters[p] = (Parameters[p]) / 1.05
         fd_m2_w2[p,t] = (A1-A0)/(A0*.05)
      end
   end
   return fd_m2_w2
end
function fd_mRNA2_w3(Parameters)
   for p in 1:34
      for t in 1:20
         A0 = calc_state_m2_w3(t)
         Parameters[p] = (Parameters[p]) * 1.05
         A1 = calc_state_m2_w3(t)
         Parameters[p] = (Parameters[p]) / 1.05
         fd_m2_w3[p,t] = (A1-A0)/(A0*.05)
      end
   end
   return fd_m2_w3
end
function fd_mRNA3_w1(Parameters)
   for p in 1:34
      for t in 1:20
         A0 = calc_state_m3_w1(t)
         Parameters[p] = (Parameters[p]) * 1.05
         A1 = calc_state_m3_w1(t)
         Parameters[p] = (Parameters[p]) / 1.05
         fd_m3_w1[p,t] = A1-A0
      end
      fd_m3_w1[p,:]/(Parameters[p]*.05)
   end
   return fd_m3_w1
end
function fd_mRNA3_w2(Parameters)
   for p in 1:34
      for t in 1:20
         A0 = calc_state_m3_w2(t)
         Parameters[p] = (Parameters[p]) * 1.05
         A1 = calc_state_m3_w2(t)
         Parameters[p] = (Parameters[p]) / 1.05
         fd_m3_w2[p,t] = (A1-A0)/(A0*.05)
      end
   end
   return fd_m3_w2
end
function fd_mRNA3_w3(Parameters)
   for p in 1:34
      for t in 1:20
         A0 = calc_state_m3_w3(t)
         Parameters[p] = (Parameters[p]) * 1.05
         A1 = calc_state_m3_w3(t)
         Parameters[p] = (Parameters[p]) / 1.05
         fd_m3_w3[p,t] = (A1-A0)/(A0*.05)
      end
   end
   return fd_m3_w3
end
function fd_prot1_w1(Parameters)
   for p in 1:34
      for t in 1:20
         A0 = calc_state_p1_w1(t)
         Parameters[p] = (Parameters[p]) * 1.05
         A1 = calc_state_p1_w1(t)
         Parameters[p] = (Parameters[p]) / 1.05
         fd_p1_w1[p,t] = A1-A0
      end
      fd_p1_w1[p,:]/(Parameters[p]*.05)
   end
   return fd_p1_w1
end
function fd_prot1_w2(Parameters)
   for p in 1:34
      for t in 1:20
         A0 = calc_state_p1_w2(t)
         Parameters[p] = (Parameters[p]) * 1.05
         A1 = calc_state_p1_w2(t)
         Parameters[p] = (Parameters[p]) / 1.05
         fd_p1_w2[p,t] = (A1-A0)/(A0*.05)
      end
   end
   return fd_p1_w2
end
function fd_prot1_w3(Parameters)
   for p in 1:34
      for t in 1:20
         A0 = calc_state_p1_w3(t)
         Parameters[p] = (Parameters[p]) * 1.05
         A1 = calc_state_p1_w3(t)
         Parameters[p] = (Parameters[p]) / 1.05
         fd_p1_w3[p,t] = (A1-A0)/(A0*.05)
      end
   end
   return fd_p1_w3
end
function fd_prot2_w1(Parameters)
   for p in 1:34
      for t in 1:20
         A0 = calc_state_p2_w1(t)
         Parameters[p] = (Parameters[p]) * 1.05
         A1 = calc_state_p2_w1(t)
         Parameters[p] = (Parameters[p]) / 1.05
         fd_p2_w1[p,t] = A1-A0
      end
      fd_p2_w1[p,:]/(Parameters[p]*.05)
   end
   return fd_p2_w1
end
function fd_prot2_w2(Parameters)
   for p in 1:34
      for t in 1:20
         A0 = calc_state_p2_w2(t)
         Parameters[p] = (Parameters[p]) * 1.05
         A1 = calc_state_p2_w2(t)
         Parameters[p] = (Parameters[p]) / 1.05
         fd_p2_w2[p,t] = (A1-A0)/(A0*.05)
      end
   end
   return fd_p2_w2
end
function fd_prot2_w3(Parameters)
   for p in 1:34
      for t in 1:20
         A0 = calc_state_p2_w3(t)
         Parameters[p] = (Parameters[p]) * 1.05
         A1 = calc_state_p2_w3(t)
         Parameters[p] = (Parameters[p]) / 1.05
         fd_p2_w3[p,t] = (A1-A0)/(A0*.05)
      end
   end
   return fd_p2_w3
end
function fd_prot3_w1(Parameters)
   for p in 1:34
      for t in 1:20
         A0 = calc_state_p3_w1(t)
         Parameters[p] = (Parameters[p]) * 1.05
         A1 = calc_state_p3_w1(t)
         Parameters[p] = (Parameters[p]) / 1.05
         fd_p3_w1[p,t] = A1-A0
      end
      fd_p3_w1[p,:]/(Parameters[p]*.05)
   end
   return fd_p3_w1
end
function fd_prot3_w2(Parameters)
   for p in 1:34
      for t in 1:20
         A0 = calc_state_p3_w2(t)
         Parameters[p] = (Parameters[p]) * 1.05
         A1 = calc_state_p3_w2(t)
         Parameters[p] = (Parameters[p]) / 1.05
         fd_p3_w2[p,t] = (A1-A0)/(A0*.05)
      end
   end
   return fd_p3_w2
end
function fd_prot3_w3(Parameters)
   for p in 1:34
      for t in 1:20
         A0 = calc_state_p3_w3(t)
         Parameters[p] = (Parameters[p]) * 1.05
         A1 = calc_state_p3_w3(t)
         Parameters[p] = (Parameters[p]) / 1.05
         fd_p3_w3[p,t] = (A1-A0)/(A0*.05)
      end
   end
   return fd_p3_w3
end

fd_mRNA1_w1(Par)
fd_mRNA2_w1(Par)
fd_mRNA3_w1(Par)
fd_prot1_w1(Par)
fd_prot2_w1(Par)
fd_prot3_w1(Par)
fd_mRNA1_w2(Par)
fd_mRNA2_w2(Par)
fd_mRNA3_w2(Par)
fd_prot1_w2(Par)
fd_prot2_w2(Par)
fd_prot3_w2(Par)
fd_mRNA1_w3(Par)
fd_mRNA2_w3(Par)
fd_mRNA3_w3(Par)
fd_prot1_w3(Par)
fd_prot2_w3(Par)
fd_prot3_w3(Par)



#2c
#could not import the simple lac operon example as a package unfortunately
#Solution modelled from the time_average_array function adapted from the Lac operon example
#Both functions taken from Varner lab github from the Lac Operon repository Utility.jl file
function trapz(x, y)
    # Trapezoidal integration rule
    local n = length(x)
    if (length(y) != n)
        error("Vectors 'x', 'y' must be of same length")
    end
    r = zero(zero(20) + zero(20))
    if n == 1; return r; end
    for i in 2:n
        r += (x[i] - x[i-1]) * (y[i] + y[i-1])
    end
    return r/2
end

function time_average_array(time_array,data_array)

  # what is the delta T?
  delta_time = (time_array[end] - time_array[1])

  # initialize -
  average_array = Float64[]

  # what is the size of the array?
  (number_of_states,number_of_timesteps) = size(data_array)
  for state_index = 1:number_of_states

    # grab the data row -
    data_row = data_array[state_index,:]

    # average -
    average_value = (1/delta_time)*trapz(time_array,data_row)

    # push -
    push!(average_array,average_value)
  end

  return average_array

end

#Time averaging all the sensitivity coefficients with the trapezoid integration rule
time_window1 = collect(20:39)
m1_w1_avg = time_average_array(time_window1', fd_m1_w1)
m2_w1_avg = time_average_array(time_window1', fd_m2_w2)
m3_w1_avg = time_average_array(time_window1', fd_m3_w3)
p1_w1_avg = time_average_array(time_window1', fd_p1_w1)
p2_w1_avg = time_average_array(time_window1', fd_p2_w1)
p3_w1_avg = time_average_array(time_window1', fd_p3_w1)
time_window2= collect(100:119)
m1_w2_avg = time_average_array(time_window2', fd_m1_w2)
m2_w2_avg = time_average_array(time_window2', fd_m2_w2)
m3_w2_avg = time_average_array(time_window2', fd_m3_w2)
p1_w2_avg = time_average_array(time_window2', fd_p1_w2)
p2_w2_avg = time_average_array(time_window2', fd_p2_w2)
p3_w2_avg = time_average_array(time_window2', fd_p3_w2)
time_window3 = collect(320:339)
m1_w3_avg = time_average_array(time_window3', fd_m1_w3)
m2_w3_avg = time_average_array(time_window3', fd_m2_w3)
m3_w3_avg = time_average_array(time_window3', fd_m3_w3)
p1_w3_avg = time_average_array(time_window3', fd_p1_w3)
p2_w3_avg = time_average_array(time_window3', fd_p2_w3)
p3_w3_avg = time_average_array(time_window3', fd_p3_w3)
#Placing all states from the same windows into a single network matrix
network_w1 = [m1_w1_avg m2_w1_avg m3_w1_avg p1_w1_avg p2_w1_avg p3_w1_avg]
network_w2 = [m1_w2_avg m2_w2_avg m3_w2_avg p1_w2_avg p2_w2_avg p3_w2_avg]
network_w3 = [m1_w3_avg m2_w3_avg m3_w3_avg p1_w3_avg p2_w3_avg p3_w3_avg]
#using singular value decomposition
W1 = svdvals(network_w1)
W2 = svdvals(network_w2)
W3 = svdvals(network_w3)
#absolute value of the first column of each U matrix
abs_mag1 = LinearAlgebra.norm(W1)
abs_mag2 = LinearAlgebra.norm(W2)
abs_mag3 = LinearAlgebra.norm(W3)
#A scaled matrix of
sol_w1 =network_w1 / abs_mag1
sol_w2 =network_w2 / abs_mag2
sol_w3 = network_w3 / abs_mag3

#Final solution
