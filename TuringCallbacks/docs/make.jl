using TuringCallbacks
using Documenter

makedocs(;
    modules=[TuringCallbacks],
    authors="Tor",
    repo="https://github.com/TuringLang/Deprecated/blob/{commit}{path}#L{line}",
    sitename="TuringCallbacks.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://turinglang.github.io/Deprecated/TuringCallbacks.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
