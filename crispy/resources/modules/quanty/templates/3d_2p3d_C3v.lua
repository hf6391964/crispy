--------------------------------------------------------------------------------
-- Quanty input file generated using Crispy. If you use this file please cite
-- the following reference: 10.5281/zenodo.1008184.
--
-- elements: 3d
-- symmetry: C3v
-- experiment: RIXS
-- edge: L2,3-M4,5 (2p3d)
--------------------------------------------------------------------------------
Verbosity($Verbosity)

--------------------------------------------------------------------------------
-- Initialize the Hamiltonians.
--------------------------------------------------------------------------------
H_i = 0
H_m = 0
H_f = 0

--------------------------------------------------------------------------------
-- Toggle the Hamiltonian terms.
--------------------------------------------------------------------------------
H_atomic = $H_atomic
H_cf = $H_cf

--------------------------------------------------------------------------------
-- Define the number of electrons, shells, etc.
--------------------------------------------------------------------------------
NBosons = 0
NFermions = 16

NElectrons_2p = 6
NElectrons_3d = $NElectrons_3d

IndexDn_2p = {0, 2, 4}
IndexUp_2p = {1, 3, 5}
IndexDn_3d = {6, 8, 10, 12, 14}
IndexUp_3d = {7, 9, 11, 13, 15}

--------------------------------------------------------------------------------
-- Define the atomic term.
--------------------------------------------------------------------------------
N_2p = NewOperator('Number', NFermions, IndexUp_2p, IndexUp_2p, {1, 1, 1})
     + NewOperator('Number', NFermions, IndexDn_2p, IndexDn_2p, {1, 1, 1})

N_3d = NewOperator('Number', NFermions, IndexUp_3d, IndexUp_3d, {1, 1, 1, 1, 1})
     + NewOperator('Number', NFermions, IndexDn_3d, IndexDn_3d, {1, 1, 1, 1, 1})

if H_atomic == 1 then
    F0_3d_3d = NewOperator('U', NFermions, IndexUp_3d, IndexDn_3d, {1, 0, 0})
    F2_3d_3d = NewOperator('U', NFermions, IndexUp_3d, IndexDn_3d, {0, 1, 0})
    F4_3d_3d = NewOperator('U', NFermions, IndexUp_3d, IndexDn_3d, {0, 0, 1})

    F0_2p_3d = NewOperator('U', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_3d, IndexDn_3d, {1, 0}, {0, 0})
    F2_2p_3d = NewOperator('U', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_3d, IndexDn_3d, {0, 1}, {0, 0})
    G1_2p_3d = NewOperator('U', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_3d, IndexDn_3d, {0, 0}, {1, 0})
    G3_2p_3d = NewOperator('U', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_3d, IndexDn_3d, {0, 0}, {0, 1})

    F2_3d_3d_i = $F2(3d,3d)_i_value * $F2(3d,3d)_i_scaling
    F4_3d_3d_i = $F4(3d,3d)_i_value * $F4(3d,3d)_i_scaling
    F0_3d_3d_i = 2 / 63 * F2_3d_3d_i + 2 / 63 * F4_3d_3d_i

    F2_3d_3d_m = $F2(3d,3d)_m_value * $F2(3d,3d)_m_scaling
    F4_3d_3d_m = $F4(3d,3d)_m_value * $F4(3d,3d)_m_scaling
    F0_3d_3d_m = 2 / 63 * F2_3d_3d_m + 2 / 63 * F4_3d_3d_m
    F2_2p_3d_m = $F2(2p,3d)_m_value * $F2(2p,3d)_m_scaling
    G1_2p_3d_m = $G1(2p,3d)_m_value * $G1(2p,3d)_m_scaling
    G3_2p_3d_m = $G3(2p,3d)_m_value * $G3(2p,3d)_m_scaling
    F0_2p_3d_m = 1 / 15 * G1_2p_3d_m + 3 / 70 * G3_2p_3d_m

    F2_3d_3d_f = $F2(3d,3d)_f_value * $F2(3d,3d)_f_scaling
    F4_3d_3d_f = $F4(3d,3d)_f_value * $F4(3d,3d)_f_scaling
    F0_3d_3d_f = 2 / 63 * F2_3d_3d_f + 2 / 63 * F4_3d_3d_f

    H_i = H_i + Chop(
          F0_3d_3d_i * F0_3d_3d
        + F2_3d_3d_i * F2_3d_3d
        + F4_3d_3d_i * F4_3d_3d)

    H_m = H_m + Chop(
          F0_3d_3d_m * F0_3d_3d
        + F2_3d_3d_m * F2_3d_3d
        + F4_3d_3d_m * F4_3d_3d
        + F0_2p_3d_m * F0_2p_3d
        + F2_2p_3d_m * F2_2p_3d
        + G1_2p_3d_m * G1_2p_3d
        + G3_2p_3d_m * G3_2p_3d)

    H_f = H_f + Chop(
          F0_3d_3d_f * F0_3d_3d
        + F2_3d_3d_f * F2_3d_3d
        + F4_3d_3d_f * F4_3d_3d)

    ldots_3d = NewOperator('ldots', NFermions, IndexUp_3d, IndexDn_3d)

    ldots_2p = NewOperator('ldots', NFermions, IndexUp_2p, IndexDn_2p)

    zeta_3d_i = $zeta(3d)_i_value * $zeta(3d)_i_scaling

    zeta_3d_m = $zeta(3d)_m_value * $zeta(3d)_m_scaling
    zeta_2p_m = $zeta(2p)_m_value * $zeta(2p)_m_scaling

    zeta_3d_f = $zeta(3d)_f_value * $zeta(3d)_f_scaling

    H_i = H_i + Chop(
          zeta_3d_i * ldots_3d)

    H_m = H_m + Chop(
          zeta_3d_m * ldots_3d
        + zeta_2p_m * ldots_2p)

    H_f = H_f + Chop(
          zeta_3d_f * ldots_3d)
