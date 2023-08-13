module Startup

using Pkg
using PrecompileTools
using Dates
using PkgTemplates
using ArgParse
using MacroTools

include("macros.jl")
include("helpers.jl")
include("pkg.jl")
include("envs.jl")
include("jl.jl")

function __init__()
  atreplinit() do repl
    replinit(repl)
    ohmyreplinit(repl)
    repl_ast_transforms(repl)
  end
end

@setup_workload begin
  function _activate()
    cd(dirname(dirname(pathof(Startup))))
    Pkg.activate("."; io = Base.devnull)
    __init__()
  end
  @compile_workload begin
    using Pkg: Pkg as Pkg
    using Revise
    using OhMyREPL: JLFzf
    using OhMyREPL.JLFzf: fzf_jll
    using OhMyREPL.BracketInserter.Pkg.API.Operations.Registry: FileWatching
    using JuliaSyntax: JuliaSyntax
    push!(Revise.dont_watch_pkgs, :Startup)
  end
end

export @autoinfiltrate, @subprocess

end
