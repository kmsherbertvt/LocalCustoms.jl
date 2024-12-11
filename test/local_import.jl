module Local_Import_Sandbox
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

        @local_ import SubordinateModule
        @local_ import SubordinateModule.InnerModule
        @local_ import SubordinateModule: one_
        @local_ import SubordinateModule: two_, three_
        @local_ import SubordinateModule.InnerModule: four_

    end

    @testset "@local_ import" begin
        @test ImportModule.SubordinateModule.zero_ == 0
        @test ImportModule.InnerModule.four_ == 4

        @test_throws UndefVarError ImportModule.zero_
        @test ImportModule.one_ == 1
        @test ImportModule.two_ == 2
        @test ImportModule.three_ == 3
        @test ImportModule.four_ == 4
    end
end