end

--------------------------------------------------------------------------------
-- Define the crystal field term.
--------------------------------------------------------------------------------
if H_cf == 1 then
    Dq_3d = NewOperator('CF', NFermions, IndexUp_3d, IndexDn_3d, {{4, 0, -14}, {4, 3, -2 * math.sqrt(70)}, {4, -3, 2 * math.sqrt(70)}})
    Dsigma_3d = NewOperator('CF', NFermions, IndexUp_3d, IndexDn_3d, {{2, 0, -7}})
    Dtau_3d = NewOperator('CF', NFermions, IndexUp_3d, IndexDn_3d, {{4, 0, -21}})

    Dq_3d_i = $Dq(3d)_i_value
    Dsigma_3d_i = $Dsigma(3d)_i_value
    Dtau_3d_i = $Dtau(3d)_i_value

    Dq_3d_m = $Dq(3d)_m_value
    Dsigma_3d_m = $Dsigma(3d)_m_value
    Dtau_3d_m = $Dtau(3d)_m_value

    Dq_3d_f = $Dq(3d)_f_value
    Dsigma_3d_f = $Dsigma(3d)_f_value
    Dtau_3d_f = $Dtau(3d)_f_value

    H_i = H_i + Chop(
          Dq_3d_i * Dq_3d
        + Dsigma_3d_i * Dsigma_3d
        + Dtau_3d_i * Dtau_3d)

    H_m = H_m + Chop(
          Dq_3d_m * Dq_3d
        + Dsigma_3d_m * Dsigma_3d
        + Dtau_3d_m * Dtau_3d)

    H_f = H_f + Chop(
          Dq_3d_f * Dq_3d
        + Dsigma_3d_f * Dsigma_3d
        + Dtau_3d_f * Dtau_3d)
end

--------------------------------------------------------------------------------
-- Define the spin and orbital operators.
--------------------------------------------------------------------------------
Sx_3d = NewOperator('Sx', NFermions, IndexUp_3d, IndexDn_3d)
Sy_3d = NewOperator('Sy', NFermions, IndexUp_3d, IndexDn_3d)
Sz_3d = NewOperator('Sz', NFermions, IndexUp_3d, IndexDn_3d)
Ssqr_3d = NewOperator('Ssqr', NFermions, IndexUp_3d, IndexDn_3d)
Splus_3d = NewOperator('Splus', NFermions, IndexUp_3d, IndexDn_3d)
Smin_3d = NewOperator('Smin', NFermions, IndexUp_3d, IndexDn_3d)

Lx_3d = NewOperator('Lx', NFermions, IndexUp_3d, IndexDn_3d)
Ly_3d = NewOperator('Ly', NFermions, IndexUp_3d, IndexDn_3d)
Lz_3d = NewOperator('Lz', NFermions, IndexUp_3d, IndexDn_3d)
Lsqr_3d = NewOperator('Lsqr', NFermions, IndexUp_3d, IndexDn_3d)
Lplus_3d = NewOperator('Lplus', NFermions, IndexUp_3d, IndexDn_3d)
Lmin_3d = NewOperator('Lmin', NFermions, IndexUp_3d, IndexDn_3d)

