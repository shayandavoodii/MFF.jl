using MFF
using Dates
using DataFrames
using Test
using CSV
push!(LOAD_PATH,"../src/")

@testset "MFF.jl" begin

  @testset "DataFrame Output" begin

    @testset "Single Stock" begin
      data = get_data(
        Val(:df),
        "AAPL",
        "2020-01-10",
        "2020-01-15",
        fixdt=false
      )

      expected = DataFrame(
        date = Date.(["2020-01-10", "2020-01-13", "2020-01-14"]),
        AAPL = [75.89, 77.5113, 76.4646]
      )

      result = isapprox.(
        @view(data[!, 2:end]), @view(expected[!, 2:end]), atol=1e-3
      )

      @test all(all.(==(true), eachcol(result)))
    end

    @testset "Multiple Stocks" begin
      data = get_data(
        Val(:df),
        ["AAPL", "MSFT"],
        "2020-01-10",
        "2020-01-15",
        prprty="high"
      )

      expected = DataFrame(
        date = Date.(["2020-01-10", "2020-01-11", "2020-01-12"]),
        AAPL = [76.4622, 77.5382, 77.6605],
        MSFT = [158.283, 158.37, 158.652]
      )

      result = isapprox.(
        @view(data[!, 2:end]), @view(expected[!, 2:end]), atol=1e-3
      )

      @test all(all.(==(true), eachcol(result)))
    end
  end

  @testset "Matrix Output" begin
    data = get_data(
      Val(:vec),
      ["AAPL", "MSFT"],
      "2020-01-10",
      "2020-01-15",
      prprty="high"
    )

    @test isapprox(data, [76.4622 158.283; 77.5382 158.37; 77.6605 158.652], atol=1e-3)
  end

  @testset "Vector Output" begin
    data = get_data(
      Val(:vec),
      "AAPL",
      "2020-01-10",
      "2020-01-15",
      prprty="high"
    )

    @test isapprox(data, [76.4622; 77.5382; 77.6605], atol=1e-3)
  end

  @testset "Wrong prprty" begin
    @test_throws ErrorException get_data(
      Val(:vec),
      "AAPL",
      "2020-01-10",
      "2020-01-15",
      prprty="wrong"
    )
  end

  @testset "Wrong path in `gs`" begin
    @test_throws ArgumentError gs(
      ["AAPL"],
      "2020-01-10",
      "2020-01-15",
      "What's up"
    )
  end
end
