module Cli

using Comonicon
using Pkg
using PackageCompatUI

@cast function add(package, project = ".")
  Pkg.activate(project)
  Pkg.add(package)
end

@cast function build(project = ".")
  Pkg.activate(project)
  Pkg.build()
end

@cast function compat(project = ".")
  Pkg.activate(project)
  PackageCompatUI.compat_ui()
end

@main

end
