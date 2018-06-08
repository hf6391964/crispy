--------------------------------------------------------------------------------
-- Quanty input file generated using Crispy. If you use this file please cite
-- the following reference: 10.5281/zenodo.1008184.
--
-- elements: 5d
-- symmetry: D4h
-- experiment: RIXS
-- edge: L2,3-O4,5 (2p5d)
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
H_5d_Ld_hybridization = $H_5d_Ld_hybridization
H_magnetic_field = $H_magnetic_field
H_exchange_field = $H_exchange_field

--------------------------------------------------------------------------------
-- Define the number of electrons, shells, etc.
--------------------------------------------------------------------------------
NBosons = 0
NFermions = 16

NElectrons_2p = 6
NElectrons_5d = $NElectrons_5d

IndexDn_2p = {0, 2, 4}
IndexUp_2p = {1, 3, 5}
IndexDn_5d = {6, 8, 10, 12, 14}
IndexUp_5d = {7, 9, 11, 13, 15}

if H_5d_Ld_hybridization == 1 then
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

N_5d = NewOperator('Number', NFermions, IndexUp_5d, IndexUp_5d, {1, 1, 1, 1, 1})
     + NewOperator('Number', NFermions, IndexDn_5d, IndexDn_5d, {1, 1, 1, 1, 1})

if H_atomic == 1 then
    F0_5d_5d = NewOperator('U', NFermions, IndexUp_5d, IndexDn_5d, {1, 0, 0})
    F2_5d_5d = NewOperator('U', NFermions, IndexUp_5d, IndexDn_5d, {0, 1, 0})
    F4_5d_5d = NewOperator('U', NFermions, IndexUp_5d, IndexDn_5d, {0, 0, 1})

    F0_2p_5d = NewOperator('U', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_5d, IndexDn_5d, {1, 0}, {0, 0})
    F2_2p_5d = NewOperator('U', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_5d, IndexDn_5d, {0, 1}, {0, 0})
    G1_2p_5d = NewOperator('U', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_5d, IndexDn_5d, {0, 0}, {1, 0})
    G3_2p_5d = NewOperator('U', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_5d, IndexDn_5d, {0, 0}, {0, 1})

    F2_5d_5d_i = $F2(5d,5d)_i_value * $F2(5d,5d)_i_scaling
    F4_5d_5d_i = $F4(5d,5d)_i_value * $F4(5d,5d)_i_scaling
    F0_5d_5d_i = 2 / 63 * F2_5d_5d_i + 2 / 63 * F4_5d_5d_i

    F2_5d_5d_m = $F2(5d,5d)_m_value * $F2(5d,5d)_m_scaling
    F4_5d_5d_m = $F4(5d,5d)_m_value * $F4(5d,5d)_m_scaling
    F0_5d_5d_m = 2 / 63 * F2_5d_5d_m + 2 / 63 * F4_5d_5d_m
    F2_2p_5d_m = $F2(2p,5d)_m_value * $F2(2p,5d)_m_scaling
    G1_2p_5d_m = $G1(2p,5d)_m_value * $G1(2p,5d)_m_scaling
    G3_2p_5d_m = $G3(2p,5d)_m_value * $G3(2p,5d)_m_scaling
    F0_2p_5d_m = 1 / 15 * G1_2p_5d_m + 3 / 70 * G3_2p_5d_m

    F2_5d_5d_f = $F2(5d,5d)_f_value * $F2(5d,5d)_f_scaling
    F4_5d_5d_f = $F4(5d,5d)_f_value * $F4(5d,5d)_f_scaling
    F0_5d_5d_f = 2 / 63 * F2_5d_5d_f + 2 / 63 * F4_5d_5d_f

    H_i = H_i + Chop(
          F0_5d_5d_i * F0_5d_5d
        + F2_5d_5d_i * F2_5d_5d
        + F4_5d_5d_i * F4_5d_5d)

    H_m = H_m + Chop(
          F0_5d_5d_m * F0_5d_5d
        + F2_5d_5d_m * F2_5d_5d
        + F4_5d_5d_m * F4_5d_5d
        + F0_2p_5d_m * F0_2p_5d
        + F2_2p_5d_m * F2_2p_5d
        + G1_2p_5d_m * G1_2p_5d
        + G3_2p_5d_m * G3_2p_5d)

    H_f = H_f + Chop(
          F0_5d_5d_f * F0_5d_5d
        + F2_5d_5d_f * F2_5d_5d
        + F4_5d_5d_f * F4_5d_5d)

    ldots_5d = NewOperator('ldots', NFermions, IndexUp_5d, IndexDn_5d)

    ldots_2p = NewOperator('ldots', NFermions, IndexUp_2p, IndexDn_2p)

    zeta_5d_i = $zeta(5d)_i_value * $zeta(5d)_i_scaling

    zeta_5d_m = $zeta(5d)_m_value * $zeta(5d)_m_scaling
    zeta_2p_m = $zeta(2p)_m_value * $zeta(2p)_m_scaling

    zeta_5d_f = $zeta(5d)_f_value * $zeta(5d)_f_scaling

    H_i = H_i + Chop(
          zeta_5d_i * ldots_5d)

    H_m = H_m + Chop(
          zeta_5d_m * ldots_5d
        + zeta_2p_m * ldots_2p)

    H_f = H_f + Chop(
          zeta_5d_f * ldots_5d)
