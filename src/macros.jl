
"""
    @subprocess ex
    @subprocess ex wait=false

Execute `ex` in a subprocess that mimics the current process configuration.
Returns the constructed `Process`.
See [`Base.julia_cmd`](@ref) for the subprocess configuration forwarding that is used.

```julia-repl
julia> println("hello from $(Base.getpid())")
hello from 35640

julia> @subprocess println("hello from $(Base.getpid())")
hello from 43056
Process(`/home/user/julia/julia -Cnative -J/home/user/julia/usr/lib/julia/sys.dylib -g1 -e 'println("hello from $(Base.getpid())")'`, ProcessExited(0))
```
"""
macro subprocess(ex, wait = true)
  quote
    local ex_str = $(esc(sprint(Base.show_unquoted, ex)))
    run(`$(Base.julia_cmd()) -e "$(ex_str)"`; wait = $(wait))
  end
end

macro autoinfiltrate(cond = true)
  pkgid = Base.PkgId(Base.UUID("5903a43b-9cc3-4c30-8d17-598619ec4e9b"), "Infiltrator")
  if !haskey(Base.loaded_modules, pkgid)
    try
      Base.eval(Main, :(using Infiltrator))
    catch err
      @error "Cannot load Infiltrator.jl. Make sure it is included in your environment stack."
    end
  end
  i = get(Base.loaded_modules, pkgid, nothing)
  lnn = LineNumberNode(__source__.line, __source__.file)

  if i === nothing
    return Expr(:macrocall, Symbol("@warn"), lnn, "Could not load Infiltrator.")
  end

  return Expr(:macrocall, Expr(:., i, QuoteNode(Symbol("@infiltrate"))), lnn, esc(cond))
end

macro cn(x)
  if Sys.ARCH === :x86_64
    println("julia> @code_native syntax=:intel debuginfo=:none ", x)
    esc(:(Startup.InteractiveUtils.@code_native syntax = :intel debuginfo = :none $x))
  else
    println("julia> @code_native debuginfo=:none ", x)
    esc(:(Startup.InteractiveUtils.@code_native debuginfo = :none $x))
  end
end

macro cl(x)
  println("julia> @code_llvm debuginfo = :none ", x)
  esc(:(Startup.InteractiveUtils.@code_llvm debuginfo = :none $x))
end

macro d(x)
  println("julia> @descend_code_warntype debuginfo = :none ", x)
  esc(:(Startup.Cthulhu.@descend_code_typed debuginfo = :none annotate_source = false iswarn = true $x))
end

export @cn,
  @cl,
  @d,
  includet,
  @btime,
  @benchmark,
  @belapsed,
  @descend,
  @descend_code_typed,
  @descend_code_warntype,
  @autoinfiltrate,
  @subprocess
