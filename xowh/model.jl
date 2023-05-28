using SpecialFunctions
using Plots
using Printf
using Roots

# units: N: cm-3, x: g

# Universal mass function
# A[1] = A, A[2] = ν, A[3] = B
f(A, x) = @. A[1] * x^A[2] * exp(-A[3] * x)

Nc(A, ν, B) = A * gamma(ν + 1.0) / B^(ν + 1.0)
Ap(Nc, ν, B) = Nc / (gamma(ν + 1.0) / B^(ν + 1.0))

Dμm_to_xg(D) = π / 6.0 * (D * 1e-6)^3.0 * 1000.0 * 1000.0
xg_to_Dμm(x) = (x / 1e6 * 6.0 / pi)^(1.0 / 3.0) * 1e6
Dμm_to_xg(4000)
xg_to_Dμm(0.03335)

Des = exp10.(range(log10(0.5), stop=log10(500), length=1000))
Des = 0:0.1:100

xes = map(Dμm_to_xg, Des)
Ds = sqrt.(Des[2:end] .* Des[1:end-1])
xs = sqrt.(xes[2:end] .* xes[1:end-1])

dxs = xes[2:end] .- xes[1:end-1]
dDs = Des[2:end] .- Des[1:end-1]

mNc = 1.0
CV  = 0.07
mDg = 10.0

ν = 0.112 ./ CV.^2.0 .- 1.0

# function find_mode(ν, B)
#     A = [Ap(mNc, ν, B), ν, B]
#     mX = f(A, xs)
#     mD = mX .* dxs ./ dDs
#     pdf = mD .* dDs ./ mNc
#     modeD, i = findmax(pdf./ dDs)
#     return Ds[i]
# end

rootf(B) = xg_to_Dμm((ν + 1) ./ B) - mDg

B = find_zero(rootf, (1000, 1e20), rtol=1eps())

# function getCV(ν, B)
#     A = [Ap(mNc, ν, B), ν, B]
#     mX = f(A, xs)

#     mD = mX .* dxs ./ dDs

#     pdf = mD .* dDs ./ mNc
#     meanDiameter = xg_to_Dμm(sum(xs .* mX .* dxs))
#     stdDiameter = sqrt.(sum((Ds .- meanDiameter) .^ 2.0 .* mX .* dxs))
  
#     return stdDiameter / meanDiameter
# end

# B = 1e7
# νs = 0:1:100
# CV1 = map(ν -> getCV(ν, B), νs)
# CV2 = map(ν -> getCV(ν, B*10), νs)
# CV3 = map(ν -> getCV(ν, B/10), νs)
# plot(mCV, 0.112 ./ mCV.^2.0 .- 1.0)
# scatter!(CV1, νs, ylim = [-0.1,100], xlim = [0, 0.5])
# scatter!(CV2, νs)
# scatter!(CV3, νs)
# mCV = 0.05:0.01:10


A = [Ap(mNc, ν, B), ν, B]
mX = f(A, xs)
mD = mX .* dxs ./ dDs
pdf = mD .* dDs ./ mNc
modeD, i = findmax(pdf./ dDs)

meanDiameter = xg_to_Dμm(sum(xs .* mX .* dxs))
stdDiameter = sqrt.(sum((Ds .- meanDiameter) .^ 2.0 .* mX .* dxs))


println(Nc(A[1], A[2], A[3]))
modeD, i = findmax(pdf./ dDs)

analyticMode = xg_to_Dμm((ν ) ./ B)
Ds[i]

analyticMean = xg_to_Dμm((ν + 1) ./ B)
# meanDiameter 

# analyticStd = xg_to_Dμm(sqrt.((ν + 1) ./ B^2.0))
# stdDiameter

# analyticCV =  1.0/(sqrt.(1 + ν))

mNc = 100.0
tstr = @sprintf("Nₜ = %.1f cm⁻³, σ/μ = %.2f", mNc, stdDiameter / meanDiameter)
lstr1 = @sprintf("meanD = %.2f μm", meanDiameter)
lstr1a = @sprintf("modeD = %.2f μm", Ds[1])
lstr2 = @sprintf("sD = ±%.2f μm", stdDiameter)
plot(Ds, mNc*pdf ./ dDs, xlim=[0, 40], label="pdf", ylabel="n(D) (cm⁻³ μm⁻¹)", title=tstr, minorgrid=:true, color=:black, framestyle=:box)
modeD = maximum(mNc*pdf ./ dDs)
plot!([meanDiameter, meanDiameter], [0, modeD], xlabel="D (μm)", label=lstr1)
plot!([Ds[i], Ds[i]], [0, modeD], xlabel="D (μm)", label=lstr1a)
plot!([Ds[i] - stdDiameter, Ds[i] + stdDiameter], [modeD / 1.6, modeD / 1.6], xlabel="D (μm)", label=lstr2)


# f(A, x) = @. (A[2]^A[1])/gamma(A[1]) * x^(A[1] - 1.0) * exp(-A[2] * x)

# α = 2.0
# β = 2000000.0
# asd = f([α, β], xs)
# sum(asd.*dxs)

# analyticMode = (α-1.0)/β
# y,i = findmax(asd)
# myMode = xs[i]

# analyticMean = α/β
# mymean = sum(xs .* asd .*dxs)
# analyticStd = sqrt.(α/β^2.0)
# mystr = sqrt.(sum((xs.-analyticMean).^2.0 .* asd .*dxs))

# plot(asd)
