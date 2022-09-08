import XCTest
@testable import PodExtractor

final class PodExtractorTests: XCTestCase {

    func testExtractModulesYieldsModules() throws {
        let podfile = """
        PODS:
          - A (1.0.0):
            - B
            - C
          - D (1.0.0)
        """

        let modules = try extractModulesFromPodfile(podfile)

        XCTAssertEqual(modules.count, 2)
    }

    func testExtractModulesIgnoresSubspecs() throws {
        let podfile = """
        PODS:
          - A (1.0.0)
          - B/Tests (1.0.0)
        """

        let modules = try extractModulesFromPodfile(podfile)

        XCTAssertEqual(modules.count, 1)
    }

    func testExtractModulesIgnoresExternals() throws {
        let podfile = """
        PODS:
          - ACPAnalytics (2.5.0):
            - ACPAnalytics/xcframeworks (= 2.5.0)
            - ACPCore (>= 2.9.0)
          - ACPCore (2.9.3):
            - ACPCore/main (= 2.9.3)
          - A
            - ACPAnalytics
        SPEC REPOS:
          trunk:
            - ACPAnalytics
            - ACPCore
        """

        let modules = try extractModulesFromPodfile(podfile)

        XCTAssertEqual(modules.count, 1)
    }
    
    func testIgnoreSpecsRepos() throws {
        let podfile = """
        PODS:
          - featureA (0.1.0)
          - featureB (0.1.0)

        DEPENDENCIES:
          - featureA (from `internal/featureA`)
          - featureB (from `internal/featureB`)

        EXTERNAL SOURCES:
          featureA:
            :path: internal/featureA
          featureB:
            :path: internal/featureB

        SPEC CHECKSUMS:
          featureA: 8c48aa91cec618f6cdbbfd451d5c9412a7c08035
          featureB: 9623fc49926f1afc2f5534b6c1b96dc1440e2d94

        PODFILE CHECKSUM: 30d85a2de434815237a4f5a02ef65b006399ab71

        COCOAPODS: 1.11.3
        """
        
        let modules = try extractModulesFromPodfile(podfile)

        XCTAssertEqual(modules.count, 2)
    }
    
    
    func testDependenciesForTargetInPodfile() throws {
        let podfile = """
        sources:
          - https://cdn.cocoapods.org/
          - https://github.com/artsy/Specs.git
        target_definitions:
          - abstract: true
            children:
              - children:
                  - abstract: false
                    dependencies:
                      - FBSnapshotTestCase
                      - Forgeries
                      - Nimble
                      - Nimble-Snapshots
                      - Quick
                      - RxBlocking
                      - RxNimble
                    inheritance: search_paths
                    name: KioskTests
                dependencies:
                  - Action
                  - ARAnalytics/HockeyApp
                  - ARAnalytics/Segmentio
                  - ARCollectionViewMasonryLayout:
                    - "~> 2.0.0"
                  - ARTiledImageView
                  - "Artsy+OSSUIFonts"
                  - "Artsy+UIColors"
                  - "Artsy+UILabels"
                  - Artsy-UIButtons
                  - CardFlight-v4
                  - DZNWebViewController:
                    - :git: https://github.com/orta/DZNWebViewController.git
                  - ECPhoneNumberFormatter
                  - FLKAutoLayout:
                    - 0.1.1
                  - HockeySDK-Source:
                    - :git: https://github.com/bitstadium/HockeySDK-iOS.git
                  - ISO8601DateFormatter
                  - Moya/RxSwift
                  - "NSObject+Rx"
                  - ReachabilitySwift
                  - RxCocoa
                  - RxOptional
                  - RxSwift
                  - SDWebImage:
                    - "~> 3.7"
                  - Stripe:
                    - 14.0.1
                  - SVProgressHUD
                  - SwiftyJSON
                  - UIImageViewAligned:
                    - :git: https://github.com/ashfurrow/UIImageViewAligned.git
                  - "UIView+BooleanAnimations"
                  - XNGMarkdownParser
                name: Kiosk
            inhibit_warnings:
              all: true
            name: Pods
            platform:
              ios: '10.0'
            uses_frameworks:
              :linkage: :dynamic
              :packaging: :framework
        """
        
        
        let modules = try extractDependencies(for: "Kiosk", podfile)

        XCTAssertEqual(modules.count, 28)
    }
}
