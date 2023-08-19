module Cli

using Comonicon
using Pkg
using PackageCompatUI
using LiveServer
using ..Startup

"""
    execute(cmd, project = ".")

Execute the given code `cmd` in the environment of the specified `project`.
"""
@cast function execute(cmd, project = ".")
  Pkg.activate(project)
  eval(Base.Meta.parse(cmd))
end

"""
    add(package, project = ".")

Add the specified `package` to the environment of the given `project`.
"""
@cast function add(package, project = ".")
  Pkg.activate(project)
  Pkg.add(package)
end

"""
    remove(package, project = ".")

Remove the specified `package` from the environment of the given `project`.
"""
@cast function remove(package, project = ".")
  Pkg.activate(project)
  Pkg.rm(package)
end

"""
    compat(project = ".")

Open the compatibility user interface for the specified `project`.
"""
@cast function compat(project = ".")
  Pkg.activate(project)
  PackageCompatUI.compat_ui()
end

"""
    instantiate(project = ".")

Instantiate the environment for the specified `project`, which ensures that the project has all the necessary dependencies.
"""
@cast function instantiate(project = ".")
  Pkg.activate(project)
  Pkg.instantiate()
end

"""
    test(project = ".")

Run tests for the specified `project`.
"""
@cast function test(project = ".")
  Pkg.activate(project)
  Pkg.test()
end

"""
    build(project = ".")

Build the specified `project`.
"""
@cast function build(project = ".")
  Pkg.activate(project)
  Pkg.build()
end

"""
    startup_build()

Build the Startup.jl project located at the specified path.
"""
@cast function startup_build()
  build("~/gitrepos/Startup.jl")
end

"""
    template(name)

Generate a template with the given `name`.
"""
@cast function template(name)
  Startup.template()(name)
end

"""
    serve(dir = ".")

Serve the content of the specified directory `dir` using the LiveServer package.
"""
@cast function serve(dir = ".")
  LiveServer.serve(; dir, launch_browser = true)
end

"""
    servedocs(project = "./docs")

Serve the documentation for the specified `project` using the LiveServer package.
"""
@cast function servedocs(project = "./docs")
  Pkg.activate(project)
  LiveServer.servedocs(; launch_browser = true)
end

@main

end
