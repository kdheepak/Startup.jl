module Clap

struct Args
  items::Vector{String}
  cursor::Ref{Int}
  Args(args) = new(deepcopy(args), length(args))
end

Args() = Args(ARGS)

function next!(self::Args)
  arg = ParsedArg(self.items[self.cursor[]])
  self.cursor[] += 1
  arg
end

function peek(self::Args)
  if self.cursor[] > length(self.items)
    nothing
  else
    ParsedArg(self.items[self.cursor[]])
  end
end

function remaining(self::Args)
  r = self.items[self.cursor[]:end]
  self.cursor[] = length(self.items)
  r
end

insert!(self::Args, item) = insert!(self.items, self.cursor[], item)

seek(self::Args, pos::Integer) = self.cursor[] = pos

struct ParsedArg
  inner::String
end

isempty(self::ParsedArg) = isempty(self.inner)

isstdio(self::ParsedArg) = self.inner == "-"

isescape(self::ParsedArg) = self.inner == "--"

isnumeric(self::ParsedArg) = isnumeric(self.inner)

function to_long(self::ParsedArg)
  raw = self.inner
  remaining = lstrip(raw, "--")
  isempty(remaining) && return nothing
  @assert count(==('='), remaining) == 1
  flag, value = split(remaining, "=")
  flag, only(value)
end

function is_long(self::ParsedArg)
  startswith(self.inner, "--") && !isescape(self)
end

function to_short(self::ParsedArg)
  remainder = lstrip(self.inner, "-")
  startswith(remainder, "-") && return nothing
  isempty(remainder) && return nothing
  ShortFlags(remainder)
end

function is_short(self::ParsedArg)
  startswith(self.inner, "-") && !isstdio(self) && !startswith(self.inner, "--")
end

value(self::ParsedArg) = self.inner

struct ShortFlags
  inner::String
end

function advance_by!(self::ShortFlags, n::Int)
  for i in 1:n
    next_flag!(self) === nothing && return i - 1
  end
  return nothing
end

function is_empty(self::ShortFlags)
  isempty(self.inner)
end

function is_number(self::ShortFlags)
  isnumeric(self.inner)
end

function next_flag!(self::ShortFlags)
  flag, remaining = split(self.inner, ""; limit = 2)
  self.inner = remaining
  isempty(flag) ? nothing : flag[1]
end

using InlineTest

@testset "insert" begin
  raw = Args(["bin", "a", "b", "c"])
end

@testset "to_long_stdio" begin
  args = Args(["bin", "-"])
  next!(args)
  next_arg = next!(args)
  @test !is_long(next_arg)
  @test to_long(next_arg) === nothing
end

@testset "to_long_no_escape" begin
  args = Args(["bin", "--"])
  next!(args)
  next_arg = next!(args)
  @test !is_long(next_arg)
  @test to_long(next_arg) === nothing
end

@testset "to_long_no_value" begin
  args = Args(["bin", "--long"])
  next!(args)
  next_arg = next!(args)
  @test is_long(next_arg)
  key, value = to_long(next_arg)
  @test key == "long"
  @test value === nothing
end

@testset "to_long_with_empty_value" begin
  args = Args(["bin", "--long="])
  next!(args)
  next_arg = next!(args)
  @test is_long(next_arg)
  key, value = to_long(next_arg)
  @test key == "long"
  @test value == ""
end

@testset "to_long_with_value" begin
  args = Args(["bin", "--long=hello"])
  next!(args)
  next_arg = next!(args)
  @test is_long(next_arg)
  key, value = to_long(next_arg)
  @test key == "long"
  @test value == "hello"
end

@testset "to_short_stdio" begin
  args = Args(["bin", "-"])
  next!(args)
  next_arg = next!(args)
  @test !is_short(next_arg)
  @test to_short(next_arg) === nothing
end

@testset "to_short_escape" begin
  args = Args(["bin", "--"])
  next!(args)
  next_arg = next!(args)
  @test !is_short(next_arg)
  @test to_short(next_arg) === nothing
end

@testset "to_short_long" begin
  args = Args(["bin", "--long"])
  next!(args)
  next_arg = next!(args)
  @test !is_short(next_arg)
  @test to_short(next_arg) === nothing
end

@testset "to_short" begin
  args = Args(["bin", "-short"])
  next!(args)
  next_arg = next!(args)
  @test is_short(next_arg)
  shorts = to_short(next_arg)
  actual = join(shorts.inner)
  @test actual == "short"
end

@testset "is_negative_number" begin
  args = Args(["bin", "-10.0"])
  next!(args)
  next_arg = next!(args)
  @test isnumeric(next_arg.inner)
end

@testset "is_positive_number" begin
  args = Args(["bin", "10.0"])
  next!(args)
  next_arg = next!(args)
  @test isnumeric(next_arg.inner)
end

@testset "is_not_number" begin
  args = Args(["bin", "--10.0"])
  next!(args)
  next_arg = next!(args)
  @test !isnumeric(next_arg.inner)
end

@testset "is_stdio" begin
  args = Args(["bin", "-"])
  next!(args)
  next_arg = next!(args)
  @test isstdio(next_arg)
end

@testset "is_not_stdio" begin
  args = Args(["bin", "--"])
  next!(args)
  next_arg = next!(args)
  @test !isstdio(next_arg)
end

@testset "is_escape" begin
  args = Args(["bin", "--"])
  next!(args)
  next_arg = next!(args)
  @test isescape(next_arg)
end

@testset "is_not_escape" begin
  args = Args(["bin", "-"])
  next!(args)
  next_arg = next!(args)
  @test !isescape(next_arg)
end

end
