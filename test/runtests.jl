using LocalCustoms
using Test

@testset "LocalCustoms.jl" begin
    include("local_import.jl")  # TESTS `@local_ import`
    include("local_export.jl")  # TESTS `@local_ export`
    include("localimport.jl")   # TESTS `@localimport`
    include("localexport.jl")   # TESTS `@localexport`
end
