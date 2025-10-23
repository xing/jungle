# Jungle Sample Projects

This directory contains sample projects demonstrating how to use Jungle with different dependency management systems.

## Available Samples

### SPMSample
A Swift Package Manager project with popular dependencies including:
- Alamofire (networking)
- RealmSwift (database)
- SwiftyJSON (JSON parsing)
- Kingfisher (image loading)

### CocoaPodsSample
A CocoaPods-based iOS project with popular dependencies including:
- Alamofire (networking)
- Moya (network abstraction)
- SwiftyJSON (JSON parsing)
- Kingfisher (image loading)
- RxSwift & RxCocoa (reactive programming)
- SnapKit (Auto Layout)

## Usage

Navigate to any sample directory and run Jungle commands to analyze dependencies.

### For SPMSample:
```bash
cd SPMSample
jungle modules --target SPMSample
```

### For CocoaPodsSample:
```bash
cd CocoaPodsSample
jungle modules --target CocoaPodsSample
```
