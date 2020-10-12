--------------------------------------------------------------------------------
-- Quanty input file generated using Crispy. If you use this file please cite
-- the following reference: http://dx.doi.org/10.5281/zenodo.1008184.
--
-- elements: 5d
-- symmetry: C3v
-- experiment: XAS
-- edge: M1 (3s)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Set the verbosity of the calculation. For increased verbosity use the values
-- 0x00FF or 0xFFFF.
--------------------------------------------------------------------------------
Verbosity($Verbosity)

--------------------------------------------------------------------------------
-- Define the parameters of the calculation.
--------------------------------------------------------------------------------
Temperature = $Temperature -- temperature (Kelvin)

NPsis = $NPsis  -- number of states to consider in the spectra calculation
NPsisAuto = $NPsisAuto  -- determine the number of state automatically
NConfigurations = $NConfigurations  -- number of configurations

Emin = $XEmin  -- minimum value of the energy range (eV)
Emax = $XEmax  -- maximum value of the energy range (eV)
NPoints = $XNPoints  -- number of points of the spectra
ExperimentalShift = $XExperimentalShift  -- experimental edge energy (eV)
ZeroShift = $XZeroShift  -- energy required to shift the calculated spectrum to start from approximately zero (eV)
Gaussian = $XGaussian  -- Gaussian FWHM (eV)
Lorentzian = $XLorentzian  -- Lorentzian FWHM (eV)
Gamma = $XGamma   -- Lorentzian FWHM used in the spectra calculation (eV)

WaveVector = $XWaveVector  -- wave vector
Ev = $XFirstPolarization  -- vertical polarization
Eh = $XSecondPolarization  -- horizontal polarization

SpectraToCalculate = $SpectraToCalculate  -- types of spectra to calculate
DenseBorder = $DenseBorder -- number of determinants where we switch from dense methods to sparse methods

Prefix = "$Prefix"  -- file name prefix

--------------------------------------------------------------------------------
-- Toggle the Hamiltonian terms.
--------------------------------------------------------------------------------
AtomicTerm = $AtomicTerm
CrystalFieldTerm = $CrystalFieldTerm
MagneticFieldTerm = $MagneticFieldTerm
ExchangeFieldTerm = $ExchangeFieldTerm

--------------------------------------------------------------------------------
-- Define the number of electrons, shells, etc.
--------------------------------------------------------------------------------
NBosons = 0
NFermions = 12

NElectrons_3s = 2
NElectrons_5d = $NElectrons_5d

IndexDn_3s = {0}
IndexUp_3s = {1}
IndexDn_5d = {2, 4, 6, 8, 10}
IndexUp_5d = {3, 5, 7, 9, 11}

--------------------------------------------------------------------------------
-- Initialize the Hamiltonians.
--------------------------------------------------------------------------------
H_i = 0
H_f = 0


--------------------------------------------------------------------------------
-- Define the atomic term.
--------------------------------------------------------------------------------
N_3s = NewOperator("Number", NFermions, IndexUp_3s, IndexUp_3s, {1})
     + NewOperator("Number", NFermions, IndexDn_3s, IndexDn_3s, {1})

N_5d = NewOperator("Number", NFermions, IndexUp_5d, IndexUp_5d, {1, 1, 1, 1, 1})
     + NewOperator("Number", NFermions, IndexDn_5d, IndexDn_5d, {1, 1, 1, 1, 1})