end

--------------------------------------------------------------------------------
-- Define the crystal field term.
--------------------------------------------------------------------------------
if H_cf == 1 then
    -- PotentialExpandedOnClm('D4h', 2, {Ea1g, Eb1g, Eb2g, Eeg})
    Dq_5d = NewOperator('CF', NFermions, IndexUp_5d, IndexDn_5d, PotentialExpandedOnClm('D4h', 2, { 6,  6, -4, -4}))
    Ds_5d = NewOperator('CF', NFermions, IndexUp_5d, IndexDn_5d, PotentialExpandedOnClm('D4h', 2, {-2,  2,  2, -1}))
    Dt_5d = NewOperator('CF', NFermions, IndexUp_5d, IndexDn_5d, PotentialExpandedOnClm('D4h', 2, {-6, -1, -1,  4}))

    Dq_5d_i = $Dq(5d)_i_value
    Ds_5d_i = $Ds(5d)_i_value
    Dt_5d_i = $Dt(5d)_i_value

    Dq_5d_m = $Dq(5d)_m_value
    Ds_5d_m = $Ds(5d)_m_value
    Dt_5d_m = $Dt(5d)_m_value

    Dq_5d_f = $Dq(5d)_f_value
    Ds_5d_f = $Ds(5d)_f_value
    Dt_5d_f = $Dt(5d)_f_value

    H_i = H_i + Chop(
          Dq_5d_i * Dq_5d
        + Ds_5d_i * Ds_5d
        + Dt_5d_i * Dt_5d)

    H_m = H_m + Chop(
          Dq_5d_m * Dq_5d
        + Ds_5d_m * Ds_5d
        + Dt_5d_m * Dt_5d)

    H_f = H_f + Chop(
          Dq_5d_f * Dq_5d
        + Ds_5d_f * Ds_5d
        + Dt_5d_f * Dt_5d)
end

