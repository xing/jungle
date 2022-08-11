# Jungle

A command line tool to extract dependency graph statistics from a CocoaPods-based Xcode project.

## Installation

### [Mint](https://github.com/xing/jungle) (recommended)

```bash
mint install xing/jungle
mint run jungle@main help
```

### Manual

```bash
git clone https://github.com/xing/jungle
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


Outputs Comma Separated Values by default (JSON option available):
```shell
<timestamp>;<hash>;<nodeCount>;<complexity>;<author>;<message>
<timestamp>;<hash>;<nodeCount>;<complexity>;<author>;<message>
<timestamp>;<hash>;<nodeCount>;<complexity>;<author>;<message>
.
.
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

Outputs JSON formatted string

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

---

💡 Copy CSV (to paste in a spreadsheet) or DOT (to paste at http://viz-js.com) to the clipboard using `pbcopy`

```shell
jungle graph | pbcopy
jungle history | pbcopy
``` 


💡 Use Graphviz tool to generate your own graphs

```shell
brew install graphviz
jungle graph | dot -Tpng -o graph.png && open graph.png
jungle graph | dot -Tpng -o graph.png && open graph.png
```
 
