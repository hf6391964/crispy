--------------------------------------------------------------------------------
-- Quanty input file generated using Crispy. If you use this file please cite
-- the following reference: 10.5281/zenodo.1008184.
--
-- elements: 4d
-- symmetry: D4h
-- experiment: RIXS
-- edge: L2,3-N4,5 (2p4d)
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
H_4d_Ld_hybridization = $H_4d_Ld_hybridization

--------------------------------------------------------------------------------
-- Define the number of electrons, shells, etc.
--------------------------------------------------------------------------------
NBosons = 0
NFermions = 16

NElectrons_2p = 6
NElectrons_4d = $NElectrons_4d

IndexDn_2p = {0, 2, 4}
IndexUp_2p = {1, 3, 5}
IndexDn_4d = {6, 8, 10, 12, 14}
IndexUp_4d = {7, 9, 11, 13, 15}

if H_4d_Ld_hybridization == 1 then
    NFermions = 26

    NElectrons_Ld = 10

    IndexDn_Ld = {16, 18, 20, 22, 24}
    IndexUp_Ld = {17, 19, 21, 23, 25}
end

--------------------------------------------------------------------------------
-- Define the atomic term.
--------------------------------------------------------------------------------
N_2p = NewOperator('Number', NFermions, IndexUp_2p, IndexUp_2p, {1, 1, 1})
     + NewOperator('Number', NFermions, IndexDn_2p, IndexDn_2p, {1, 1, 1})

N_4d = NewOperator('Number', NFermions, IndexUp_4d, IndexUp_4d, {1, 1, 1, 1, 1})
     + NewOperator('Number', NFermions, IndexDn_4d, IndexDn_4d, {1, 1, 1, 1, 1})

if H_atomic == 1 then
    F0_4d_4d = NewOperator('U', NFermions, IndexUp_4d, IndexDn_4d, {1, 0, 0})
    F2_4d_4d = NewOperator('U', NFermions, IndexUp_4d, IndexDn_4d, {0, 1, 0})
    F4_4d_4d = NewOperator('U', NFermions, IndexUp_4d, IndexDn_4d, {0, 0, 1})

    F0_2p_4d = NewOperator('U', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_4d, IndexDn_4d, {1, 0}, {0, 0})
    F2_2p_4d = NewOperator('U', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_4d, IndexDn_4d, {0, 1}, {0, 0})
    G1_2p_4d = NewOperator('U', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_4d, IndexDn_4d, {0, 0}, {1, 0})
    G3_2p_4d = NewOperator('U', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_4d, IndexDn_4d, {0, 0}, {0, 1})

    F2_4d_4d_i = $F2(4d,4d)_i_value * $F2(4d,4d)_i_scaling
    F4_4d_4d_i = $F4(4d,4d)_i_value * $F4(4d,4d)_i_scaling
    F0_4d_4d_i = 2 / 63 * F2_4d_4d_i + 2 / 63 * F4_4d_4d_i

    F2_4d_4d_m = $F2(4d,4d)_m_value * $F2(4d,4d)_m_scaling
    F4_4d_4d_m = $F4(4d,4d)_m_value * $F4(4d,4d)_m_scaling
    F0_4d_4d_m = 2 / 63 * F2_4d_4d_m + 2 / 63 * F4_4d_4d_m
    F2_2p_4d_m = $F2(2p,4d)_m_value * $F2(2p,4d)_m_scaling
    G1_2p_4d_m = $G1(2p,4d)_m_value * $G1(2p,4d)_m_scaling
    G3_2p_4d_m = $G3(2p,4d)_m_value * $G3(2p,4d)_m_scaling
    F0_2p_4d_m = 1 / 15 * G1_2p_4d_m + 3 / 70 * G3_2p_4d_m

    F2_4d_4d_f = $F2(4d,4d)_f_value * $F2(4d,4d)_f_scaling
    F4_4d_4d_f = $F4(4d,4d)_f_value * $F4(4d,4d)_f_scaling
    F0_4d_4d_f = 2 / 63 * F2_4d_4d_f + 2 / 63 * F4_4d_4d_f

    H_i = H_i + Chop(
          F0_4d_4d_i * F0_4d_4d
        + F2_4d_4d_i * F2_4d_4d
        + F4_4d_4d_i * F4_4d_4d)

    H_m = H_m + Chop(
          F0_4d_4d_m * F0_4d_4d
        + F2_4d_4d_m * F2_4d_4d
        + F4_4d_4d_m * F4_4d_4d
        + F0_2p_4d_m * F0_2p_4d
        + F2_2p_4d_m * F2_2p_4d
        + G1_2p_4d_m * G1_2p_4d
        + G3_2p_4d_m * G3_2p_4d)

    H_f = H_f + Chop(
          F0_4d_4d_f * F0_4d_4d
        + F2_4d_4d_f * F2_4d_4d
        + F4_4d_4d_f * F4_4d_4d)

    ldots_4d = NewOperator('ldots', NFermions, IndexUp_4d, IndexDn_4d)

    ldots_2p = NewOperator('ldots', NFermions, IndexUp_2p, IndexDn_2p)

    zeta_4d_i = $zeta(4d)_i_value * $zeta(4d)_i_scaling

    zeta_4d_m = $zeta(4d)_m_value * $zeta(4d)_m_scaling
    zeta_2p_m = $zeta(2p)_m_value * $zeta(2p)_m_scaling

    zeta_4d_f = $zeta(4d)_f_value * $zeta(4d)_f_scaling

    H_i = H_i + Chop(
          zeta_4d_i * ldots_4d)

    H_m = H_m + Chop(
          zeta_4d_m * ldots_4d
        + zeta_2p_m * ldots_2p)

    H_f = H_f + Chop(
          zeta_4d_f * ldots_4d)