--------------------------------------------------------------------------------
-- Define the 5d-Ld hybridization term.
--------------------------------------------------------------------------------
if H_5d_Ld_hybridization == 1 then
    N_Ld = NewOperator('Number', NFermions, IndexUp_Ld, IndexUp_Ld, {1, 1, 1, 1, 1})
         + NewOperator('Number', NFermions, IndexDn_Ld, IndexDn_Ld, {1, 1, 1, 1, 1})

    Delta_5d_Ld_i = $Delta(5d,Ld)_i_value
    U_5d_5d_i = $U(5d,5d)_i_value
    e_5d_i = (10 * Delta_5d_Ld_i - NElectrons_5d * (19 + NElectrons_5d) * U_5d_5d_i / 2) / (10 + NElectrons_5d)
    e_Ld_i = NElectrons_5d * ((1 + NElectrons_5d) * U_5d_5d_i / 2 - Delta_5d_Ld_i) / (10 + NElectrons_5d)

    Delta_5d_Ld_m = $Delta(5d,Ld)_m_value
    U_5d_5d_m = $U(5d,5d)_m_value
    U_2p_5d_m = $U(2p,5d)_m_value
    e_5d_m = (10 * Delta_5d_Ld_m - NElectrons_5d * (31 + NElectrons_5d) * U_5d_5d_m / 2 - 90 * U_2p_5d_m) / (16 + NElectrons_5d)
    e_2p_m = (10 * Delta_5d_Ld_m + (1 + NElectrons_5d) * (NElectrons_5d * U_5d_5d_m / 2 - (10 + NElectrons_5d) * U_2p_5d_m)) / (16 + NElectrons_5d)
    e_Ld_m = ((1 + NElectrons_5d) * (NElectrons_5d * U_5d_5d_m / 2 + 6 * U_2p_5d_m) - (6 + NElectrons_5d) * Delta_5d_Ld_m) / (16 + NElectrons_5d)

    Delta_5d_Ld_f = $Delta(5d,Ld)_f_value
    U_5d_5d_f = $U(5d,5d)_f_value
    e_5d_f = (10 * Delta_5d_Ld_f - NElectrons_5d * (19 + NElectrons_5d) * U_5d_5d_f / 2) / (10 + NElectrons_5d)
    e_Ld_f = NElectrons_5d * ((1 + NElectrons_5d) * U_5d_5d_f / 2 - Delta_5d_Ld_f) / (10 + NElectrons_5d)

    H_i = H_i + Chop(
          U_5d_5d_i * F0_5d_5d
        + e_5d_i * N_5d
        + e_Ld_i * N_Ld)

    H_m = H_m + Chop(
          U_5d_5d_m * F0_5d_5d
        + U_2p_5d_m * F0_2p_5d
        + e_5d_m * N_5d
        + e_2p_m * N_2p
        + e_Ld_m * N_Ld)

    H_f = H_f + Chop(
          U_5d_5d_f * F0_5d_5d
        + e_5d_f * N_5d
        + e_Ld_f * N_Ld)

    Dq_Ld = NewOperator('CF', NFermions, IndexUp_Ld, IndexDn_Ld, PotentialExpandedOnClm('D4h', 2, { 6,  6, -4, -4}))
    Ds_Ld = NewOperator('CF', NFermions, IndexUp_Ld, IndexDn_Ld, PotentialExpandedOnClm('D4h', 2, {-2,  2,  2, -1}))
    Dt_Ld = NewOperator('CF', NFermions, IndexUp_Ld, IndexDn_Ld, PotentialExpandedOnClm('D4h', 2, {-6, -1, -1,  4}))

    Va1g_5d_Ld = NewOperator('CF', NFermions, IndexUp_Ld, IndexDn_Ld, IndexUp_5d, IndexDn_5d, PotentialExpandedOnClm('D4h', 2, {1, 0, 0, 0}))
               + NewOperator('CF', NFermions, IndexUp_5d, IndexDn_5d, IndexUp_Ld, IndexDn_Ld, PotentialExpandedOnClm('D4h', 2, {1, 0, 0, 0}))

    Vb1g_5d_Ld = NewOperator('CF', NFermions, IndexUp_Ld, IndexDn_Ld, IndexUp_5d, IndexDn_5d, PotentialExpandedOnClm('D4h', 2, {0, 1, 0, 0}))
               + NewOperator('CF', NFermions, IndexUp_5d, IndexDn_5d, IndexUp_Ld, IndexDn_Ld, PotentialExpandedOnClm('D4h', 2, {0, 1, 0, 0}))

    Vb2g_5d_Ld = NewOperator('CF', NFermions, IndexUp_Ld, IndexDn_Ld, IndexUp_5d, IndexDn_5d, PotentialExpandedOnClm('D4h', 2, {0, 0, 1, 0}))
               + NewOperator('CF', NFermions, IndexUp_5d, IndexDn_5d, IndexUp_Ld, IndexDn_Ld, PotentialExpandedOnClm('D4h', 2, {0, 0, 1, 0}))

    Veg_5d_Ld = NewOperator('CF', NFermions, IndexUp_Ld, IndexDn_Ld, IndexUp_5d, IndexDn_5d, PotentialExpandedOnClm('D4h', 2, {0, 0, 0, 1}))
              + NewOperator('CF', NFermions, IndexUp_5d, IndexDn_5d, IndexUp_Ld, IndexDn_Ld, PotentialExpandedOnClm('D4h', 2, {0, 0, 0, 1}))

    Dq_Ld_i = $Dq(Ld)_i_value
    Ds_Ld_i = $Ds(Ld)_i_value
    Dt_Ld_i = $Dt(Ld)_i_value
    Va1g_5d_Ld_i = $Va1g(5d,Ld)_i_value
    Vb1g_5d_Ld_i = $Vb1g(5d,Ld)_i_value
    Vb2g_5d_Ld_i = $Vb2g(5d,Ld)_i_value
    Veg_5d_Ld_i = $Veg(5d,Ld)_i_value

    Dq_Ld_m = $Dq(Ld)_m_value
    Ds_Ld_m = $Ds(Ld)_m_value
    Dt_Ld_m = $Dt(Ld)_m_value
    Va1g_5d_Ld_m = $Va1g(5d,Ld)_m_value
    Vb1g_5d_Ld_m = $Vb1g(5d,Ld)_m_value
    Vb2g_5d_Ld_m = $Vb2g(5d,Ld)_m_value
    Veg_5d_Ld_m = $Veg(5d,Ld)_m_value

    Dq_Ld_f = $Dq(Ld)_f_value
    Ds_Ld_f = $Ds(Ld)_f_value
    Dt_Ld_f = $Dt(Ld)_f_value
    Va1g_5d_Ld_f = $Va1g(5d,Ld)_f_value
    Vb1g_5d_Ld_f = $Vb1g(5d,Ld)_f_value
    Vb2g_5d_Ld_f = $Vb2g(5d,Ld)_f_value
    Veg_5d_Ld_f = $Veg(5d,Ld)_f_value

    H_i = H_i + Chop(
          Dq_Ld_i * Dq_Ld
        + Ds_Ld_i * Ds_Ld
        + Dt_Ld_i * Dt_Ld
        + Va1g_5d_Ld_i * Va1g_5d_Ld
        + Vb1g_5d_Ld_i * Vb1g_5d_Ld
        + Vb2g_5d_Ld_i * Vb2g_5d_Ld
        + Veg_5d_Ld_i * Veg_5d_Ld)

    H_m = H_m + Chop(
          Dq_Ld_m * Dq_Ld
        + Ds_Ld_m * Ds_Ld
        + Dt_Ld_m * Dt_Ld
        + Va1g_5d_Ld_m * Va1g_5d_Ld
        + Vb1g_5d_Ld_m * Vb1g_5d_Ld
        + Vb2g_5d_Ld_m * Vb2g_5d_Ld
        + Veg_5d_Ld_m * Veg_5d_Ld)

    H_f = H_f + Chop(
          Dq_Ld_f * Dq_Ld
        + Ds_Ld_f * Ds_Ld
        + Dt_Ld_f * Dt_Ld
        + Va1g_5d_Ld_f * Va1g_5d_Ld
        + Vb1g_5d_Ld_f * Vb1g_5d_Ld
        + Vb2g_5d_Ld_f * Vb2g_5d_Ld
        + Veg_5d_Ld_f * Veg_5d_Ld)