Jx_3d = NewOperator('Jx', NFermions, IndexUp_3d, IndexDn_3d)
Jy_3d = NewOperator('Jy', NFermions, IndexUp_3d, IndexDn_3d)
Jz_3d = NewOperator('Jz', NFermions, IndexUp_3d, IndexDn_3d)
Jsqr_3d = NewOperator('Jsqr', NFermions, IndexUp_3d, IndexDn_3d)
Jplus_3d = NewOperator('Jplus', NFermions, IndexUp_3d, IndexDn_3d)
Jmin_3d = NewOperator('Jmin', NFermions, IndexUp_3d, IndexDn_3d)

Sx = Sx_3d
Sy = Sy_3d
Sz = Sz_3d

Lx = Lx_3d
Ly = Ly_3d
Lz = Lz_3d

Jx = Jx_3d
Jy = Jy_3d
Jz = Jz_3d

Ssqr = Sx * Sx + Sy * Sy + Sz * Sz
Lsqr = Lx * Lx + Ly * Ly + Lz * Lz
Jsqr = Jx * Jx + Jy * Jy + Jz * Jz

NConfigurations = $NConfigurations

--------------------------------------------------------------------------------
-- Define the restrictions and set the number of initial states.
--------------------------------------------------------------------------------
InitialRestrictions = {NFermions, NBosons, {'111111 0000000000', NElectrons_2p, NElectrons_2p},
                                           {'000000 1111111111', NElectrons_3d, NElectrons_3d}}

IntermediateRestrictions = {NFermions, NBosons, {'111111 0000000000', NElectrons_2p - 1, NElectrons_2p - 1},
                                                {'000000 1111111111', NElectrons_3d + 1, NElectrons_3d + 1}}

FinalRestrictions = InitialRestrictions

Operators = {H_i, Ssqr, Lsqr, Jsqr, Sz, Lz, Jz, N_2p, N_3d, 'dZ'}
header = 'Analysis of the initial Hamiltonian:\n'
header = header .. '=============================================================================================================\n'
header = header .. 'State         <E>     <S^2>     <L^2>     <J^2>      <Sz>      <Lz>      <Jz>    <N_2p>    <N_3d>          dZ\n'
header = header .. '=============================================================================================================\n'
footer = '=============================================================================================================\n'

-- Define the temperature.
T = $T * EnergyUnits.Kelvin.value

 -- Approximate machine epsilon.
epsilon = 2.22e-16

NPsis = $NPsis
NPsisAuto = $NPsisAuto

dZ = {}

if NPsisAuto == 1 and NPsis ~= 1 then
    NPsis = 4
    NPsisIncrement = 8
    NPsisIsConverged = false

    while not NPsisIsConverged do
        if CalculationRestrictions == nil then
            Psis_i = Eigensystem(H_i, InitialRestrictions, NPsis)
        else
            Psis_i = Eigensystem(H_i, InitialRestrictions, NPsis, {{'restrictions', CalculationRestrictions}})
        end

        if not (type(Psis_i) == 'table') then
            Psis_i = {Psis_i}
        end

        E_gs_i = Psis_i[1] * H_i * Psis_i[1]

        Z = 0

        for i, Psi in ipairs(Psis_i) do
            E = Psi * H_i * Psi

            if math.abs(E - E_gs_i) < epsilon then
                dZ[i] = 1
            else
                dZ[i] = math.exp(-(E - E_gs_i) / T)
            end

            Z = Z + dZ[i]

            if (dZ[i] / Z) < math.sqrt(epsilon) then
                i = i - 1
                NPsisIsConverged = true
                NPsis = i
                Psis_i = {unpack(Psis_i, 1, i)}
                dZ = {unpack(dZ, 1, i)}
                break
            end
        end

        if NPsisIsConverged then
            break
        else
            NPsis = NPsis + NPsisIncrement
        end
    end
else
    if CalculationRestrictions == nil then
        Psis_i = Eigensystem(H_i, InitialRestrictions, NPsis)
    else
        Psis_i = Eigensystem(H_i, InitialRestrictions, NPsis, {{'restrictions', CalculationRestrictions}})
    end

    if not (type(Psis_i) == 'table') then
        Psis_i = {Psis_i}
    end
        E_gs_i = Psis_i[1] * H_i * Psis_i[1]

    Z = 0

    for i, Psi in ipairs(Psis_i) do
        E = Psi * H_i * Psi

        if math.abs(E - E_gs_i) < epsilon then
            dZ[i] = 1
        else
            dZ[i] = math.exp(-(E - E_gs_i) / T)
        end

        Z = Z + dZ[i]
    end
