using MFF
using Dates
using DataFrames
using Test

@testset "MFF.jl" begin

  startdt = "2020-01-10"
  enddt = "2020-01-15"
  @testset "DataFrame Output" begin

    @testset "Single Stock" begin
      data = get_data(
        Val(:df),
        "AAPL",
        startdt,
        enddt
      )

      @test data isa DataFrame
      @test size(data, 2) == 2
      @test names(data) == ["date", "AAPL"]
      @test all(Date(startdt).≤data.date.≤Date(enddt))
      @test size(data, 1)≤(Date(enddt)-Date(startdt)).value

      data = get_data(
        Val(:df),
        "asdasd",
        startdt,
        enddt
      )

      @test data isa Nothing
    end

    @testset "Multiple Stocks" begin
      data = get_data!(
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

      data = get_data!(
        Val(:df),
        ["ghjgh", "ghjehrf"],
        startdt,
        enddt,
        prprty="high"
      )

      @test data isa Nothing

      assets = ["ghjgh", "MSFT"]
      data = get_data!(
        Val(:df),
        assets,
        startdt,
        enddt,
        prprty="high"
      )

      @test data isa DataFrame
      @test size(data, 2) == 2
      @test names(data) == ["date", "MSFT"]
      @test all(Date(startdt).≤data.date.≤Date(enddt))
      @test size(data, 1)≤(Date(enddt)-Date(startdt)).value
      @test assets == ["MSFT"]

      assets = ["MSFT", "ghjgh"]
      data = get_data!(
        Val(:df),
        assets,
        startdt,
        enddt,
        prprty="high"
      )

      @test data isa DataFrame
      @test size(data, 2) == 2
      @test names(data) == ["date", "MSFT"]
      @test all(Date(startdt).≤data.date.≤Date(enddt))
      @test size(data, 1)≤(Date(enddt)-Date(startdt)).value
      @test assets == ["MSFT"]

      assets = ["MSFT", "ghjgh", "AAPL"]
      data = get_data!(
        Val(:df),
        assets,
        startdt,
        enddt,
        prprty="high"
      )

      @test data isa DataFrame
      @test size(data, 2) == 3
      @test names(data) == ["date", "MSFT", "AAPL"]
      @test all(Date(startdt).≤data.date.≤Date(enddt))
      @test size(data, 1)≤(Date(enddt)-Date(startdt)).value
      @test assets == ["MSFT", "AAPL"]
    end
  end

  @testset "Matrix Output" begin
    data = get_data!(
      Val(:vec),
      ["AAPL", "MSFT"],
      startdt,
      enddt,
      prprty="high"
    )

    @test data isa Matrix{<:AbstractFloat}
    @test size(data, 2) == 2
    @test size(data, 1)≤(Date(enddt)-Date(startdt)).value

    data = get_data!(
      Val(:vec),
      ["safrd", "sdryherh"],
      startdt,
      enddt,
      prprty="high"
    )

    @test data isa Nothing

    assets = ["aasf", "MSFT"]
    data = get_data!(
      Val(:vec),
      assets,
      startdt,
      enddt,
      prprty="high"
    )

    @test data isa Matrix{<:AbstractFloat}
    @test size(data, 2) == 1
    @test size(data, 1)≤(Date(enddt)-Date(startdt)).value
    @test assets == ["MSFT"]

    assets = ["MSFT", "aasf"]
    data = get_data!(
      Val(:vec),
      assets,
      startdt,
      enddt,
      prprty="high"
    )

    @test data isa Matrix{<:AbstractFloat}
    @test size(data, 2) == 1
    @test size(data, 1)≤(Date(enddt)-Date(startdt)).value
    @test assets == ["MSFT"]

    assets = ["MSFT", "aasf", "AAPL"]
    data = get_data!(
      Val(:vec),
      assets,
      startdt,
      enddt,
      prprty="high"
    )

    @test data isa Matrix{<:AbstractFloat}
    @test size(data, 2) == 2
    @test size(data, 1)≤(Date(enddt)-Date(startdt)).value
    @test assets == ["MSFT", "AAPL"]

    @test_logs (:warn, r"The following assets have inconsistent data length: \[\"688041.SS\", \"688047.SS\"\]") get_data!(Val(:vec), ["688041.SS", "688047.SS", "688008.SS", "688009.SS"], "2022-04-01", "2024-12-25", prprty="vol")
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

    data = get_data(
      Val(:vec),
      "asdas",
      startdt,
      enddt,
      prprty="high"
    )

    @test data isa Nothing
  end

  @testset "Wrong prprty" begin
    @test_throws ArgumentError get_data(
      Val(:vec),
      "AAPL",
      startdt,
      enddt,
      prprty="wrong"
    )

    @test_throws ArgumentError get_data!(
      Val(:vec),
      ["AAPL", "MSFT"],
      startdt,
      enddt,
      prprty="wrong"
    )

    @test_throws ArgumentError get_data(
      Val(:df),
      "AAPL",
      startdt,
      enddt,
      prprty="wrong"
    )

    @test_throws ArgumentError get_data!(
      Val(:df),
      ["AAPL", "MSFT"],
      startdt,
      enddt,
      prprty="wrong"
    )
  end

  @testset "Wrong stratdt & enddt" begin
    @test_throws ArgumentError get_data(
      Val(:vec),
      "AAPL",
      "2020-01-15",
      "2020-01-10"
    )

    @test_throws ArgumentError get_data!(
      Val(:vec),
      ["AAPL", "MSFT"],
      "2020-01-15",
      "2020-01-10"
    )

    @test_throws ArgumentError get_data(
      Val(:df),
      "AAPL",
      "2020-01-15",
      "2020-01-10"
    )

    @test_throws ArgumentError get_data!(
      Val(:df),
      ["AAPL", "MSFT"],
      "2020-01-15",
      "2020-01-10"
    )
  end

  @testset "property check" begin
    @test_throws ArgumentError get_data(
      Val(:vec),
      "AAPL",
      startdt,
      enddt,
      prprty="wrong"
    )

    @test_throws ArgumentError get_data!(
      Val(:vec),
      ["AAPL", "MSFT"],
      startdt,
      enddt,
      prprty="wrong"
    )
  end
  @testset "Wrong path in `gs`" begin
  using CSV
    @test_throws ArgumentError gs(
      ["AAPL"],
      startdt,
      enddt,
      "What's up"
    )
  end

  @testset "Utils.jl" begin
    b = [
        [1,2,1,2],
        [2,4,5],
        [2,2,3,4],
        [1,2]
    ]

    @test MFF.checklen!(b) == BitVector((false, true, false, true))
    @test b == [[1,2,1,2], [2,2,3,4]]

  end
  @testset "Other Exceptions" begin
    startdt = "2022-04-01"
    enddt = "2024-12-25"
    @test_throws MFF.InconsistencyError get_data!(
      Val(:vec),
      ["688041.SS", "688047.SS"],
      startdt,
      enddt,
      prprty = "vol"
    )
  end
end