end

--------------------------------------------------------------------------------
-- Define the magnetic field and exchange field terms.
--------------------------------------------------------------------------------
Sx_5d = NewOperator('Sx', NFermions, IndexUp_5d, IndexDn_5d)
Sy_5d = NewOperator('Sy', NFermions, IndexUp_5d, IndexDn_5d)
Sz_5d = NewOperator('Sz', NFermions, IndexUp_5d, IndexDn_5d)
Ssqr_5d = NewOperator('Ssqr', NFermions, IndexUp_5d, IndexDn_5d)
Splus_5d = NewOperator('Splus', NFermions, IndexUp_5d, IndexDn_5d)
Smin_5d = NewOperator('Smin', NFermions, IndexUp_5d, IndexDn_5d)

Lx_5d = NewOperator('Lx', NFermions, IndexUp_5d, IndexDn_5d)
Ly_5d = NewOperator('Ly', NFermions, IndexUp_5d, IndexDn_5d)
Lz_5d = NewOperator('Lz', NFermions, IndexUp_5d, IndexDn_5d)
Lsqr_5d = NewOperator('Lsqr', NFermions, IndexUp_5d, IndexDn_5d)
Lplus_5d = NewOperator('Lplus', NFermions, IndexUp_5d, IndexDn_5d)
Lmin_5d = NewOperator('Lmin', NFermions, IndexUp_5d, IndexDn_5d)