end

--------------------------------------------------------------------------------
-- Define the crystal field term.
--------------------------------------------------------------------------------
if H_cf == 1 then
    -- PotentialExpandedOnClm('D4h', 2, {Ea1g, Eb1g, Eb2g, Eeg})
    Dq_4d = NewOperator('CF', NFermions, IndexUp_4d, IndexDn_4d, PotentialExpandedOnClm('D4h', 2, { 6,  6, -4, -4}))
    Ds_4d = NewOperator('CF', NFermions, IndexUp_4d, IndexDn_4d, PotentialExpandedOnClm('D4h', 2, {-2,  2,  2, -1}))
    Dt_4d = NewOperator('CF', NFermions, IndexUp_4d, IndexDn_4d, PotentialExpandedOnClm('D4h', 2, {-6, -1, -1,  4}))

    Dq_4d_i = $Dq(4d)_i_value
    Ds_4d_i = $Ds(4d)_i_value
    Dt_4d_i = $Dt(4d)_i_value

    Dq_4d_m = $Dq(4d)_m_value
    Ds_4d_m = $Ds(4d)_m_value
    Dt_4d_m = $Dt(4d)_m_value

    Dq_4d_f = $Dq(4d)_f_value
    Ds_4d_f = $Ds(4d)_f_value
    Dt_4d_f = $Dt(4d)_f_value

    H_i = H_i + Chop(
          Dq_4d_i * Dq_4d
        + Ds_4d_i * Ds_4d
        + Dt_4d_i * Dt_4d)

    H_m = H_m + Chop(
          Dq_4d_m * Dq_4d
        + Ds_4d_m * Ds_4d
        + Dt_4d_m * Dt_4d)

    H_f = H_f + Chop(
          Dq_4d_f * Dq_4d
        + Ds_4d_f * Ds_4d
        + Dt_4d_f * Dt_4d)
end