if AtomicTerm then
    F0_5d_5d = NewOperator("U", NFermions, IndexUp_5d, IndexDn_5d, {1, 0, 0})
    F2_5d_5d = NewOperator("U", NFermions, IndexUp_5d, IndexDn_5d, {0, 1, 0})
    F4_5d_5d = NewOperator("U", NFermions, IndexUp_5d, IndexDn_5d, {0, 0, 1})

    F0_3s_5d = NewOperator("U", NFermions, IndexUp_3s, IndexDn_3s, IndexUp_5d, IndexDn_5d, {1}, {0})
    G2_3s_5d = NewOperator("U", NFermions, IndexUp_3s, IndexDn_3s, IndexUp_5d, IndexDn_5d, {0}, {1})

    U_5d_5d_i = $U(5d,5d)_i_value
    F2_5d_5d_i = $F2(5d,5d)_i_value * $F2(5d,5d)_i_scaleFactor
    F4_5d_5d_i = $F4(5d,5d)_i_value * $F4(5d,5d)_i_scaleFactor
    F0_5d_5d_i = U_5d_5d_i + 2 / 63 * F2_5d_5d_i + 2 / 63 * F4_5d_5d_i

    U_5d_5d_f = $U(5d,5d)_f_value
    F2_5d_5d_f = $F2(5d,5d)_f_value * $F2(5d,5d)_f_scaleFactor
    F4_5d_5d_f = $F4(5d,5d)_f_value * $F4(5d,5d)_f_scaleFactor
    F0_5d_5d_f = U_5d_5d_f + 2 / 63 * F2_5d_5d_f + 2 / 63 * F4_5d_5d_f
    U_3s_5d_f = $U(3s,5d)_f_value
    G2_3s_5d_f = $G2(3s,5d)_f_value * $G2(3s,5d)_f_scaleFactor
    F0_3s_5d_f = U_3s_5d_f + 1 / 10 * G2_3s_5d_f

    H_i = H_i + Chop(
          F0_5d_5d_i * F0_5d_5d
        + F2_5d_5d_i * F2_5d_5d
        + F4_5d_5d_i * F4_5d_5d)

    H_f = H_f + Chop(
          F0_5d_5d_f * F0_5d_5d
        + F2_5d_5d_f * F2_5d_5d
        + F4_5d_5d_f * F4_5d_5d
        + F0_3s_5d_f * F0_3s_5d
        + G2_3s_5d_f * G2_3s_5d)

    ldots_5d = NewOperator("ldots", NFermions, IndexUp_5d, IndexDn_5d)

    zeta_5d_i = $zeta(5d)_i_value * $zeta(5d)_i_scaleFactor

    zeta_5d_f = $zeta(5d)_f_value * $zeta(5d)_f_scaleFactor

    H_i = H_i + Chop(
          zeta_5d_i * ldots_5d)

    H_f = H_f + Chop(
          zeta_5d_f * ldots_5d)
end

--------------------------------------------------------------------------------
-- Define the crystal field term.
--------------------------------------------------------------------------------
if CrystalFieldTerm then
    Akm = {{4, 0, -14}, {4, 3, -2 * math.sqrt(70)}, {4, -3, 2 * math.sqrt(70)}}
    Dq_#m = NewOperator("CF", NFermions, IndexUp_#m, IndexDn_#m, Akm)

    Akm = {{2, 0, -7}}
    Dsigma_#m = NewOperator("CF", NFermions, IndexUp_#m, IndexDn_#m, Akm)

    Akm = {{4, 0, -21}}
    Dtau_#m = NewOperator("CF", NFermions, IndexUp_#m, IndexDn_#m, Akm)


    Dq_5d_i = $10Dq(5d)_i_value / 10.0
    Dsigma_5d_i = $Dsigma(5d)_i_value
    Dtau_5d_i = $Dtau(5d)_i_value

    io.write("Diagonal values of the initial crystal field Hamiltonian:\n")
    io.write("================\n")
    io.write("Irrep.         E\n")
    io.write("================\n")
    io.write(string.format("a1(t2g) %8.3f\n", -4 * Dq_5d_i - 2 * Dsigma_5d_i - 6 * Dtau_5d_i))
    io.write(string.format("e(t2g)  %8.3f\n", -4 * Dq_5d_i + Dsigma_5d_i + 2 / 3 * Dtau_5d_i))
    io.write(string.format("e(eg)   %8.3f\n", 6 * Dq_5d_i + 7 / 3 * Dtau_5d_i))
    io.write("================\n")
    io.write("For the C3v symmetry, the crystal field Hamiltonian is not necessarily diagonal in\n")
    io.write("the basis of the irreducible representations. See the König and Kremer book, page 56.\n")
    io.write(string.format("The non-digonal element <e(t2g)|H|e(eg)> is %.3f.\n", -math.sqrt(2) / 3 * (3 * Dsigma_5d_i - 5 * Dtau_5d_i)))
    io.write("\n")

    Dq_5d_f = $10Dq(5d)_f_value / 10.0
    Dsigma_5d_f = $Dsigma(5d)_f_value
    Dtau_5d_f = $Dtau(5d)_f_value

    H_i = H_i + Chop(
          Dq_5d_i * Dq_5d
        + Dsigma_5d_i * Dsigma_5d
        + Dtau_5d_i * Dtau_5d)

    H_f = H_f + Chop(
          Dq_5d_f * Dq_5d
        + Dsigma_5d_f * Dsigma_5d
        + Dtau_5d_f * Dtau_5d)
