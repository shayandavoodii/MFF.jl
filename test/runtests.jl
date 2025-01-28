using MFF
using Dates
using DataFrames
using Test
using CSV

@testset "MFF.jl" begin

  startdt = "2020-01-10"
  enddt = "2020-01-15"
  @testset "DataFrame Output" begin

    @testset "Single Stock" begin
      data = get_data(
        Val(:df),
        "AAPL",
        startdt,
        enddt,
        fixdt=false
      )

      @test data isa DataFrame
      @test size(data, 2) == 2
      @test names(data) == ["date", "AAPL"]
      @test all(Date(startdt).≤data.date.≤Date(enddt))
      @test size(data, 1)≤(Date(enddt)-Date(startdt)).value
    end

    @testset "Multiple Stocks" begin
      data = get_data(
        Val(:df),
        ["AAPL", "MSFT"],
        startdt,
        enddt,
        prprty="high"
      )

      @test data isa DataFrame
      @test size(data, 2) == 3
      @test names(data) == ["date", "AAPL", "MSFT"]
      @test all(Date(startdt).≤data.date.≤Date(enddt))
      @test size(data, 1)≤(Date(enddt)-Date(startdt)).value
    end
  end

  @testset "Matrix Output" begin
    data = get_data(
      Val(:vec),
      ["AAPL", "MSFT"],
      startdt,
      enddt,
      prprty="high"
    )

    @test data isa Matrix{<:AbstractFloat}
    @test size(data, 2) == 2
    @test size(data, 1)≤(Date(enddt)-Date(startdt)).value
  end

  @testset "Vector Output" begin
    data = get_data(
      Val(:vec),
      "AAPL",
      startdt,
      enddt,
      prprty="high"
    )

    @test data isa AbstractVector{<:AbstractFloat}
    @test length(data)≤(Date(enddt)-Date(startdt)).value
  end

  @testset "Wrong prprty" begin
    @test_throws ErrorException get_data(
      Val(:vec),
      "AAPL",
      startdt,
      enddt,
      prprty="wrong"
    )
  end

  @testset "Wrong path in `gs`" begin
    @test_throws ArgumentError gs(
      ["AAPL"],
      startdt,
      enddt,
      "What's up"
    )
  end
end
