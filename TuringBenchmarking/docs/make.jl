using TuringBenchmarking
using Documenter

DocMeta.setdocmeta!(TuringBenchmarking, :DocTestSetup, :(using TuringBenchmarking); recursive=true)

makedocs(;
    modules=[TuringBenchmarking],
    authors="Tor Erlend Fjelde <torfjelde.github@gmail.com> and contributors",
    repo="https://github.com/TuringLang/depreciated/blob/{commit}{path}#{line}",
    sitename="TuringBenchmarking.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://github.com/TuringLang/depreciated",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
