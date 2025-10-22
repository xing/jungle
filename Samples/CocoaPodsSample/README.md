# CocoaPodsSample

A CocoaPods sample project demonstrating Jungle's analysis capabilities with iOS projects.

## Dependencies

This project includes popular CocoaPods:
- **Alamofire** (~> 5.8) - HTTP networking library
- **Moya** (~> 15.0) - Network abstraction layer
- **SwiftyJSON** (~> 5.0) - JSON parsing library
- **Kingfisher** (~> 7.10) - Image downloading and caching
- **RxSwift** (~> 6.6) - Reactive programming framework
- **RxCocoa** (~> 6.6) - Reactive extensions for Cocoa
- **SnapKit** (~> 5.6) - Auto Layout DSL

## Setup

1. Install dependencies:
```bash
pod install
```

2. Open the workspace:
```bash
open CocoaPodsSample.xcworkspace
```

## Usage

Run Jungle to analyze module dependencies:

```bash
jungle modules --target CocoaPodsSample
```

## Note

This sample project has a git repository initialized with Podfile.lock committed, which allows Jungle to analyze the dependency graph.