Jx_5d = NewOperator('Jx', NFermions, IndexUp_5d, IndexDn_5d)
Jy_5d = NewOperator('Jy', NFermions, IndexUp_5d, IndexDn_5d)
Jz_5d = NewOperator('Jz', NFermions, IndexUp_5d, IndexDn_5d)
Jsqr_5d = NewOperator('Jsqr', NFermions, IndexUp_5d, IndexDn_5d)
Jplus_5d = NewOperator('Jplus', NFermions, IndexUp_5d, IndexDn_5d)
Jmin_5d = NewOperator('Jmin', NFermions, IndexUp_5d, IndexDn_5d)

Sx = Sx_5d
Sy = Sy_5d
Sz = Sz_5d

Lx = Lx_5d
Ly = Ly_5d
Lz = Lz_5d

Jx = Jx_5d
Jy = Jy_5d
Jz = Jz_5d

Ssqr = Sx * Sx + Sy * Sy + Sz * Sz
Lsqr = Lx * Lx + Ly * Ly + Lz * Lz
Jsqr = Jx * Jx + Jy * Jy + Jz * Jz

if H_magnetic_field == 1 then
    Bx_i = $Bx_i_value * EnergyUnits.Tesla.value
    By_i = $By_i_value * EnergyUnits.Tesla.value
    Bz_i = $Bz_i_value * EnergyUnits.Tesla.value

    Bx_m = $Bx_m_value * EnergyUnits.Tesla.value
    By_m = $By_m_value * EnergyUnits.Tesla.value
    Bz_m = $Bz_m_value * EnergyUnits.Tesla.value

    Bx_f = $Bx_f_value * EnergyUnits.Tesla.value
    By_f = $By_f_value * EnergyUnits.Tesla.value
    Bz_f = $Bz_f_value * EnergyUnits.Tesla.value

    H_i = H_i + Chop(
          Bx_i * (2 * Sx + Lx)
        + By_i * (2 * Sy + Ly)
        + Bz_i * (2 * Sz + Lz))

    H_m = H_m + Chop(
          Bx_m * (2 * Sx + Lx)
        + By_m * (2 * Sy + Ly)
        + Bz_m * (2 * Sz + Lz))

    H_f = H_f + Chop(
          Bx_f * (2 * Sx + Lx)
        + By_f * (2 * Sy + Ly)
        + Bz_f * (2 * Sz + Lz))
end

if H_exchange_field == 1 then
    Hx_i = $Hx_i_value
    Hy_i = $Hy_i_value
    Hz_i = $Hz_i_value

    Hx_m = $Hx_m_value
    Hy_m = $Hy_m_value
    Hz_m = $Hz_m_value

    Hx_f = $Hx_f_value
    Hy_f = $Hy_f_value
    Hz_f = $Hz_f_value

    H_i = H_i + Chop(
          Hx_i * Sx
        + Hy_i * Sy
        + Hz_i * Sz)

    H_m = H_m + Chop(
          Hx_m * Sx
        + Hy_m * Sy
        + Hz_m * Sz)

    H_f = H_f + Chop(
          Hx_f * Sx
        + Hy_f * Sy
        + Hz_f * Sz)
end

NConfigurations = $NConfigurations
Experiment = '$Experiment'

--------------------------------------------------------------------------------
-- Define the restrictions and set the number of initial states.
--------------------------------------------------------------------------------
InitialRestrictions = {NFermions, NBosons, {'111111 0000000000', NElectrons_2p, NElectrons_2p},
                                           {'000000 1111111111', NElectrons_5d, NElectrons_5d}}

IntermediateRestrictions = {NFermions, NBosons, {'111111 0000000000', NElectrons_2p - 1, NElectrons_2p - 1},
                                                {'000000 1111111111', NElectrons_5d + 1, NElectrons_5d + 1}}

FinalRestrictions = InitialRestrictions

if H_5d_Ld_hybridization == 1 then
    InitialRestrictions = {NFermions, NBosons, {'111111 0000000000 0000000000', NElectrons_2p, NElectrons_2p},
                                               {'000000 1111111111 0000000000', NElectrons_5d, NElectrons_5d},
                                               {'000000 0000000000 1111111111', NElectrons_Ld, NElectrons_Ld}}

    IntermediateRestrictions = {NFermions, NBosons, {'111111 0000000000 0000000000', NElectrons_2p - 1, NElectrons_2p - 1},
                                                    {'000000 1111111111 0000000000', NElectrons_5d + 1, NElectrons_5d + 1},
                                                    {'000000 0000000000 1111111111', NElectrons_Ld, NElectrons_Ld}}

    FinalRestrictions = InitialRestrictions

    CalculationRestrictions = {NFermions, NBosons, {'000000 0000000000 1111111111', NElectrons_Ld - (NConfigurations - 1), NElectrons_Ld}}
