include("../examples/2D\ Cauchy\ Distribution.jl")
include("../examples/Airy\ equation.jl")
if @try_import(RandomMatrices) && @try_import(PyPlot)
    include("../examples/GUE\ Sampling.jl")
end
include("../examples/Lanczos.jl")
include("../examples/Lee\ &\ Greengard\ equation.jl")
include("../examples/Newton iteration for Nonlinear BVPs.jl")
