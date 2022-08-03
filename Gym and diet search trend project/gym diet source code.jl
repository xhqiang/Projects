import Pkg;
Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("Plots")
Pkg.add("LinearAlgebra")
Pkg.add("IJulia")
using CSV, DataFrames, Plots
using LinearAlgebra: norm

theme(
    :wong;
    label="",
    markerstrokewidth=0.3,
    markerstrokecolor=:white,
    alpha=0.7
)

df = CSV.File("diet_gym_trends_us.csv") |> DataFrame

rename!(df, [1 => :month, 2 => :diet, 3 => :gym])

include("MyLsqFit.jl")
using Main.MyLsqFit

# Fitting gym
label_idx = 1:24:length(df.month)
y=1:length(df.month)
d_poly, d_periodic, T =6, 7, 12   
A, c_ls = lsqfit_poly_periodic(y, df.gym, d_poly, d_periodic, T)
train_error = norm(df.gym - A * c_ls)
xtest = range(minimum(y); stop=maximum(y), length=length(df.month)) |> collect
ypredict = poly_periodic(xtest, c_ls, d_poly, d_periodic, T)

err1 = []
k=10
d_list = 1:1:k
for d_polyi in d_list
    for d_periodici in d_list
    Ai, c_lsi = lsqfit_poly_periodic(y, df.gym, d_polyi, d_periodici, T)
    push!(err1, norm(df.gym - Ai * c_lsi))
    end
end
@show minimum(err1)
@show d_poly_optimal = div(findmin(err1)[2],k)+1
@show d_periodic_optimal = rem(findmin(err1)[2],k)

    p_poly_degree = scatter(
        d_list, err1;
        markersize=3,
        color=:red,
        xlabel="d_poly", 
        ylabel="squared fitting error",
        title="Degree for polynomial"
    )
    
                 
    p_data = scatter(
        y, df.gym;
        color=:red,
        markersize=3,
        xticks=(label_idx, string.(df[label_idx, 1])),
        xrotation=45    
    )

    plot!(
        xtest, ypredict;
        label="Squared error = $(round(train_error; digits=4))",
        lw=3,
        legend=:bottomleft,
        xlabel="Date",
        ylabel="y",
        color=:blue,
        title="Best fitted line \n(d_poly, d_periodic, T) = ($d_poly, $d_periodic, $T)"
    )

    p_residual = scatter(
        y, (df.gym - A * c_ls);
        color=:red,
        markersize=3,
        xlabel="Date",
        ylabel="Error",
        title="Plot of the residual fitting error versus date",
        xticks=(label_idx, string.(df[label_idx, 1])),
        xrotation=45
    )
    plot(p_poly_degree, p_data, p_residual; layout=(1, 3), size=(1400, 300))
    
    
    
# Fitting diet
label_idx = 1:24:length(df.month)
y=1:length(df.month)
d_poly, d_periodic, T =6, 7, 12  
A1, c_ls1 = lsqfit_poly_periodic(y, df.diet, d_poly, d_periodic, T)
train_error = norm(df.diet - A1 * c_ls1)
xtest1 = range(minimum(y); stop=maximum(y), length=length(df.month)) |> collect
ypredict1 = poly_periodic(xtest1, c_ls1, d_poly, d_periodic, T)

err = []
k=10
d_list = 1:1:k
for d_polyi in d_list
    for d_periodici in d_list
    Ai, c_lsi = lsqfit_poly_periodic(y, df.diet, d_polyi, d_periodici, T)
    push!(err, norm(df.diet - Ai * c_lsi))
    end
end
@show minimum(err)
@show d_poly_optimal = div(findmin(err)[2],k)+1
@show d_periodic_optimal = rem(findmin(err)[2],k)
    p_poly_degree = scatter(
        d_list, err;
        markersize=3,
        color=:red,
        xlabel="d_poly", 
        ylabel="squared fitting error",
        title="Degree for polynomial"
    )
    
                 
    p_data = scatter(
        y, df.diet;
        color=:red,
        markersize=3,
        xticks=(label_idx, string.(df[label_idx, 1])),
        xrotation=45    
    )
    plot!(
        xtest1, ypredict1;
        label="Squared error = $(round(train_error; digits=4))",
        lw=3,
        legend=:bottomleft,
        xlabel="Date",
        ylabel="y",
        color=:blue,
        title="Best fitted line \n(d_poly, d_periodic, T) = ($d_poly, $d_periodic, $T)"
    )

    p_residual = scatter(
        y, (df.diet - A1 * c_ls1);
        color=:red,
        markersize=3,
        xlabel="Date",
        ylabel="Error",
        title="Plot of the residual fitting error versus date",
        xticks=(label_idx, string.(df[label_idx, 1])),
        xrotation=45
    )
    plot(p_poly_degree, p_data, p_residual; layout=(1, 3), size=(1400, 300))
    
extrema(df.month)
using Dates
last_month = df.month |> last
future_dates = last_month:Dates.Month(1):(last_month + Dates.Month(12))
collect(future_dates)

# Predict diet
future_dates1=collect(future_dates)
popfirst!(future_dates1)
new_month=vcat(df.month,future_dates1)
label_idx = 1:24:length(new_month)
t_forecast1 = collect(range(maximum(y); stop=length(new_month), length=length(future_dates1)))
yforecast1 = poly_periodic(t_forecast1, c_ls1, d_poly, d_periodic, T)

p_data = scatter(y, df.diet; markersize=3)
plot!(
    xtest1, ypredict1;
    label="($d_poly,$d_periodic,$T)-fit",
    legend=:bottomleft,
    color=:black
)
plot!(
    t_forecast1,yforecast1; 
    label="($d_poly,$d_periodic,$T)-forecast",
    linestyle=:dash,
    color=:blue,
    xticks=(label_idx, string.(new_month[label_idx, 1])),
    xrotation=45,
    xlabel="Date",
    ylabel="Diet",
    title="Prediction for Diet"
)


# Predict gym
label_idx = 1:24:length(new_month)
t_forecast = collect(range(maximum(y); stop=length(new_month), length=length(future_dates1)))
yforecast = poly_periodic(t_forecast, c_ls, d_poly, d_periodic, T)

p_data = scatter(y, df.gym; markersize=3)
plot!(
    t_forecast,yforecast; 
    label="($d_poly,$d_periodic,$T)-forecast",
    linestyle=:dash,
    color=:red,
    xticks=(label_idx, string.(new_month[label_idx, 1])),
    xrotation=45,
    xlabel="Date",
    ylabel="Gym",
    title="Prediction for Gym"
)
plot!(
    xtest, ypredict;
    label="($d_poly,$d_periodic,$T)-fit",
    legend=:topleft,
    color=:black
)