--------------------------------------------------------------------------------
-- Define the 4d-Ld hybridization term.
--------------------------------------------------------------------------------
if H_4d_Ld_hybridization == 1 then
    N_Ld = NewOperator('Number', NFermions, IndexUp_Ld, IndexUp_Ld, {1, 1, 1, 1, 1})
         + NewOperator('Number', NFermions, IndexDn_Ld, IndexDn_Ld, {1, 1, 1, 1, 1})

    Delta_4d_Ld_i = $Delta(4d,Ld)_i_value
    U_4d_4d_i = $U(4d,4d)_i_value
    e_4d_i = (10 * Delta_4d_Ld_i - NElectrons_4d * (19 + NElectrons_4d) * U_4d_4d_i / 2) / (10 + NElectrons_4d)
    e_Ld_i = NElectrons_4d * ((1 + NElectrons_4d) * U_4d_4d_i / 2 - Delta_4d_Ld_i) / (10 + NElectrons_4d)

    Delta_4d_Ld_m = $Delta(4d,Ld)_m_value
    U_4d_4d_m = $U(4d,4d)_m_value
    U_2p_4d_m = $U(2p,4d)_m_value
    e_4d_m = (10 * Delta_4d_Ld_m - NElectrons_4d * (31 + NElectrons_4d) * U_4d_4d_m / 2 - 90 * U_2p_4d_m) / (16 + NElectrons_4d)
    e_2p_m = (10 * Delta_4d_Ld_m + (1 + NElectrons_4d) * (NElectrons_4d * U_4d_4d_m / 2 - (10 + NElectrons_4d) * U_2p_4d_m)) / (16 + NElectrons_4d)
    e_Ld_m = ((1 + NElectrons_4d) * (NElectrons_4d * U_4d_4d_m / 2 + 6 * U_2p_4d_m) - (6 + NElectrons_4d) * Delta_4d_Ld_m) / (16 + NElectrons_4d)

    Delta_4d_Ld_f = $Delta(4d,Ld)_f_value
    U_4d_4d_f = $U(4d,4d)_f_value
    e_4d_f = (10 * Delta_4d_Ld_f - NElectrons_4d * (19 + NElectrons_4d) * U_4d_4d_f / 2) / (10 + NElectrons_4d)
    e_Ld_f = NElectrons_4d * ((1 + NElectrons_4d) * U_4d_4d_f / 2 - Delta_4d_Ld_f) / (10 + NElectrons_4d)

    H_i = H_i + Chop(
          U_4d_4d_i * F0_4d_4d
        + e_4d_i * N_4d
        + e_Ld_i * N_Ld)

    H_m = H_m + Chop(
          U_4d_4d_m * F0_4d_4d
        + U_2p_4d_m * F0_2p_4d
        + e_4d_m * N_4d
        + e_2p_m * N_2p
        + e_Ld_m * N_Ld)

    H_f = H_f + Chop(
          U_4d_4d_f * F0_4d_4d
        + e_4d_f * N_4d
        + e_Ld_f * N_Ld)

    Dq_Ld = NewOperator('CF', NFermions, IndexUp_Ld, IndexDn_Ld, PotentialExpandedOnClm('D4h', 2, { 6,  6, -4, -4}))
    Ds_Ld = NewOperator('CF', NFermions, IndexUp_Ld, IndexDn_Ld, PotentialExpandedOnClm('D4h', 2, {-2,  2,  2, -1}))
    Dt_Ld = NewOperator('CF', NFermions, IndexUp_Ld, IndexDn_Ld, PotentialExpandedOnClm('D4h', 2, {-6, -1, -1,  4}))

    Va1g_4d_Ld = NewOperator('CF', NFermions, IndexUp_Ld, IndexDn_Ld, IndexUp_4d, IndexDn_4d, PotentialExpandedOnClm('D4h', 2, {1, 0, 0, 0}))
               + NewOperator('CF', NFermions, IndexUp_4d, IndexDn_4d, IndexUp_Ld, IndexDn_Ld, PotentialExpandedOnClm('D4h', 2, {1, 0, 0, 0}))

    Vb1g_4d_Ld = NewOperator('CF', NFermions, IndexUp_Ld, IndexDn_Ld, IndexUp_4d, IndexDn_4d, PotentialExpandedOnClm('D4h', 2, {0, 1, 0, 0}))
               + NewOperator('CF', NFermions, IndexUp_4d, IndexDn_4d, IndexUp_Ld, IndexDn_Ld, PotentialExpandedOnClm('D4h', 2, {0, 1, 0, 0}))

    Vb2g_4d_Ld = NewOperator('CF', NFermions, IndexUp_Ld, IndexDn_Ld, IndexUp_4d, IndexDn_4d, PotentialExpandedOnClm('D4h', 2, {0, 0, 1, 0}))
               + NewOperator('CF', NFermions, IndexUp_4d, IndexDn_4d, IndexUp_Ld, IndexDn_Ld, PotentialExpandedOnClm('D4h', 2, {0, 0, 1, 0}))

    Veg_4d_Ld = NewOperator('CF', NFermions, IndexUp_Ld, IndexDn_Ld, IndexUp_4d, IndexDn_4d, PotentialExpandedOnClm('D4h', 2, {0, 0, 0, 1}))
              + NewOperator('CF', NFermions, IndexUp_4d, IndexDn_4d, IndexUp_Ld, IndexDn_Ld, PotentialExpandedOnClm('D4h', 2, {0, 0, 0, 1}))

    Dq_Ld_i = $Dq(Ld)_i_value
    Ds_Ld_i = $Ds(Ld)_i_value
    Dt_Ld_i = $Dt(Ld)_i_value
    Va1g_4d_Ld_i = $Va1g(4d,Ld)_i_value
    Vb1g_4d_Ld_i = $Vb1g(4d,Ld)_i_value
    Vb2g_4d_Ld_i = $Vb2g(4d,Ld)_i_value
    Veg_4d_Ld_i = $Veg(4d,Ld)_i_value

    Dq_Ld_m = $Dq(Ld)_m_value
    Ds_Ld_m = $Ds(Ld)_m_value
    Dt_Ld_m = $Dt(Ld)_m_value
    Va1g_4d_Ld_m = $Va1g(4d,Ld)_m_value
    Vb1g_4d_Ld_m = $Vb1g(4d,Ld)_m_value
    Vb2g_4d_Ld_m = $Vb2g(4d,Ld)_m_value
    Veg_4d_Ld_m = $Veg(4d,Ld)_m_value

    Dq_Ld_f = $Dq(Ld)_f_value
    Ds_Ld_f = $Ds(Ld)_f_value
    Dt_Ld_f = $Dt(Ld)_f_value
    Va1g_4d_Ld_f = $Va1g(4d,Ld)_f_value
    Vb1g_4d_Ld_f = $Vb1g(4d,Ld)_f_value
    Vb2g_4d_Ld_f = $Vb2g(4d,Ld)_f_value
    Veg_4d_Ld_f = $Veg(4d,Ld)_f_value

    H_i = H_i + Chop(
          Dq_Ld_i * Dq_Ld
        + Ds_Ld_i * Ds_Ld
        + Dt_Ld_i * Dt_Ld
        + Va1g_4d_Ld_i * Va1g_4d_Ld
        + Vb1g_4d_Ld_i * Vb1g_4d_Ld
        + Vb2g_4d_Ld_i * Vb2g_4d_Ld
        + Veg_4d_Ld_i * Veg_4d_Ld)

    H_m = H_m + Chop(
          Dq_Ld_m * Dq_Ld
        + Ds_Ld_m * Ds_Ld
        + Dt_Ld_m * Dt_Ld
        + Va1g_4d_Ld_m * Va1g_4d_Ld
        + Vb1g_4d_Ld_m * Vb1g_4d_Ld
        + Vb2g_4d_Ld_m * Vb2g_4d_Ld
        + Veg_4d_Ld_m * Veg_4d_Ld)

    H_f = H_f + Chop(
          Dq_Ld_f * Dq_Ld
        + Ds_Ld_f * Ds_Ld
        + Dt_Ld_f * Dt_Ld
        + Va1g_4d_Ld_f * Va1g_4d_Ld
        + Vb1g_4d_Ld_f * Vb1g_4d_Ld
        + Vb2g_4d_Ld_f * Vb2g_4d_Ld
        + Veg_4d_Ld_f * Veg_4d_Ld)
