using LsqFit
using PyPlot

#Data
AMP = [0 0.055 0.093 0.181 0.405 0.99] #mM
overall_rate = [3.003 6.302 29.761 52.002 60.306 68.653]  #uM/h
estimate = [0.59 1.2 5.7 10.2  11.8 13.3] #95% confidence

#parameters
F6p = .1 #mM
ATP = 2.3 #mM
PFK = .12 #uM
kf6p = .11 #mM
kATP = .42 #mM
kcat = .4 #s^-1
kcathr = kcat * 3600 #hr^-1
#kinetic limit
r1 = kcathr*PFK*(F6p/(kf6p+F6p))*(ATP/(ATP+kATP))

#Estimation of moon voigt parameters
#initial dummy values of parameters
W0 = .045
W1 = 1.2
K = .3
n= 1.5
Par =  [W0 W1 K n] #parameters array
@. model(x,Par) = r1 * (Par[1]+Par[2]*x^Par[4]/(Par[3]^Par[4]+x^Par[4]))/(1+(Par[1]+Par[2]*x^Par[4]/(Par[3]^Par[4]+x^Par[4])))
xdata = vec(AMP)
ydata = vec(overall_rate)
p0 = [0.1, 20.0, 0.3, 1.5]
lb = [0.0, 0.0, 0.0, 0.0]
ub = [10.0,1000.0,1000.0,10.0]
fit = curve_fit(model,xdata,ydata,p0, lower = lb, upper = ub)

Par = coef(fit)
x = collect(0:.01:1)#steady line for model
y= model(x,Par)#best fit line derived
errs = [estimate; estimate]
plot(AMP,overall_rate, "o")
errorbar(xdata,ydata,yerr=errs,fmt="o")
plot(x,y)
xlabel("3'-5'-AMP concentration [mM]")
ylabel("PFK activity [uM/hr]")
#As shown by the graph this model is good at describing the data.
