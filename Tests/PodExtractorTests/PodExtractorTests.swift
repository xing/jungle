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

        let modules = try extractModulesFromPodfileLock(podfile)

        XCTAssertEqual(modules.count, 2)
    }

    func testExtractModulesIgnoresSubspecs() throws {
        let podfile = """
        PODS:
          - A (1.0.0)
          - B/Tests (1.0.0)
        """

        let modules = try extractModulesFromPodfileLock(podfile)

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

        let modules = try extractModulesFromPodfileLock(podfile)

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
        
        let modules = try extractModulesFromPodfileLock(podfile)

        XCTAssertEqual(modules.count, 2)
    }
    
    func testTargetModulesFromPodfileLock() throws {
        
        // Example Podfile from https://github.com/artsy/eidolon
        let podfile = """
        {
           "sources" : [
              "https://github.com/artsy/Specs.git",
              "https://cdn.cocoapods.org/"
           ],
           "target_definitions" : [
              {
                 "abstract" : true,
                 "children" : [
                    {
                       "children" : [
                          {
                             "abstract" : false,
                             "dependencies" : [
                                "FBSnapshotTestCase",
                                "Nimble-Snapshots",
                                "Quick",
                                "Nimble",
                                "RxNimble",
                                "Forgeries",
                                "RxBlocking"
                             ],
                             "inheritance" : "search_paths",
                             "name" : "KioskTests"
                          }
                       ],
                       "dependencies" : [
                          "Artsy+UIColors",
                          "Artsy+UILabels",
                          "Artsy-UIButtons",
                          "Artsy+OSSUIFonts",
                          {
                             "FLKAutoLayout" : [
                                "0.1.1"
                             ]
                          },
                          {
                             "ARCollectionViewMasonryLayout" : [
                                "~> 2.0.0"
                             ]
                          },
                          {
                             "SDWebImage" : [
                                "~> 3.7"
                             ]
                          },
                          "SVProgressHUD",
                          {
                             "HockeySDK-Source" : [
                                {
                                   "git" : "https://github.com/bitstadium/HockeySDK-iOS.git"
                                }
                             ]
                          },
                          "ARAnalytics/Segmentio",
                          "ARAnalytics/HockeyApp",
                          "CardFlight-v4",
                          {
                             "Stripe" : [
                                "14.0.1"
                             ]
                          },
                          "ECPhoneNumberFormatter",
                          {
                             "UIImageViewAligned" : [
                                {
                                   "git" : "https://github.com/ashfurrow/UIImageViewAligned.git"
                                }
                             ]
                          },
                          {
                             "DZNWebViewController" : [
                                {
                                   "git" : "https://github.com/orta/DZNWebViewController.git"
                                }
                             ]
                          },
                          "ReachabilitySwift",
                          "UIView+BooleanAnimations",
                          "ARTiledImageView",
                          "XNGMarkdownParser",
                          "ISO8601DateFormatter",
                          "SwiftyJSON",
                          "RxSwift",
                          "RxCocoa",
                          "RxOptional",
                          "Moya/RxSwift",
                          "NSObject+Rx",
                          "Action"
                       ],
                       "name" : "Kiosk"
                    }
                 ],
                 "inhibit_warnings" : {
                    "all" : true
                 },
                 "name" : "Pods",
                 "platform" : {
                    "ios" : "10.0"
                 },
                 "uses_frameworks" : {
                    "linkage" : "dynamic",
                    "packaging" : "framework"
                 }
              }
           ]
        }
        """
        
        let targets = try extractModulesFromPodfile(podfile)
        
        XCTAssertEqual(targets.count, 2)
        let expectedDependencies = ["Artsy+UIColors",
                        "Artsy+UILabels",
                        "Artsy-UIButtons",
                        "Artsy+OSSUIFonts",
                        "FLKAutoLayout",
                        "ARCollectionViewMasonryLayout",
                        "SDWebImage",
                        "SVProgressHUD",
                        "HockeySDK-Source",
                        "ARAnalytics/Segmentio",
                        "ARAnalytics/HockeyApp",
                        "CardFlight-v4",
                        "Stripe",
                        "ECPhoneNumberFormatter",
                        "UIImageViewAligned",
                        "DZNWebViewController",
                        "ReachabilitySwift",
                        "UIView+BooleanAnimations",
                        "ARTiledImageView",
                        "XNGMarkdownParser",
                        "ISO8601DateFormatter",
                        "SwiftyJSON",
                        "RxSwift",
                        "RxCocoa",
                        "RxOptional",
                        "Moya/RxSwift",
                        "NSObject+Rx",
                        "Action"]
        
        let firstTarget = try XCTUnwrap(targets.first)
        
        XCTAssertEqual(firstTarget.name, "Kiosk")
        XCTAssertEqual(firstTarget.dependencies, expectedDependencies)
    }
}
