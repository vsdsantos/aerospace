using Plots

let # Questão 6
    δm = 0.15
    k = 1.6e3
    m_a = 8
    ω_n = sqrt(k/m_a)
    display(ω_n)
    P(ω_f) = k*δm ./ abs((1 .- (ω_f./ω_n).^2))

    plot(P, range(0, 100, length=1000))
    plot!([0, 100], [120, 120])
    plot!(yrange=[0, 350], ylabel="P [N]", xlabel="ω_f (rad)")
end # let

let # Questão X
    m = 0.030
    e = 0.2
    M = 200
    k = 240e3
    X(ω) = m .* e .* ω.^2 ./ abs.(k .- M.*ω.^2)
    plot(X, range(30, 40, length=1000))
    plot!(yrange=[0, 0.002], ylabel="X (m)", xlabel="ω_f (rad)")
    plot!([30,40],0.0015*[1,1])
end # let