end

--------------------------------------------------------------------------------
-- Define the spin and orbital operators.
--------------------------------------------------------------------------------
Sx_4d = NewOperator('Sx', NFermions, IndexUp_4d, IndexDn_4d)
Sy_4d = NewOperator('Sy', NFermions, IndexUp_4d, IndexDn_4d)
Sz_4d = NewOperator('Sz', NFermions, IndexUp_4d, IndexDn_4d)
Ssqr_4d = NewOperator('Ssqr', NFermions, IndexUp_4d, IndexDn_4d)
Splus_4d = NewOperator('Splus', NFermions, IndexUp_4d, IndexDn_4d)
Smin_4d = NewOperator('Smin', NFermions, IndexUp_4d, IndexDn_4d)

Lx_4d = NewOperator('Lx', NFermions, IndexUp_4d, IndexDn_4d)
Ly_4d = NewOperator('Ly', NFermions, IndexUp_4d, IndexDn_4d)
Lz_4d = NewOperator('Lz', NFermions, IndexUp_4d, IndexDn_4d)
Lsqr_4d = NewOperator('Lsqr', NFermions, IndexUp_4d, IndexDn_4d)
Lplus_4d = NewOperator('Lplus', NFermions, IndexUp_4d, IndexDn_4d)
Lmin_4d = NewOperator('Lmin', NFermions, IndexUp_4d, IndexDn_4d)

Jx_4d = NewOperator('Jx', NFermions, IndexUp_4d, IndexDn_4d)
Jy_4d = NewOperator('Jy', NFermions, IndexUp_4d, IndexDn_4d)
Jz_4d = NewOperator('Jz', NFermions, IndexUp_4d, IndexDn_4d)
Jsqr_4d = NewOperator('Jsqr', NFermions, IndexUp_4d, IndexDn_4d)
Jplus_4d = NewOperator('Jplus', NFermions, IndexUp_4d, IndexDn_4d)
Jmin_4d = NewOperator('Jmin', NFermions, IndexUp_4d, IndexDn_4d)

Sx = Sx_4d
Sy = Sy_4d
Sz = Sz_4d

Lx = Lx_4d
Ly = Ly_4d
Lz = Lz_4d

