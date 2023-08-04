module Clap

struct Args
  items::Vector{String}
  cursor::Ref{Int}
  Args() = new(deepcopy(ARGS), length(ARGS))
end

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

insert!(self::Args, index::Integer, item) = insert!(self.items, index, item)

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

end
