module Startup

using PrecompileTools

include("macros.jl")
include("helpers.jl")
include("pkg.jl")
include("envs.jl")
# include("jl.jl")

function __init__()
  atreplinit() do repl
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
    using Infiltrator
    using ArgParse
    using BenchmarkTools
    using Crayons
    using Cthulhu
    using Dates
    using Infiltrator
    using InteractiveUtils
    using JuliaSyntax: JuliaSyntax
    using LinearAlgebra
    using OhMyREPL
    using Pkg
    using OhMyREPL: JLFzf
    using OhMyREPL.JLFzf: fzf_jll
    using OhMyREPL.BracketInserter.Pkg.API.Operations.Registry: FileWatching
    using OhMyREPL
    OhMyREPL.enable_pass!("RainbowBrackets", false)
    OhMyREPL.enable_autocomplete_brackets(false)
    OhMyREPL.colorscheme!("OneDark")

    push!(Revise.dont_watch_pkgs, :Startup)
  end
end

export @autoinfiltrate, @subprocess

end
