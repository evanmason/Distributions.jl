## Canonical Form of Normal distribution

immutable NormalCanon <: ContinuousUnivariateDistribution
    η::Float64       # σ^(-2) * μ
    λ::Float64    # σ^(-2)
    μ::Float64       # μ

    function NormalCanon(η::Real, λ::Real)
        @check_args(NormalCanon, λ > zero(λ))
    	new(η, λ, η / λ)
    end
    NormalCanon() = new(0.0, 1.0, 0.0)
end

@distr_support NormalCanon -Inf Inf


## conversion between Normal and NormalCanon

Base.convert(::Type{Normal}, d::NormalCanon) = Normal(d.μ, 1.0 / sqrt(d.λ))
Base.convert(::Type{NormalCanon}, d::Normal) = (λ = 1.0 / σ^2; NormalCanon(λ * d.μ, λ))
canonform(d::Normal) = convert(NormalCanon, d)


#### Parameters

params(d::NormalCanon) = (d.η, d.λ)


#### Statistics

mean(d::NormalCanon) = d.μ
median(d::NormalCanon) = mean(d)
mode(d::NormalCanon) = mean(d)

skewness(d::NormalCanon) = 0.0
kurtosis(d::NormalCanon) = 0.0

var(d::NormalCanon) = 1.0 / d.λ
std(d::NormalCanon) = sqrt(var(d))

entropy(d::NormalCanon) = 0.5 * (log2π + 1.0 - log(d.λ))


#### Evaluation

pdf(d::NormalCanon, x::Float64) = (sqrt(d.λ) / sqrt2π) * exp(-0.5 * d.λ * abs2(x - d.μ))
logpdf(d::NormalCanon, x::Float64) = 0.5 * (log(d.λ) - log2π - d.λ * abs2(x - d.μ))

zval(d::NormalCanon, x::Float64) = (x - d.μ) * sqrt(d.λ)
xval(d::NormalCanon, z::Float64) = d.μ + z / sqrt(d.λ)

cdf(d::NormalCanon, x::Float64) = normcdf(zval(d,x))
ccdf(d::NormalCanon, x::Float64) = normccdf(zval(d,x))
logcdf(d::NormalCanon, x::Float64) = normlogcdf(zval(d,x))
logccdf(d::NormalCanon, x::Float64) = normlogccdf(zval(d,x))

quantile(d::NormalCanon, p::Float64) = xval(d, norminvcdf(p))
cquantile(d::NormalCanon, p::Float64) = xval(d, norminvccdf(p))
invlogcdf(d::NormalCanon, lp::Float64) = xval(d, norminvlogcdf(lp))
invlogccdf(d::NormalCanon, lp::Float64) = xval(d, norminvlogccdf(lp))


#### Sampling

rand(cf::NormalCanon) = cf.μ + randn() / sqrt(cf.λ)
rand!{T<:Real}(cf::NormalCanon, r::AbstractArray{T}) = rand!(convert(Normal, cf), r)
