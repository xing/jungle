# SPMSample

A complex Swift Package Manager sample project demonstrating Jungle's analysis capabilities with multiple internal modules and dependencies.

## Architecture

This project demonstrates a multi-module architecture with internal dependencies:

### Internal Modules

- **Core** - Base utilities (no dependencies)
- **Networking** - HTTP client layer (depends on Core, Alamofire, SwiftyJSON)
- **DataLayer** - Data persistence (depends on Core, RealmSwift)
- **APIClient** - API integration (depends on Networking, DataLayer)
- **ImageService** - Image loading (depends on Core, Kingfisher)
- **Feature1** - User profile feature (depends on Core, APIClient, ImageService)
- **Feature2** - Data sync feature (depends on Core, Networking, DataLayer)
- **SPMSample** - Main module (depends on all modules)

### Dependency Graph

```
SPMSample
├── Core
├── Networking
│   ├── Core
│   ├── Alamofire
│   └── SwiftyJSON
├── DataLayer
│   ├── Core
│   └── RealmSwift
├── APIClient
│   ├── Networking
│   └── DataLayer
├── ImageService
│   ├── Core
│   └── Kingfisher
├── Feature1
│   ├── Core
│   ├── APIClient
│   └── ImageService
└── Feature2
    ├── Core
    ├── Networking
    └── DataLayer
```

## External Dependencies

- **Alamofire** (5.8.0+) - HTTP networking library
- **RealmSwift** (10.45.0+) - Mobile database
- **SwiftyJSON** (5.0.0+) - JSON parsing library
- **Kingfisher** (7.10.0+) - Image downloading and caching

## Usage with Jungle

Analyze the main module dependencies:
```bash
jungle modules --target SPMSample
```

Analyze a specific internal module:
```bash
jungle modules --target Networking
```

Find dependants of a module:
```bash
jungle dependant --target Core
```

Generate dependency graph:
```bash
jungle graph --target SPMSample
```

## Building

```bash
swift build
```

## Testing

```bash
swift test
```
