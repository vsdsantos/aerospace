# Propriedades

E_l = 200000 # N/mm² Módulo longitudinal
E_t = 15000 # N/mm² Módulo transversal
G_lt = 10000 # N/mm² Módulo de cisalhamento
ν_lt = 0.3 # Poisson maior
ν_tl = (E_t/E_l)*ν_lt # Poisson menor

# Matriz de rigidez de cada ply
K = [E_l/(1-ν_lt*ν_tl) ν_tl*E_l/(1-ν_lt*ν_tl) 0
     ν_lt*E_t/(1-ν_lt*ν_tl) E_t/(1-ν_lt*ν_tl) 0
     0 0 G_lt]

function stiff_mat(K, θ)
    m, n = cosd(θ), sind(θ)

    # R = [m^2 n^2 2m*n
    #      n^2 m^2 -2m*n
    #     -m*n m*n m^2-n^2]

    k11 = m^4*K[1,1] + m^2*n^2*(2K[1,2]+4K[3,3]) + n^4*K[2,2]
    k22 = n^4*K[1,1] + m^2*n^2*(2K[1,2]+4K[3,3]) + m^4*K[2,2]
    k33 = m^2*n^2*(K[1,1]-K[2,2]-2K[1,2]-2K[3,3]) + (m^4+n^4)*K[3,3]
    k12 = m^2*n^2*(K[1,1]+K[2,2]-4K[3,3]) + (m^4+n^4)*K[1,2]
    k13 = m^3*n*(K[1,1]-K[1,2]-2K[3,3]) + m*n^3*(K[1,2]-K[2,2]+K[3,3])
    k23 = m*n^3*(K[1,1]-K[1,2]-2K[3,3]) + m^3*n*(K[1,2]-K[2,2]+K[3,3])

    return [k11 k12 k13
            k12 k22 k23
            k13 k23 k33]
end

function layup_properties(K, layup, t_total)

    N = length(layup) # número de camadas
    # hipótese de todas as camadas com mesma espessura
    t = t_total/N

    # Matriz de k_barra
    plies_k = Array{Any,1}(undef, N)
    for i in 1:N
        plies_k[i] = stiff_mat(K, layup[i])
    end
    # print(plies_k)
    # Matriz A
    A = zeros(Float64, 3, 3)
    for ply in plies_k
        for i in 1:3, j in 1:3
            A[i,j] += t*ply[i,j]
        end
    end

    A_inv = inv(A)

    E_x = 1/(t_total*A_inv[1,1])
    E_y = 1/(t_total*A_inv[2,2])
    G_xy = 1/(t_total*A_inv[3,3])
    ν_xy = -A_inv[1,2]/A_inv[1,1]
    m_x = -A_inv[1,3]/A_inv[1,1]
    m_y = -A_inv[2,3]/A_inv[1,1]

    return E_x, E_y, G_xy, ν_xy, m_x, m_y, A, A_inv
end

# Flange
# layup [0/45/-45/90]_S => [0/45/-45/90/90/-45/45/0]
flange_t_total = 1 # mm
flange_layup = [0 45 -45 90 90 -45 45 0]
flange = layup_properties(K, flange_layup, flange_t_total)

# Alma
# layup [45/-45]_S => [45/-45/-45/45]
web_layup = [45 -45 -45 45]
web_t_total = 0.5 # mm
web = layup_properties(K, web_layup, web_t_total)
