# Sample script to run a model using GRNSimKit -
using GRNSimKit
using PyPlot

# time step -
time_step_size = 1.0/(60)#Time step in hours

simulation_case_flag = :default

# default -
path_to_model_file = "$(pwd())/ICT1.json"#updated JSON file with updated binding constants from the one posted on slack
color_P1 = "black"
color_P2 = "red"
color_P3 = "blue"

# Build a data dictionary from a model file -
ddd = build_discrete_dynamic_data_dictionary(time_step_size, path_to_model_file)
# Run the model to steady-state, before we do anything -
steady_state = GRNSteadyStateSolve(ddd)
# Run the model 60 minutes without inducer-
ddd[:initial_condition_array] = steady_state
(T0, X0) = GRNDiscreteDynamicSolve((0.0,1.0,time_step_size), ddd)

# Add inducer I = 10 mM for the rest of the 6 hours -
ddd[:initial_condition_array] = X0[end,:]
ddd[:initial_condition_array][7] = 10.0
tstart_1 = T0[end]
tstop_1 = tstart_1 + 5.0
(T1, X1) = GRNDiscreteDynamicSolve((tstart_1,tstop_1, time_step_size), ddd)

# Package -
T = [T0 ; T1]
X = [X0 ; X1]

# make a plot -
plot(T*60,X[:,4],color_P1,linewidth=2)
plot(T*60,X[:,5],color_P2,linewidth=2)
plot(T*60,X[:,6],color_P3,linewidth=2)

# axis -
xlabel("Time (min)", fontsize=16)
ylabel("Protein (nmol/gDW)", fontsize=16)
