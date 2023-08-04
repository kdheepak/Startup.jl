module PkgStack

import Pkg
import Markdown: @md_str

function stack(envs)
  if isempty(envs)
    printstyled(" The current stack:\n", bold=true)
    println.("  " .* LOAD_PATH)
  else
    for env in envs
      if env ∉ LOAD_PATH
        push!(LOAD_PATH, env)
      end
    end
  end
end

const STACK_SPEC = Pkg.REPLMode.CommandSpec(
  name="stack",
  api=stack,
  help=md"""
    stack envs...
Stack another environment.
""",
  description="Stack another environment",
  completions=Pkg.REPLMode.complete_activate,
  should_splat=false,
  arg_count=0 => Inf)

function unstack(envs)
  if isempty(envs)
    printstyled(" The current stack:\n", bold=true)
    println.("  " .* LOAD_PATH)
  else
    deleteat!(LOAD_PATH, sort(filter(!isnothing, indexin(envs, LOAD_PATH))))
  end
end

const UNSTACK_SPEC = Pkg.REPLMode.CommandSpec(
  name="unstack",
  api=unstack,
  help=md"""
    unstack envs...
Unstack a previously stacked environment.
""",
  description="Unstack an environment",
  completions=(_, partial, _, _) ->
    filter(p -> startswith(p, partial), LOAD_PATH),
  should_splat=false,
  arg_count=0 => Inf)

function environments()
  envs = String[]
  for depot in Base.DEPOT_PATH
    envdir = joinpath(depot, "environments")
    isdir(envdir) || continue
    for env in readdir(envdir)
      if !isnothing(match(r"^__", env))
      elseif !isnothing(match(r"^v\d+\.\d+$", env))
      else
        push!(envs, '@' * env)
      end
    end
  end
  envs = Base.DEFAULT_LOAD_PATH ∪ LOAD_PATH ∪ envs
  for env in envs
    if env in LOAD_PATH
      print("  ", env)
    else
      printstyled("  ", env, color=:light_black)
      if env in Base.DEFAULT_LOAD_PATH
        printstyled(" (unloaded)", color=:light_red)
      end
    end
    if env == "@"
      printstyled(" [current environment]", color=:light_black)
    elseif env == "@v#.#"
      printstyled(" [global environment]", color=:light_black)
    elseif env == "@stdlib"
      printstyled(" [standard library]", color=:light_black)
    elseif env in LOAD_PATH
      printstyled(" (loaded)", color=:green)
    end
    print('\n')
  end
end

const ENVS_SPEC = Pkg.REPLMode.CommandSpec(
  name="environments",
  short_name="envs",
  api=environments,
  help=md"""
    environments|envs
List all known named environments.
""",
  description="List all known named environments",
  arg_count=0 => 0)

const SPECS = Dict(
  "stack" => STACK_SPEC,
  "unstack" => UNSTACK_SPEC,
  "environments" => ENVS_SPEC,
  "envs" => ENVS_SPEC)

function __init__()
  # add the commands to the repl
  activate = Pkg.REPLMode.SPECS["package"]["activate"]
  activate_modified = Pkg.REPLMode.CommandSpec(
    activate.canonical_name,
    "a", # Modified entry, short name
    activate.api,
    activate.should_splat,
    activate.argument_spec,
    activate.option_specs,
    activate.completions,
    activate.description,
    activate.help)
  SPECS["activate"] = activate_modified
  SPECS["a"] = activate_modified
  Pkg.REPLMode.SPECS["package"] = merge(Pkg.REPLMode.SPECS["package"], SPECS)
  # update the help with the new commands
  copy!(Pkg.REPLMode.help.content, Pkg.REPLMode.gen_help().content)
end

end

