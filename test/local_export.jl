module Local_Export_Sandbox
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

        @local_ export SubordinateModule
        @local_ export SubordinateModule: one_
        @local_ export SubordinateModule: two_, three_

    end

    using .ExportModule

    @testset "@local_ export" begin
        @test SubordinateModule.zero_ == 0
        @test_throws UndefVarError InnerModule

        @test_throws UndefVarError zero_
        @test one_ == 1
        @test two_ == 2
        @test three_ == 3
        @test_throws UndefVarError four_
    end
end