module LocalImport_Sandbox
    using Test

    module ImportModule
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

        @localimport SubordinateModule
        @localimport SubordinateModule.InnerModule
        @localimport SubordinateModule one_
        @localimport SubordinateModule two_ three_
        @localimport SubordinateModule.InnerModule four_

    end

    @testset "@localimport" begin
        @test ImportModule.SubordinateModule.zero_ == 0
        @test ImportModule.InnerModule.four_ == 4

        @test_throws UndefVarError ImportModule.zero_
        @test ImportModule.one_ == 1
        @test ImportModule.two_ == 2
        @test ImportModule.three_ == 3
        @test ImportModule.four_ == 4
    end
end