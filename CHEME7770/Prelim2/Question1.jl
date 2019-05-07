#Question 1
using NLsolve
using LinearAlgebra
using Plots
#parameters
Vm1 = 5.0
Vm2 = 5.0
Vm3 = 1.0
Vm4 = 1.0
Ks1 = 5.0
Ks2 = 5.0
Ks3 = 5.0
Ks4 = 5.0
Ki1 = 1.0
Ki2 = 1.0
I1 = 0.0
I2 = 0.0
Stot = 100.0

#Writing out functions
f1(x) = Vm1 * x / (1 + I1/Ki1)*(Ks1 + x)
f2(x) = Vm2 * x / (1 + I2/Ki2)*(Ks2+x)
f3(x) = Vm3 * x / (Ks3 + x)
f4(x) = Vm4 * x / (Ks4 + x)

#x[1] = A
#x[2] = B
#x[3] = C

#system of equations
function f!(F,x)
    F[1] = f3(x[2]) + f4(x[3]) - f1(x[1]) - f1(x[1])
    F[2] = f1(x[1]) - f3(x[2])
    F[3] = f2(x[1]) - f4(x[3])
    F[4] = x[1] + x[2] + x[3] - Stot
    F[5] = x[4] + x[5] # dummy equation with two dummy variables to make the system of equations a square
end

root = nlsolve(f!, [0.0,100.0,100.0,0.0,0.0])
println(root.zero[1:3])
multiple = 10^(1/10)
solution = zeros(51,51)
inhibitor_1 = zeros(51)
inhibitor_2 = zeros(51)
inhibitor_2[1]=.01
for i in 1:51
    I1 = .01 * multiple ^ (i-1)
    inhibitor_1[i] = I1
    I2 = .01
    f1(x) = Vm1 * x / (1 + I1/Ki1)*(Ks1 + x)
    f2(x) = Vm2 * x / (1 + I2/Ki2)*(Ks2+x)
    f3(x) = Vm3 * x / (Ks3 + x)
    f4(x) = Vm4 * x / (Ks4 + x)
    function f!(F,x)
        F[1] = f3(x[2]) + f4(x[3]) - f1(x[1]) - f1(x[1])
        F[2] = f1(x[1]) - f3(x[2])
        F[3] = f2(x[1]) - f4(x[3])
        F[4] = x[1] + x[2] + x[3] - Stot
        F[5] = x[4] + x[5] # dummy equation with two dummy variables to make the system of equations a square
    end
    roots = nlsolve(f!, [30.0,50.0,50.0,0.0,0.0])
    solution[i,1] = roots.zero[1]
    for j in 1:50
        I2 = .01 * multiple ^ (j)
        inhibitor_2[j+1]=I2
        f1(x) = Vm1 * x / (1 + I1/Ki1)*(Ks1 + x)
        f2(x) = Vm2 * x / (1 + I2/Ki2)*(Ks2+x)
        f3(x) = Vm3 * x / (Ks3 + x)
        f4(x) = Vm4 * x / (Ks4 + x)
        function f!(F,x)
            F[1] = f3(x[2]) + f4(x[3]) - f1(x[1]) - f1(x[1])
            F[2] = f1(x[1]) - f3(x[2])
            F[3] = f2(x[1]) - f4(x[3])
            F[4] = x[1] + x[2] + x[3] - Stot
            F[5] = x[4] + x[5] # dummy equation with two dummy variables to make the system of equations a square
        end
        roots = nlsolve(f!, [30.0,50.0,50.0,0.0,0.0])
        solution[i,j+1] = roots.zero[1]
    end
end
p2 = contour(inhibitor_1, inhibitor_2, solution)
yaxis!("Inhibitor 2", :log10)
xaxis!("Inhibitor 1", :log10)
title!("Ki = 1.0 case")
Ks1 = 35.0
Ks2 = 35.0
Ks3 = 35.0
Ks4 = 35.0
solution2 = zeros(51,51)
inhibitor_12 = zeros(51)
inhibitor_22 = zeros(51)
inhibitor_22[1]=.01
for i in 1:51
    I1 = .01 * multiple ^ (i-1)
    inhibitor_12[i] = I1
    I2 = .01
    f1(x) = Vm1 * x / (1 + I1/Ki1)*(Ks1 + x)
    f2(x) = Vm2 * x / (1 + I2/Ki2)*(Ks2+x)
    f3(x) = Vm3 * x / (Ks3 + x)
    f4(x) = Vm4 * x / (Ks4 + x)
    function f!(F,x)
        F[1] = f3(x[2]) + f4(x[3]) - f1(x[1]) - f1(x[1])
        F[2] = f1(x[1]) - f3(x[2])
        F[3] = f2(x[1]) - f4(x[3])
        F[4] = x[1] + x[2] + x[3] - Stot
        F[5] = x[4] + x[5] # dummy equation with two dummy variables to make the system of equations a square
    end
    roots = nlsolve(f!, [30.0,50.0,50.0,0.0,0.0])
    solution2[i,1] = roots.zero[1]
    for j in 1:50
        I2 = .01 * multiple ^ (j)
        inhibitor_22[j+1]=I2
        f1(x) = Vm1 * x / (1 + I1/Ki1)*(Ks1 + x)
        f2(x) = Vm2 * x / (1 + I2/Ki2)*(Ks2+x)
        f3(x) = Vm3 * x / (Ks3 + x)
        f4(x) = Vm4 * x / (Ks4 + x)
        function f!(F,x)
            F[1] = f3(x[2]) + f4(x[3]) - f1(x[1]) - f1(x[1])
            F[2] = f1(x[1]) - f3(x[2])
            F[3] = f2(x[1]) - f4(x[3])
            F[4] = x[1] + x[2] + x[3] - Stot
            F[5] = x[4] + x[5] # dummy equation with two dummy variables to make the system of equations a square
        end
        roots = nlsolve(f!, [30.0,50.0,50.0,0.0,0.0])
        solution2[i,j+1] = roots.zero[1]
    end
end
p3 = contour(inhibitor_12, inhibitor_22, solution2)
yaxis!("Inhibitor 2", :log10)
xaxis!("Inhibitor 1", :log10)
title!("Ki = 35.0 case")
plot(p2,p3)
