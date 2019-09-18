using ForwardDiff
using LinearAlgebra
using SymPy
using Calculus

#Problem 5 part a
f(x::Vector) = 1 + x[1] + x[2] + x[3] + x[4] + x[1]*x[2] + x[1]*x[3] + x[1]*x[4] + x[2]*x[3] + x[2]*x[4] + x[3]*x[4] + (x[1])^2 + x[2]^2 + x[3]^2 + x[4]^2
#Function for problem 5 part a
x = [-3; -30; -4; -0.1]
#Initial values
iterations = zeros(4,6)
#Creating matrix to store values of iterations
iterations[:,1] = x
#Initial values are my first column

while loop < 6
    hess = ForwardDiff.hessian(f, iterations[:,loop])
    #Take the hessian at xk
    inverse = inv(hess)
    #invert the hessian
    grad = ForwardDiff.gradient(f,iterations[:,loop])
    #grad2 = ForwardDiff.gradient(g,iterations2[:,loop])
    #Take the gradient at x_k
    iterations[:,loop+1] = iterations[:,(loop)] - inverse*grad
    #iterations2[:,loop+1] = iterations2[:,(loop)] - inverse2*grad2
    #Create x_(k+1)
    global loop +=1
end

iterations[:,6]

#Problem 5 part b
g(y::Vector) = y[1] * y[2]^2 * y[3]^3 * y[4]^4 * (exp(-y[1]-y[2]-y[3]-y[4])-1)
#Function for problem 5 part a
y = [3; 4; .5; 1]
#Initial values
iterations2 = zeros(4,200)
#Creating matrix to store values of iterations
iterations2[:,1] = y
#Initial values are my first column
loop = 1
while loop < 200
    hess2 = ForwardDiff.hessian(g, iterations2[:,loop])
    #Take the hessian at xk
    inverse2 = inv(hess2)
    #invert the hessian
    grad2 = ForwardDiff.gradient(g,iterations2[:,loop])
    #Take the gradient at x_k
    iterations2[:,loop+1] = iterations2[:,(loop)] - inverse2*grad2
    #Create x_(k+1)
    global loop +=1
end

println(iterations[:,6])
#evaluate x_5 after newtonian method for 5a
println(f(iterations[:,6]))
#evaluate f(x_5) for 5a
println(iterations2[:,6])
#evaluate x_5 after newtonian method for 5b
println(g(iterations2[:,6]))
#evaluate f(x_5) for 5b
println(iterations2[:,200])
#evaluate x_199 after newtonian method for 5b
println(g(iterations2[:,200]))
#evaluate f(x_199) after newtonian method for 5b



#Hw1 question 6

X1 = [84 73 65 70 76 69 63 72 79 75 27 89 65 57 59 69 60 79 75 82 59 67 85 55 63]
X2 = [46 20 52 30 57 25 28 36 57 44 24 31 52 23 60 48 34 51 50 34 46 23 37 40 30]
Y = [354 190 405 263 451 302 288 385 402 365 209 290 346 254 395 434 220 374 308 220 311 181 274 303 244]
Xa = ones(25)
Xtot = vcat(transpose(Xa),X1,X2)
n=25
#Problem 6 part a
p1=Sym("p1")
p2=Sym("p2")
p3=Sym("p3")
i=1
j=0
objfxn2 = (p1 + p2*X1[1]+p3*X2[1]-Y[1])^2
while j != 1
    global sum2 = (p1 + p2*X1[1]+p3*X2[1]-Y[1])^2
    for i in 2:25
        objfxn2 = (p1 + p2*X1[i]+p3*X2[i]-Y[i])^2
        global sum2 = sum2 +  objfxn2
    end
    j=1
    return sum2
end
sum2 = sum2/25
#hess3 = ForwardDiff.hessian(sum2, y)
f6(t::Vector) = sum2((p1=>t[1]),(p2=>t[2]),(p3=>t[3]))
#Function for problem 5 part b
z = [0.0;0;0]
#Initial values
iterations3 = zeros(3,20)
#Storage for iterations of newtonian method for 20 times
for i in 1:19
    inv3 = inv(Calculus.hessian(f6,iterations3[:,i]))
    #invert the hessian
    grad3 = Calculus.gradient(f6,iterations3[:,i])
    #Take the gradient
    iterations3[:,i+1] = iterations3[:,i]-inv3*grad3
end
theta = iterations3[:,20]
println(theta)

#Problem 6 part b

theta_analytic = inv(Xtot*transpose(Xtot))*Xtot*transpose(Y)
println(theta_analytic)
