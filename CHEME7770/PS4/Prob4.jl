using LinearAlgebra
using ODE
#initial conditions
x0 = [10.0
    0.0
    0.0
    2.0
    0.0
    0.0
    0.0]



function Balances(t,x)
#parameters
Etot=10
CheR=0.2
CheB=2
kr=0.1
VRMax=kr*CheR
if t > 0
    L = .01
else
    L = 0
end
a_plus=1/(1+L)
a_min=L/(L+1)
b1=2.5*L/(1+L)
abp=100#s^-1uM^-1
dbp=0.01
kbp=1
ab=000#s^-1uM^-1
db=1
kb=0
k_minus=0
k_plus=0
#species
E0=x[1]
E1=x[2];
E1star=x[3]
B=x[4]
Bp=x[5]
E1B=x[6]
E1Bp=x[7]
#differntials
dxdt = similar(x)
dxdt[1]=kbp*E1Bp+kb*E1B-VRMax
dxdt[2]=a_min*E1star-a_plus*E1+VRMax+E1B*b1+E1Bp*b1
dxdt[3]=a_plus*E1-a_min*E1star-E1star*Bp*abp+E1Bp*dbp-E1star*B*ab+E1B*db
dxdt[4]=-ab*E1star*B+kb*E1B+E1B*b1+db*E1B+k_minus*Bp-k_plus*E1star*B
dxdt[5]=-abp*E1star*Bp+(kbp+b1+dbp)*E1Bp-k_minus*Bp+k_plus*E1star*B
dxdt[6]=-db*E1B+ab*E1star*B-b1*E1B-kb*E1B
dxdt[7]=-dbp*E1Bp+abp*E1star*Bp-b1*E1Bp-kbp*E1Bp
dxdt
end


f(t,x) = Balances(t,x)
#time step
tStart = -10
tStep = .1
tStop = 1000
tSim = collect(tStart:tStep:tStop)
#ode solver
t,X = ode45(f, x0,tSim; points =:specified)
#vector of E1star over time
E1star = [a[3] for a in X]
#plotting
using PyPlot
figure(1)
plot(tSim,E1star)
