module LocalExport_Sandbox
    using Test

    module ExportModule
        using LocalCustoms

        module SubordinateModule
            const zero_ = 0
            const one_ = 1
            const two_ = 2
            const three_ = 3

            module InnerModule
                const four_ = 4
            end
        end

        @localexport SubordinateModule
        @localexport SubordinateModule.InnerModule
        @localexport SubordinateModule one_
        @localexport SubordinateModule two_ three_
        @localexport SubordinateModule.InnerModule four_

    end

    using .ExportModule

    @testset "@localexport" begin
        @test SubordinateModule.zero_ == 0
        @test InnerModule.four_ == 4

        @test_throws UndefVarError zero_
        @test one_ == 1
        @test two_ == 2
        @test three_ == 3
        @test four_ == 4
    end
end