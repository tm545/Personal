using LinearAlgebra
using PyPlot
#Parameters
n_1 = 1.0
n_2 = 2.0
ss_1 = (-1+41^(1/2))/2
ss_2 = 2.0
a = 10.0
#nullclines question 2b
u_1 = collect(0:.1:11)
f_1 = zeros(111)
g_1 = zeros(111)
f_2 = zeros(111)
g_2 = zeros(111)
for f in 1:111
    f_1[f] = a/(1+u_1[f]^n_1)
    g_1[f] = a/(1+u_1[f]^n_1)
    f_2[f] = a/(1+u_1[f]^n_2)
    g_2[f] = a/(1+u_1[f]^n_2)
end
figure(1)
plot(u_1,f_1)
plot(g_1,u_1)
figure(2)
plot(u_1,f_2)
plot(g_2,u_1)
#Streamplot Question2c
minval = 0
maxval = 12
steps = 100
X = repeat(range(minval,stop=maxval,length=steps)',steps)
Y = repeat(range(minval,stop=maxval,length=steps),1,steps)
U = a ./(1 .+ X) .- Y
V = a ./(1 .+ Y) .- X
U_2 = a ./(1 .+ X.^2) .- Y
V_2 = a ./(1 .+ Y.^2) .- X
figure(3)
subplot(211)
streamplot(X,Y,U,V)
ylabel("V")
subplot(212)
streamplot(X,Y,U_2,V_2)
xlabel("U")
ylabel("V")
#Evaluation for parts of Question 2d
v_ss =(-1+41^(1/2))/2#Steady state value at n=1
J = [-1 -10/(v_ss+1)^2; -10/(v_ss+1)^2 -1] #jacobian in the case of n=1
J_2 = [-1 -40/25; -40/25 -1]#Jacobian in the case of n=2
println(eigvals(J))#Just checking
println(eigvals(J_2))#Just checking
println((tr(J)+(tr(J)^2-4*det(J))^(1/2))/2)
println((tr(J)-(tr(J)^2-4*det(J))^(1/2))/2)
println((tr(J_2)+(tr(J_2)^2-4*det(J_2))^(1/2))/2)
println((tr(J_2)-(tr(J_2)^2-4*det(J_2))^(1/2))/2)