end

Operators = {H_i, Ssqr, Lsqr, Jsqr, Sz, Lz, Jz, N_2p, N_5d, 'dZ'}
header = 'Analysis of the initial Hamiltonian:\n'
header = header .. '=============================================================================================================\n'
header = header .. 'State         <E>     <S^2>     <L^2>     <J^2>      <Sz>      <Lz>      <Jz>    <N_2p>    <N_5d>          dZ\n'
header = header .. '=============================================================================================================\n'
footer = '=============================================================================================================\n'

if H_5d_Ld_hybridization == 1 then
    Operators = {H_i, Ssqr, Lsqr, Jsqr, Sz, Lz, Jz, N_2p, N_5d, N_Ld, 'dZ'}
    header = 'Analysis of the initial Hamiltonian:\n'
    header = header .. '=======================================================================================================================\n'
    header = header .. 'State         <E>     <S^2>     <L^2>     <J^2>      <Sz>      <Lz>      <Jz>    <N_2p>    <N_5d>    <N_Ld>          dZ\n'
    header = header .. '=======================================================================================================================\n'
    footer = '=======================================================================================================================\n'
end

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

Tx_2p_5d = NewOperator('CF', NFermions, IndexUp_5d, IndexDn_5d, IndexUp_2p, IndexDn_2p, {{1, -1, t    }, {1, 1, -t    }})
Ty_2p_5d = NewOperator('CF', NFermions, IndexUp_5d, IndexDn_5d, IndexUp_2p, IndexDn_2p, {{1, -1, t * I}, {1, 1,  t * I}})
Tz_2p_5d = NewOperator('CF', NFermions, IndexUp_5d, IndexDn_5d, IndexUp_2p, IndexDn_2p, {{1,  0, 1    }                })

Tx_5d_2p = NewOperator('CF', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_5d, IndexDn_5d, {{1, -1, t    }, {1, 1, -t    }})
Ty_5d_2p = NewOperator('CF', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_5d, IndexDn_5d, {{1, -1, t * I}, {1, 1,  t * I}})
Tz_5d_2p = NewOperator('CF', NFermions, IndexUp_2p, IndexDn_2p, IndexUp_5d, IndexDn_5d, {{1,  0, 1    }                })

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

totalCalculations = #Psis_i
calculation = 1

for i, Psi in ipairs(Psis_i) do
    io.write(string.format('Running calculation %d of %d.\n', calculation, totalCalculations))
    if CalculationRestrictions == nil then
        G = G + CreateResonantSpectra(H_m, H_f, {Tx_2p_5d, Ty_2p_5d, Tz_2p_5d}, {Tx_5d_2p, Ty_5d_2p, Tz_5d_2p}, Psi, {{'Emin1', Emin1}, {'Emax1', Emax1}, {'NE1', NE1}, {'Gamma1', Gamma1}, {'Emin2', Emin2}, {'Emax2', Emax2}, {'NE2', NE2}, {'Gamma2', Gamma2}}) * dZ[i]
    else
        G = G + CreateResonantSpectra(H_m, H_f, {Tx_2p_5d, Ty_2p_5d, Tz_2p_5d}, {Tx_5d_2p, Ty_5d_2p, Tz_5d_2p}, Psi, {{'Emin1', Emin1}, {'Emax1', Emax1}, {'NE1', NE1}, {'Gamma1', Gamma1}, {'Emin2', Emin2}, {'Emax2', Emax2}, {'NE2', NE2}, {'Gamma2', Gamma2}, {'restrictions1', CalculationRestrictions}}) * dZ[i]
    end
    calculation = calculation + 1
end

Gtot = 0
ishift = 0

-- The number of operators in times the number of operators out.
for i = 1, 3 * 3 do
    Indices = {}
    for i = 1, NE1 + 1 do
        table.insert(Indices, i + ishift)
    end
    Gtot = Gtot + Spectra.Element(G, Indices)
    ishift = ishift + NE1 + 1
end

Gtot.Print({{'file', '$BaseName.spec'}})
