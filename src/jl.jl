module Cli

using Comonicon
using Pkg
using PackageCompatUI
using LiveServer
using ..Startup

@cast function add(package, project = ".")
  Pkg.activate(project)
  Pkg.add(package)
end

@cast function remove(package, project = ".")
  Pkg.activate(project)
  Pkg.rm(package)
end

@cast function compat(project = ".")
  Pkg.activate(project)
  PackageCompatUI.compat_ui()
end

@cast function instantiate(project = ".")
  Pkg.activate(project)
  Pkg.instantiate()
end

@cast function test(project = ".")
  Pkg.activate(project)
  Pkg.test()
end

@cast function build(project = ".")
  Pkg.activate(project)
  Pkg.build()
end

@cast function startup_build(project = "~/gitrepos/Startup.jl")
  Pkg.activate(project)
  Pkg.build()
end

@cast function template(name)
  Startup.template()(name)
end

@cast function serve(dir = ".")
  LiveServer.serve(; dir, launch_browser = true)
end

@main

end