end
--------------------------------------------------------------------------------
-- Define the magnetic field and exchange field terms.
--------------------------------------------------------------------------------
Sx_5d = NewOperator("Sx", NFermions, IndexUp_5d, IndexDn_5d)
Sy_5d = NewOperator("Sy", NFermions, IndexUp_5d, IndexDn_5d)
Sz_5d = NewOperator("Sz", NFermions, IndexUp_5d, IndexDn_5d)
Ssqr_5d = NewOperator("Ssqr", NFermions, IndexUp_5d, IndexDn_5d)
Splus_5d = NewOperator("Splus", NFermions, IndexUp_5d, IndexDn_5d)
Smin_5d = NewOperator("Smin", NFermions, IndexUp_5d, IndexDn_5d)

Lx_5d = NewOperator("Lx", NFermions, IndexUp_5d, IndexDn_5d)
Ly_5d = NewOperator("Ly", NFermions, IndexUp_5d, IndexDn_5d)
Lz_5d = NewOperator("Lz", NFermions, IndexUp_5d, IndexDn_5d)
Lsqr_5d = NewOperator("Lsqr", NFermions, IndexUp_5d, IndexDn_5d)
Lplus_5d = NewOperator("Lplus", NFermions, IndexUp_5d, IndexDn_5d)
Lmin_5d = NewOperator("Lmin", NFermions, IndexUp_5d, IndexDn_5d)

Jx_5d = NewOperator("Jx", NFermions, IndexUp_5d, IndexDn_5d)
Jy_5d = NewOperator("Jy", NFermions, IndexUp_5d, IndexDn_5d)
Jz_5d = NewOperator("Jz", NFermions, IndexUp_5d, IndexDn_5d)
Jsqr_5d = NewOperator("Jsqr", NFermions, IndexUp_5d, IndexDn_5d)
Jplus_5d = NewOperator("Jplus", NFermions, IndexUp_5d, IndexDn_5d)
Jmin_5d = NewOperator("Jmin", NFermions, IndexUp_5d, IndexDn_5d)

Tx_5d = NewOperator("Tx", NFermions, IndexUp_5d, IndexDn_5d)
Ty_5d = NewOperator("Ty", NFermions, IndexUp_5d, IndexDn_5d)
Tz_5d = NewOperator("Tz", NFermions, IndexUp_5d, IndexDn_5d)

Sx = Sx_5d
Sy = Sy_5d
Sz = Sz_5d

Lx = Lx_5d
Ly = Ly_5d
Lz = Lz_5d

Jx = Jx_5d
Jy = Jy_5d
Jz = Jz_5d

Tx = Tx_5d
Ty = Ty_5d
Tz = Tz_5d

Ssqr = Sx * Sx + Sy * Sy + Sz * Sz
Lsqr = Lx * Lx + Ly * Ly + Lz * Lz
Jsqr = Jx * Jx + Jy * Jy + Jz * Jz

if MagneticFieldTerm then
    Bx_i = $Bx_i_value * EnergyUnits.Tesla.value
    By_i = $By_i_value * EnergyUnits.Tesla.value
    Bz_i = $Bz_i_value * EnergyUnits.Tesla.value

    Bx_f = $Bx_f_value * EnergyUnits.Tesla.value
    By_f = $By_f_value * EnergyUnits.Tesla.value
    Bz_f = $Bz_f_value * EnergyUnits.Tesla.value

    H_i = H_i + Chop(
          Bx_i * (2 * Sx + Lx)
        + By_i * (2 * Sy + Ly)
        + Bz_i * (2 * Sz + Lz))

    H_f = H_f + Chop(
          Bx_f * (2 * Sx + Lx)
        + By_f * (2 * Sy + Ly)
        + Bz_f * (2 * Sz + Lz))
