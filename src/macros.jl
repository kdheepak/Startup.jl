
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
macro subprocess(ex, wait=true)
  quote
    local ex_str = $(esc(sprint(Base.show_unquoted, ex)))
    run(`$(Base.julia_cmd()) -e "$(ex_str)"`, wait=$(wait))
  end
end

# Silent @show version (omit the right-hand side)
# https://github.com/mroavi/dotfiles/blob/2d1f6d05515153b3616f5384faf85e2d406a6e26/julia/.julia/config/startup.jl#L147
macro sshow(exs...)
  blk = Expr(:block)
  for ex in exs
    push!(blk.args, :(println(repr(begin
      local value = $(esc(ex))
    end))))
  end
  isempty(exs) || push!(blk.args, :value)
  return blk
end