Jx = Jx_4d
Jy = Jy_4d
Jz = Jz_4d

Ssqr = Sx * Sx + Sy * Sy + Sz * Sz
Lsqr = Lx * Lx + Ly * Ly + Lz * Lz
Jsqr = Jx * Jx + Jy * Jy + Jz * Jz

NConfigurations = $NConfigurations

--------------------------------------------------------------------------------
-- Define the restrictions and set the number of initial states.
--------------------------------------------------------------------------------
InitialRestrictions = {NFermions, NBosons, {'111111 0000000000', NElectrons_2p, NElectrons_2p},
                                           {'000000 1111111111', NElectrons_4d, NElectrons_4d}}

IntermediateRestrictions = {NFermions, NBosons, {'111111 0000000000', NElectrons_2p - 1, NElectrons_2p - 1},
                                                {'000000 1111111111', NElectrons_4d + 1, NElectrons_4d + 1}}

FinalRestrictions = InitialRestrictions

if H_4d_Ld_hybridization == 1 then
    InitialRestrictions = {NFermions, NBosons, {'111111 0000000000 0000000000', NElectrons_2p, NElectrons_2p},
                                               {'000000 1111111111 0000000000', NElectrons_4d, NElectrons_4d},
                                               {'000000 0000000000 1111111111', NElectrons_Ld, NElectrons_Ld}}

    IntermediateRestrictions = {NFermions, NBosons, {'111111 0000000000 0000000000', NElectrons_2p - 1, NElectrons_2p - 1},
                                                    {'000000 1111111111 0000000000', NElectrons_4d + 1, NElectrons_4d + 1},
                                                    {'000000 0000000000 1111111111', NElectrons_Ld, NElectrons_Ld}}

    FinalRestrictions = InitialRestrictions

    CalculationRestrictions = {NFermions, NBosons, {'000000 0000000000 1111111111', NElectrons_Ld - (NConfigurations - 1), NElectrons_Ld}}
end

Operators = {H_i, Ssqr, Lsqr, Jsqr, Sz, Lz, Jz, N_2p, N_4d, 'dZ'}
header = 'Analysis of the initial Hamiltonian:\n'
header = header .. '=============================================================================================================\n'
header = header .. 'State         <E>     <S^2>     <L^2>     <J^2>      <Sz>      <Lz>      <Jz>    <N_2p>    <N_4d>          dZ\n'
header = header .. '=============================================================================================================\n'
footer = '=============================================================================================================\n'

if H_4d_Ld_hybridization == 1 then
    Operators = {H_i, Ssqr, Lsqr, Jsqr, Sz, Lz, Jz, N_2p, N_4d, N_Ld, 'dZ'}
    header = 'Analysis of the initial Hamiltonian:\n'
    header = header .. '=======================================================================================================================\n'
    header = header .. 'State         <E>     <S^2>     <L^2>     <J^2>      <Sz>      <Lz>      <Jz>    <N_2p>    <N_4d>    <N_Ld>          dZ\n'
    header = header .. '=======================================================================================================================\n'
    footer = '=======================================================================================================================\n'
end

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

Tx_2p_4d = NewOperator('CF', NFermions, IndexUp_4d, IndexDn_4d, IndexUp_2p, IndexDn_2p, {{1, -1, t    }, {1, 1, -t    }})
Ty_2p_4d = NewOperator('CF', NFermions, IndexUp_4d, IndexDn_4d, IndexUp_2p, IndexDn_2p, {{1, -1, t * I}, {1, 1,  t * I}})
Tz_2p_4d = NewOperator('CF', NFermions, IndexUp_4d, IndexDn_4d, IndexUp_2p, IndexDn_2p, {{1,  0, 1    }                })

Tx_4d_2p = NewOperator('CF', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_4d, IndexDn_4d, {{1, -1, t    }, {1, 1, -t    }})
Ty_4d_2p = NewOperator('CF', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_4d, IndexDn_4d, {{1, -1, t * I}, {1, 1,  t * I}})
Tz_4d_2p = NewOperator('CF', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_4d, IndexDn_4d, {{1,  0, 1    }                })

T_2p_4d = {Tx_2p_4d, Ty_2p_4d, Tz_2p_4d}
T_4d_2p = {Tx_4d_2p, Ty_4d_2p, Tz_4d_2p}

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

totalCalculations = #Psis_i * #T_2p_4d * #T_4d_2p
calculation = 1

for i, Psi in ipairs(Psis_i) do
    for j, OperatorIn in ipairs(T_2p_4d) do
        for k, OperatorOut in ipairs(T_4d_2p) do
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

