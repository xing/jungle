# Jungle

[![Swift](https://github.com/xing/jungle/actions/workflows/swift.yml/badge.svg)](https://github.com/xing/jungle/actions/workflows/swift.yml)

A Swift command line tool to extract dependency information from a CocoaPods-based Xcode project. Currently, that´s what you can do:
- Dependency graph (dot format)
- Cyclomatic complexity evaluation 
- Number of dependant modules
- Compare stats between different branches or even through the git history

You can read more information about dependency complexity in our Technical article ["How to control your dependencies"](https://medium.com/@OswaldoRubio/how-to-control-your-dependencies-7690cc7b1c40).

## Table of contents

- [Installation](#installation)
  * [Mint](#mint)
  * [Manual](#manual)
- [Usage](#usage)
  * [Fetch Historic Complexities](#fetch-historic-complexities)
  * [Compare Complexity Graphs](#compare-complexity-graphs)
  * [Visualize Complexity Graphs](#visualize-complexity-graphs)
    + [Some tips](#some-tips)
- [Contributing](#contributing)
  * [Contributor License Agreement](#contributor-license-agreement)

## Installation

### Mint

```bash
mint install xing/jungle
mint run jungle help
```

### Manual

```bash
git clone https://github.com/xing/jungle
cd jungle
swift build -c release
.build/release/jungle help
```

## Usage

### Fetch Historic Complexities

```shell
OVERVIEW: Displays historic complexity of the dependency graph

USAGE: jungle history [--since <since>] [--pod <pod>] [--output-format <output-format>] [<directory-path>]

ARGUMENTS:
  <directory-path>        Path to the directory where Podfile.lock is located (default: .)

OPTIONS:
  --since <since>         Equivalent to git-log --since: Eg: '6 months ago' (default: 6 months ago)
  --pod <pod>             The Pod to generate a report for. Omitting this generates a report for a virtual `App` target that imports all Pods
  --output-format <output-format>
                          csv or json (default: csv)
  --version               Show the version.
  -h, --help              Show help information.
```


Example:

```shell
jungle history ProjectDirectory/ --since '1 week ago'

2022-08-30T15:12:14+02:00;cdb9d2ce64a;124;21063;Author;commit message
2022-09-02T11:02:12+02:00;4fdf3a157a4;124;21063;Author;commit message
Now;Current;124;21063;;
```

### Compare Complexity Graphs

```shell
OVERVIEW: Compares the current complexity of the dependency graph to others versions in git

USAGE: jungle compare [--to <git-object> ...] [--pod <pod>] [<directory-path>]

ARGUMENTS:
  <directory-path>        Path to the directory where Podfile.lock is located (default: .)

OPTIONS:
  --to <git-object>       The git objects to compare the current graph to. Eg: - 'main', 'my_branch', 'some_commit_hash'. (default: HEAD, main, master)
  --pod <pod>             The Pod to compare. Omitting this generates compares a virtual `App` target that imports all Pods
  --version               Show the version.
  -h, --help              Show help information.
```

Example:

```shell

jungle compare ProjectDirectory/ --to main
[
  {
    "modules" : 124,
    "complexity" : 20063,
    "name" : "Current",
    "moduleCount" : 124
  },
  {
    "modules" : 124,
    "complexity" : 21063,
    "name" : "main",
    "moduleCount" : 124
  }
]
```

### Visualize Complexity Graphs

```shell
OVERVIEW: Outputs the dependency graph in DOT format

USAGE: jungle graph [--of <git-object>] [--pod <pod>] [<directory-path>]

ARGUMENTS:
  <directory-path>        Path to the directory where Podfile.lock is located (default: .)

OPTIONS:
  --of <git-object>       A git object representing the version to draw the graph for. Eg: - 'main', 'my_branch', 'some_commit_hash'.
  --pod <pod>             The Pod to graph. Omitting this generates compares a virtual `App` target that imports all Pods
  --version               Show the version.
  -h, --help              Show help information.

```

Outputs DOT format which can be viewed using http://viz-js.com


#### Some tips

💡 Copy CSV (to paste in a spreadsheet) or DOT (to paste at http://viz-js.com) to the clipboard using `pbcopy`

```shell
jungle graph | pbcopy
jungle history | pbcopy
``` 


💡 Use Graphviz tool to generate your own graphs

```shell
brew install graphviz
jungle graph | dot -Tpng -o graph.png && open graph.png
```
 
## Contributing

🎁 Bug reports and pull requests for new features/ideas are most welcome!

👷🏼 We are looking forward to your pull request, we'd love to help!

You can help by doing any of the following:

- Reviewing pull requests
- Bringing ideas for new features
- Answering questions on issues
- Improving documentation


This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant code](http://contributor-covenant.org/) of conduct.

### Contributor License Agreement

Contributions to this project must be accompanied by a Contributor License
Agreement. You (or your employer) retain the copyright to your contribution,
this simply gives us permission to use and redistribute your contributions as
part of the project. Find the agreement [here][XING CLA] and head over to [the
contributors page][contributors] and find a XING employee to contact for further
instructions.

You generally only need to submit a CLA once, so if you've already submitted one
(even if it was for a different project), you probably don't need to do it
again.

[XING CLA]: docs/XING_CLAv2.md
[contributors]: https://github.com/xing/jungle/graphs/contributors
