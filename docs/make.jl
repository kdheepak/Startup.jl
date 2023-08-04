using Startup
using Documenter

DocMeta.setdocmeta!(Startup, :DocTestSetup, :(using Startup); recursive=true)

makedocs(;
    modules=[Startup],
    authors="Dheepak Krishnamurthy",
    repo="https://github.com/kdheepak/Startup.jl/blob/{commit}{path}#{line}",
    sitename="Startup.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://kdheepak.github.io/Startup.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/kdheepak/Startup.jl",
    devbranch="main",
)
