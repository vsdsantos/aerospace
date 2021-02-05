data = [15.94	13.19	13.36
        15.93	13.34	13.35
        15.9	13.3	13.27
        15.95	13.31	13.2
        16.05	13.32	13.25]
using Plots, Statistics
begin
    plot()

    avrg = mean.(data[:,i] for i in 1:3)
    sigma = std.(data[:,i] for i in 1:3)

    plot!([1], [avrg[1]], yerror=sigma[1], label="")
    scatter!(ones(5,1), data[:,1], alpha=0.4, label="Sistema 1")

    plot!([2], [avrg[2]], yerror=sigma[2], label="")
    scatter!(2*ones(5,1), data[:,2], alpha=0.4,  label="Sistema 2")

    plot!([3], [avrg[3]], yerror=sigma[3], label="")
    scatter!(3*ones(5,1), data[:,3], alpha=0.4,  label="Sistema 3")

    plot!(ylim=[0 20], xticks=:none, ylabel="tempo [s]")
end
savefig("vibes2.png")

data2 = [14.38	10.19	10.23	9.07
        14.39	10.26	10.23	9.13
        14.42	10.15	10.22	9.2
        14.53	10.17	10.13	9.08
        14.53	10.18	10.22	9.18]./10
# data2[:,1:3] .*= 0.4442
# data2[:,4] .*= 0.3571
begin
    plot()

    avrg = mean.(data2[:,i] for i in 1:4)
    sigma = std.(data2[:,i] for i in 1:4)
    print(sigma)

    plot!([1], [avrg[1]], yerror=sigma[1], label="")
    scatter!(ones(5,1), data2[:,1], alpha=0.4, label="Sistema 1")

    plot!([2], [avrg[2]], yerror=sigma[2], label="")
    scatter!(2*ones(5,1), data2[:,2], alpha=0.4,  label="Sistema 2")

    plot!([3], [avrg[3]], yerror=sigma[3], label="")
    scatter!(3*ones(5,1), data2[:,3], alpha=0.4,  label="Sistema 3")

    plot!([4], [avrg[4]], yerror=sigma[4], label="")
    scatter!(4*ones(5,1), data2[:,4], alpha=0.4,  label="Sistema 4")

    plot!(ylim=[0 20], xticks=:none, ylabel="omega_n [rad/s]")
end