end

-- Normalize dZ to unity.
for i in ipairs(dZ) do
    dZ[i] = dZ[i] / Z
end

io.write(header)
for i, Psi in ipairs(Psis_i) do
    io.write(string.format('%5d', i))
    for j, Operator in ipairs(Operators) do
        if j == 1 then
            io.write(string.format('%12.6f', Complex.Re(Psi * Operator * Psi)))
        elseif Operator == 'dZ' then
            io.write(string.format('%12.2E', dZ[i]))
        else
        io.write(string.format('%10.4f', Complex.Re(Psi * Operator * Psi)))
    end
    end
    io.write('\n')
end
io.write(footer)

--------------------------------------------------------------------------------
-- Define the transition operators.
--------------------------------------------------------------------------------
t = math.sqrt(1/2);

Tx_2p_3d = NewOperator('CF', NFermions, IndexUp_3d, IndexDn_3d, IndexUp_2p, IndexDn_2p, {{1, -1, t    }, {1, 1, -t    }})
Ty_2p_3d = NewOperator('CF', NFermions, IndexUp_3d, IndexDn_3d, IndexUp_2p, IndexDn_2p, {{1, -1, t * I}, {1, 1,  t * I}})
Tz_2p_3d = NewOperator('CF', NFermions, IndexUp_3d, IndexDn_3d, IndexUp_2p, IndexDn_2p, {{1,  0, 1    }                })

Tx_3d_2p = NewOperator('CF', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_3d, IndexDn_3d, {{1, -1, t    }, {1, 1, -t    }})
Ty_3d_2p = NewOperator('CF', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_3d, IndexDn_3d, {{1, -1, t * I}, {1, 1,  t * I}})
Tz_3d_2p = NewOperator('CF', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_3d, IndexDn_3d, {{1,  0, 1    }                })

T_2p_3d = {Tx_2p_3d, Ty_2p_3d, Tz_2p_3d}
T_3d_2p = {Tx_3d_2p, Ty_3d_2p, Tz_3d_2p}

--------------------------------------------------------------------------------
-- Calculate and save the spectrum.
--------------------------------------------------------------------------------
E_gs_i = Psis_i[1] * H_i * Psis_i[1]

if CalculationRestrictions == nil then
    Psis_m = Eigensystem(H_m, IntermediateRestrictions, 1)
else
    Psis_m = Eigensystem(H_m, IntermediateRestrictions, 1, {{'restrictions', CalculationRestrictions}})
end
Psis_m = {Psis_m}
E_gs_m = Psis_m[1] * H_m * Psis_m[1]

Eedge1 = $Eedge1
DeltaE1 = Eedge1 + E_gs_i - E_gs_m

Eedge2 = $Eedge2
DeltaE2 = Eedge2

Emin1 = $Emin1 - DeltaE1
Emax1 = $Emax1 - DeltaE1
Gamma1 = $Gamma1
NE1 = $NE1

Emin2 = $Emin2 - DeltaE2
Emax2 = $Emax2 - DeltaE2
Gamma2 = $Gamma2
NE2 = $NE2

G = 0

totalCalculations = #Psis_i * #T_2p_3d * #T_3d_2p
calculation = 1

for i, Psi in ipairs(Psis_i) do
    for j, OperatorIn in ipairs(T_2p_3d) do
        for k, OperatorOut in ipairs(T_3d_2p) do
            io.write(string.format('Running calculation %d of %d.\n', calculation, totalCalculations))
            if CalculationRestrictions == nil then
                G = G + CreateResonantSpectra(H_m, H_f, OperatorIn, OperatorOut, Psi, {{'Emin1', Emin1}, {'Emax1', Emax1}, {'NE1', NE1}, {'Gamma1', Gamma1}, {'Emin2', Emin2}, {'Emax2', Emax2}, {'NE2', NE2}, {'Gamma2', Gamma2}}) * dZ[i]
            else
                G = G + CreateResonantSpectra(H_m, H_f, OperatorIn, OperatorOut, Psi, {{'Emin1', Emin1}, {'Emax1', Emax1}, {'NE1', NE1}, {'Gamma1', Gamma1}, {'Emin2', Emin2}, {'Emax2', Emax2}, {'NE2', NE2}, {'Gamma2', Gamma2}, {'restrictions1', CalculationRestrictions}}) * dZ[i]
            end
            calculation = calculation + 1
        end
    end
end

G.Print({{'file', '$BaseName.spec'}})

