using Documenter
using CasADi

makedocs(
    sitename = "CasADi.jl",
    modules = [CasADi],
    checkdocs = :exports,
    doctest = false,
    linkcheck = false,
    format = Documenter.HTML(
        canonical = "https://docs.sciml.ai/CasADi/stable/"
    ),
    pages = [
        "Home" => "index.md",
        "API" => "api.md",
    ],
)

deploydocs(
    repo = "github.com/SciML/CasADi.jl.git",
    push_preview = true,
)