end

if ExchangeFieldTerm then
    Hx_i = $Hx_i_value
    Hy_i = $Hy_i_value
    Hz_i = $Hz_i_value

    Hx_f = $Hx_f_value
    Hy_f = $Hy_f_value
    Hz_f = $Hz_f_value

    H_i = H_i + Chop(
          Hx_i * Sx
        + Hy_i * Sy
        + Hz_i * Sz)

    H_f = H_f + Chop(
          Hx_f * Sx
        + Hy_f * Sy
        + Hz_f * Sz)
end

--------------------------------------------------------------------------------
-- Define the restrictions and set the number of initial states.
--------------------------------------------------------------------------------
InitialRestrictions = {NFermions, NBosons, {"11 0000000000", NElectrons_3s, NElectrons_3s},
                                           {"00 1111111111", NElectrons_5d, NElectrons_5d}}

FinalRestrictions = {NFermions, NBosons, {"11 0000000000", NElectrons_3s - 1, NElectrons_3s - 1},
                                         {"00 1111111111", NElectrons_5d + 1, NElectrons_5d + 1}}

CalculationRestrictions = nil

--------------------------------------------------------------------------------
-- Define some helper functions.
--------------------------------------------------------------------------------
function MatrixToOperator(Matrix, StartIndex)
    -- Transform a matrix to an operator.
    local Operator = 0
    for i = 1, #Matrix do
        for j = 1, #Matrix do
            local Weight = Matrix[i][j]
            Operator = Operator + NewOperator("Number", #Matrix + StartIndex, i + StartIndex - 1, j + StartIndex - 1) * Weight
        end
    end
    Operator.Chop()
    return Operator
end

function ValueInTable(Value, Table)
    -- Check if a value is in a table.
    for _, v in ipairs(Table) do
        if Value == v then
            return true
        end
    end
    return false
end

function GetSpectrum(G, Ids, dZ, NOperators, NPsis)
    -- Extract the spectrum corresponding to the operators identified
    -- using the Ids argument. The returned spectrum is a weighted
    -- sum where the weights are the Boltzmann probabilities.
    --
    -- @param G: spectrum object as returned by the functions defined in Quanty, i.e. one spectrum
    --           for each operator and each wavefunction.
    -- @param Ids: indexes of the operators that are considered in the returned spectrum
    -- @param dZ: Boltzmann prefactors for each of the spectrum in the spectra object
    -- @param NOperators: number of transition operators
    -- @param NPsis: number of wavefunctions

    if not (type(Ids) == "table") then
        Ids = {Ids}
    end

    local Id = 1
    local dZs = {}

    for i = 1, NOperators do
        for _ = 1, NPsis do
            if ValueInTable(i, Ids) then
                table.insert(dZs, dZ[Id])
            else
                table.insert(dZs, 0)
            end
            Id = Id + 1
        end
    end
    return Spectra.Sum(G, dZs)
end

function SaveSpectrum(G, Filename, Gaussian, Lorentzian, Pcl)
    if Pcl == nil then
        Pcl = 1
    end
    G = -1 / math.pi / Pcl * G
    G.Broaden(Gaussian, Lorentzian)
    G.Print({{"file", Filename .. ".spec"}})
end

function CalculateT(Basis, Eps, K)
    -- Calculate the transition operator in the basis of tesseral harmonics for
    -- an arbitrary polarization and wave-vector (for quadrupole operators).
    --
    -- @param: Basis: operators forming the basis
    -- @param: Eps: cartesian components of the polarization vector
    -- @param: K: cartesian components of the wave-vector

    if #Basis == 3 then
        -- The basis for dipolar operators is in the order x, y, z.
        T = Eps[1] * Basis[1]
          + Eps[2] * Basis[2]
          + Eps[3] * Basis[3]
    elseif #Basis == 5 then 
        -- The basis for quadrupolar operators is in the order xy, xz, yz, x2y2, z2.
        T = (Eps[1] * K[2] + Eps[2] * K[1]) / math.sqrt(3) * Basis[1] 
          + (Eps[1] * K[3] + Eps[3] * K[1]) / math.sqrt(3) * Basis[2] 
          + (Eps[2] * K[3] + Eps[3] * K[2]) / math.sqrt(3) * Basis[3] 
          + (Eps[1] * K[1] - Eps[2] * K[2]) / math.sqrt(3) * Basis[4] 
          + Eps[3] * K[3] * Basis[5]
    end
    return Chop(T)
end

function DotProduct(a, b)
    return Chop(a[1] * b[1] + a[2] * b[2] + a[3] * b[3])
end

function WavefunctionsAndBoltzmannFactors(H, NPsis, NPsisAuto, Temperature, Threshold, StartRestrictions, CalculationRestrictions)
    -- Calculate the wavefunctions and Boltzmann factors of a Hamiltonian.
    --
    -- @param H: Hamiltonian for which to calculate the wavefunctions
    -- @param NPsis: number of wavefunctions
    -- @param NPsisAuto: determine automatically the number of wavefunctions that are populated at the specified
    --                   temperature and within the threshold
    -- @param Temperature: temperature in eV
    -- @param Threshold: threshold used to determine the number of wavefunction in the automatic procedure
    -- @param StartRestrictions: occupancy restrictions at the start of the calculation
    -- @param CalculationRestrictions: restrictions during the calculation
    -- @return Psis: wavefunctions
    -- @return dZ: Boltzmann factors

    if Threshold == nil then
        Threshold = 1e-8
    end

    local dZ = {}
    local Z = 0
    local Psis

    if NPsisAuto == true and NPsis ~= 1 then
        NPsis = 4
        local NpsisIncrement = 8
        local NPsisIsConverged = false

        while not NPsisIsConverged do
            if CalculationRestrictions == nil then
                Psis = Eigensystem(H, StartRestrictions, NPsis)
            else
                Psis = Eigensystem(H, StartRestrictions, NPsis, {{"restrictions", CalculationRestrictions}})
            end

            if not (type(Psis) == "table") then
                Psis = {Psis}
            end

            if E_gs == nil then
                E_gs = Psis[1] * H * Psis[1]
            end

            Z = 0

            for i, Psi in ipairs(Psis) do
                local E = Psi * H * Psi

                if math.abs(E - E_gs) < Threshold ^ 2 then
                    dZ[i] = 1
                else
                    dZ[i] = math.exp(-(E - E_gs) / Temperature)
                end

                Z = Z + dZ[i]

                if dZ[i] / Z < Threshold then
                    i = i - 1
                    NPsisIsConverged = true
                    NPsis = i
                    Psis = {unpack(Psis, 1, i)}
                    dZ = {unpack(dZ, 1, i)}
                    break
                end
            end

            if NPsisIsConverged then
                break
            else
                NPsis = NPsis + NpsisIncrement
            end
        end
    else
        if CalculationRestrictions == nil then
            Psis = Eigensystem(H, StartRestrictions, NPsis)
        else
            Psis = Eigensystem(H, StartRestrictions, NPsis, {{"restrictions", CalculationRestrictions}})
        end

        if not (type(Psis) == "table") then
            Psis = {Psis}
        end

        local E_gs = Psis[1] * H * Psis[1]

        Z = 0

        for i, psi in ipairs(Psis) do
            local E = psi * H * psi

            if math.abs(E - E_gs) < Threshold ^ 2 then
                dZ[i] = 1
            else
                dZ[i] = math.exp(-(E - E_gs) / Temperature)
            end

            Z = Z + dZ[i]
        end
    end

    -- Normalize the Boltzmann factors to unity.
    for i in ipairs(dZ) do
        dZ[i] = dZ[i] / Z
    end

    return Psis, dZ
end

function PrintHamiltonianAnalysis(Psis, Operators, dZ, Header, Footer)
    io.write(Header)
    for i, Psi in ipairs(Psis) do
        io.write(string.format("%5d", i))
        for j, operator in ipairs(Operators) do
            if j == 1 then
                io.write(string.format("%12.6f", Complex.Re(Psi * operator * Psi)))
            elseif operator == "dZ" then
                io.write(string.format("%12.2e", dZ[i]))
            else
                io.write(string.format("%10.4f", Complex.Re(Psi * operator * Psi)))
            end
        end
        io.write("\n")
    end
    io.write(Footer)
end

--------------------------------------------------------------------------------
-- Analyze the initial Hamiltonian.
--------------------------------------------------------------------------------
Temperature = Temperature * EnergyUnits.Kelvin.value

Sk = DotProduct(WaveVector, {Sx, Sy, Sz})
Lk = DotProduct(WaveVector, {Lx, Ly, Lz})
Jk = DotProduct(WaveVector, {Jx, Jy, Jz})
Tk = DotProduct(WaveVector, {Tx, Ty, Tz})

Operators = {H_i, Ssqr, Lsqr, Jsqr, Sk, Lk, Jk, Tk, ldots_5d, N_3s, N_5d, "dZ"}
Header = "Analysis of the %s Hamiltonian:\n"
Header = Header .. "=================================================================================================================================\n"
Header = Header .. "State           E     <S^2>     <L^2>     <J^2>      <Sk>      <Lk>      <Jk>      <Tk>     <l.s>    <N_3s>    <N_5d>          dZ\n"
Header = Header .. "=================================================================================================================================\n"
Footer = "=================================================================================================================================\n\n"

local Psis_i, dZ_i = WavefunctionsAndBoltzmannFactors(H_i, NPsis, NPsisAuto, Temperature, nil, InitialRestrictions, CalculationRestrictions)
PrintHamiltonianAnalysis(Psis_i, Operators, dZ_i, string.format(Header, "initial"), Footer)

-- Stop the calculation if no spectra need to be calculated.
if next(SpectraToCalculate) == nil then
    return
end

--------------------------------------------------------------------------------
-- Calculate and save the spectra.
--------------------------------------------------------------------------------
local t = math.sqrt(1 / 2)

Txy_3s_5d   = NewOperator("CF", NFermions, IndexUp_5d, IndexDn_5d, IndexUp_3s, IndexDn_3s, {{2, -2, t * I}, {2, 2, -t * I}})
Txz_3s_5d   = NewOperator("CF", NFermions, IndexUp_5d, IndexDn_5d, IndexUp_3s, IndexDn_3s, {{2, -1, t    }, {2, 1, -t    }})
Tyz_3s_5d   = NewOperator("CF", NFermions, IndexUp_5d, IndexDn_5d, IndexUp_3s, IndexDn_3s, {{2, -1, t * I}, {2, 1,  t * I}})
Tx2y2_3s_5d = NewOperator("CF", NFermions, IndexUp_5d, IndexDn_5d, IndexUp_3s, IndexDn_3s, {{2, -2, t    }, {2, 2,  t    }})
Tz2_3s_5d   = NewOperator("CF", NFermions, IndexUp_5d, IndexDn_5d, IndexUp_3s, IndexDn_3s, {{2,  0, 1    }                })

Er = {t * (Eh[1] - I * Ev[1]),
      t * (Eh[2] - I * Ev[2]),
      t * (Eh[3] - I * Ev[3])}

El = {-t * (Eh[1] + I * Ev[1]),
      -t * (Eh[2] + I * Ev[2]),
      -t * (Eh[3] + I * Ev[3])}

local T = {Txy_3s_5d, Txz_3s_5d, Tyz_3s_5d, Tx2y2_3s_5d, Tz2_3s_5d}
Tv_3s_5d = CalculateT(T, Ev, WaveVector)
Th_3s_5d = CalculateT(T, Eh, WaveVector)
Tr_3s_5d = CalculateT(T, Er, WaveVector)
Tl_3s_5d = CalculateT(T, El, WaveVector)
Tk_3s_5d = CalculateT(T, WaveVector, WaveVector)

-- Initialize a table with the available spectra and the required operators.
SpectraAndOperators = {
    ["Isotropic Absorption"] = {Txy_3s_5d, Txz_3s_5d, Tyz_3s_5d, Tx2y2_3s_5d, Tz2_3s_5d},
    ["Absorption"] = {Tk_3s_5d,},
    ["Circular Dichroic"] = {Tr_3s_5d, Tl_3s_5d},
    ["Linear Dichroic"] = {Tv_3s_5d, Th_3s_5d},
}

-- Create an unordered set with the required operators.
local T_3s_5d = {}
for Spectrum, Operators in pairs(SpectraAndOperators) do
    if ValueInTable(Spectrum, SpectraToCalculate) then
        for _, Operator in pairs(Operators) do
            T_3s_5d[Operator] = true
        end
    end
end

-- Give the operators table the form required by Quanty's functions.
local T = {}
for Operator, _ in pairs(T_3s_5d) do
    table.insert(T, Operator)
end
T_3s_5d = T

Emin = Emin - (ZeroShift + ExperimentalShift)
Emax = Emax - (ZeroShift + ExperimentalShift)

if CalculationRestrictions == nil then
    G_3s_5d = CreateSpectra(H_f, T_3s_5d, Psis_i, {{"Emin", Emin}, {"Emax", Emax}, {"NE", NPoints}, {"Gamma", Gamma}, {"DenseBorder", DenseBorder}})
else
    G_3s_5d = CreateSpectra(H_f, T_3s_5d, Psis_i, {{"Emin", Emin}, {"Emax", Emax}, {"NE", NPoints}, {"Gamma", Gamma}, {"Restrictions", CalculationRestrictions}, {"DenseBorder", DenseBorder}})
end

-- Shift the calculated spectra.
G_3s_5d.Shift(ZeroShift + ExperimentalShift)

-- Create a list with the Boltzmann probabilities for a given operator and wavefunction.
local dZ_3s_5d = {}
for _ in ipairs(T_3s_5d) do
    for j in ipairs(Psis_i) do
        table.insert(dZ_3s_5d, dZ_i[j])
    end
end

local Ids = {}
for k, v in pairs(T_3s_5d) do
    Ids[v] = k
end

-- Subtract the broadening used in the spectra calculations from the Lorentzian table.
for i, _ in ipairs(Lorentzian) do
    -- The FWHM is the second value in each pair.
    Lorentzian[i][2] = Lorentzian[i][2] - Gamma
end

Pcl_3s_5d = 1

for Spectrum, Operators in pairs(SpectraAndOperators) do
    if ValueInTable(Spectrum, SpectraToCalculate) then
        -- Find the indices of the spectrum's operators in the table used during the
        -- calculation (this is unsorted).
        SpectrumIds = {}
        for _, Operator in pairs(Operators) do
            table.insert(SpectrumIds, Ids[Operator])
        end

        if Spectrum == "Isotropic Absorption" then
            Giso = GetSpectrum(G_3s_5d, SpectrumIds, dZ_3s_5d, #T_3s_5d, #Psis_i)
            Giso = Giso / 15 
            SaveSpectrum(Giso, Prefix .. "_iso", Gaussian, Lorentzian, Pcl_3s_5d)
        end

        if Spectrum == "Absorption" then
            Gk = GetSpectrum(G_3s_5d, SpectrumIds, dZ_3s_5d, #T_3s_5d, #Psis_i)
            SaveSpectrum(Gk, Prefix .. "_k", Gaussian, Lorentzian, Pcl_3s_5d)
        end

        if Spectrum == "Circular Dichroic" then
            Gr = GetSpectrum(G_3s_5d, SpectrumIds[1], dZ_3s_5d, #T_3s_5d, #Psis_i)
            Gl = GetSpectrum(G_3s_5d, SpectrumIds[2], dZ_3s_5d, #T_3s_5d, #Psis_i)
            SaveSpectrum(Gr, Prefix .. "_r", Gaussian, Lorentzian, Pcl_3s_5d)
            SaveSpectrum(Gl, Prefix .. "_l", Gaussian, Lorentzian, Pcl_3s_5d)
            SaveSpectrum(Gr - Gl, Prefix .. "_cd", Gaussian, Lorentzian)
        end

        if Spectrum == "Linear Dichroic" then
            Gv = GetSpectrum(G_3s_5d, SpectrumIds[1], dZ_3s_5d, #T_3s_5d, #Psis_i)
            Gh = GetSpectrum(G_3s_5d, SpectrumIds[2], dZ_3s_5d, #T_3s_5d, #Psis_i)
            SaveSpectrum(Gv, Prefix .. "_v", Gaussian, Lorentzian, Pcl_3s_5d)
            SaveSpectrum(Gh, Prefix .. "_h", Gaussian, Lorentzian, Pcl_3s_5d)
            SaveSpectrum(Gv - Gh, Prefix .. "_ld", Gaussian, Lorentzian)
        end
    end
end

