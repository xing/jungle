import XCTest
@testable import SPMExtractor

final class SPMExtractorTests: XCTestCase {
    func testTargetModulesFromPackage() throws {
        let rawPackage = """
        {
          "dependencies" : [
            {
              "identity" : "swift-argument-parser",
              "requirement" : {
                "range" : [
                  {
                    "lower_bound" : "1.1.3",
                    "upper_bound" : "2.0.0"
                  }
                ]
              },
              "type" : "sourceControl",
              "url" : "https://github.com/apple/swift-argument-parser"
            },
            {
              "identity" : "yams",
              "requirement" : {
                "range" : [
                  {
                    "lower_bound" : "5.0.1",
                    "upper_bound" : "6.0.0"
                  }
                ]
              },
              "type" : "sourceControl",
              "url" : "https://github.com/jpsim/Yams.git"
            }
          ],
          "manifest_display_name" : "jungle",
          "name" : "jungle",
          "path" : "/Users/oswaldo.rubio/Developer/jungle/jungle",
          "platforms" : [
            {
              "name" : "macos",
              "version" : "12.0"
            }
          ],
          "products" : [
            {
              "name" : "jungle",
              "targets" : [
                "jungle"
              ],
              "type" : {
                "executable" : null
              }
            },
            {
              "name" : "PodExtractor",
              "targets" : [
                "PodExtractor"
              ],
              "type" : {
                "library" : [
                  "automatic"
                ]
              }
            },
            {
              "name" : "SPMExtractor",
              "targets" : [
                "SPMExtractor"
              ],
              "type" : {
                "library" : [
                  "automatic"
                ]
              }
            },
            {
              "name" : "DependencyGraph",
              "targets" : [
                "DependencyGraph"
              ],
              "type" : {
                "library" : [
                  "automatic"
                ]
              }
            },
            {
              "name" : "Shell",
              "targets" : [
                "Shell"
              ],
              "type" : {
                "library" : [
                  "automatic"
                ]
              }
            }
          ],
          "targets" : [
            {
              "c99name" : "jungleTests",
              "module_type" : "SwiftTarget",
              "name" : "jungleTests",
              "path" : "Tests/jungleTests",
              "sources" : [
                "GitLogEntryTests.swift"
              ],
              "target_dependencies" : [
                "jungle"
              ],
              "type" : "test"
            },
            {
              "c99name" : "jungle",
              "module_type" : "SwiftTarget",
              "name" : "jungle",
              "path" : "Sources/jungle",
              "product_dependencies" : [
                "ArgumentParser"
              ],
              "product_memberships" : [
                "jungle"
              ],
              "sources" : [
                "Commands/CompareCommand.swift",
                "Commands/GraphCommand.swift",
                "Commands/HistoryCommand.swift",
                "Commands/Main.swift",
                "Models/GitLogEntry.swift",
                "Models/Outputs.swift"
              ],
              "target_dependencies" : [
                "PodExtractor",
                "SPMExtractor",
                "DependencyGraph",
                "Shell"
              ],
              "type" : "executable"
            },
            {
              "c99name" : "Shell",
              "module_type" : "SwiftTarget",
              "name" : "Shell",
              "path" : "Sources/Shell",
              "product_memberships" : [
                "jungle",
                "PodExtractor",
                "SPMExtractor",
                "Shell"
              ],
              "sources" : [
                "Shell.swift"
              ],
              "type" : "library"
            },
            {
              "c99name" : "SPMExtractorTests",
              "module_type" : "SwiftTarget",
              "name" : "SPMExtractorTests",
              "path" : "Tests/SPMExtractorTests",
              "sources" : [
                "File.swift"
              ],
              "target_dependencies" : [
                "SPMExtractor"
              ],
              "type" : "test"
            },
            {
              "c99name" : "SPMExtractor",
              "module_type" : "SwiftTarget",
              "name" : "SPMExtractor",
              "path" : "Sources/SPMExtractor",
              "product_memberships" : [
                "jungle",
                "SPMExtractor"
              ],
              "sources" : [
                "Module+Package.swift"
              ],
              "target_dependencies" : [
                "DependencyModule",
                "Shell",
                "DependencyGraph"
              ],
              "type" : "library"
            },
            {
              "c99name" : "PodExtractorTests",
              "module_type" : "SwiftTarget",
              "name" : "PodExtractorTests",
              "path" : "Tests/PodExtractorTests",
              "sources" : [
                "PodExtractorTests.swift"
              ],
              "target_dependencies" : [
                "PodExtractor"
              ],
              "type" : "test"
            },
            {
              "c99name" : "PodExtractor",
              "module_type" : "SwiftTarget",
              "name" : "PodExtractor",
              "path" : "Sources/PodExtractor",
              "product_dependencies" : [
                "Yams"
              ],
              "product_memberships" : [
                "jungle",
                "PodExtractor"
              ],
              "sources" : [
                "Module+Podfile.swift"
              ],
              "target_dependencies" : [
                "DependencyModule",
                "Shell"
              ],
              "type" : "library"
            },
            {
              "c99name" : "DependencyModule",
              "module_type" : "SwiftTarget",
              "name" : "DependencyModule",
              "path" : "Sources/DependencyModule",
              "product_memberships" : [
                "jungle",
                "PodExtractor",
                "SPMExtractor",
                "DependencyGraph"
              ],
              "sources" : [
                "Module.swift"
              ],
              "type" : "library"
            },
            {
              "c99name" : "DependencyGraphTests",
              "module_type" : "SwiftTarget",
              "name" : "DependencyGraphTests",
              "path" : "Tests/DependencyGraphTests",
              "sources" : [
                "DependencyGraphTests.swift"
              ],
              "target_dependencies" : [
                "DependencyGraph"
              ],
              "type" : "test"
            },
            {
              "c99name" : "DependencyGraph",
              "module_type" : "SwiftTarget",
              "name" : "DependencyGraph",
              "path" : "Sources/DependencyGraph",
              "product_memberships" : [
                "jungle",
                "SPMExtractor",
                "DependencyGraph"
              ],
              "sources" : [
                "Graph+Dot.swift",
                "Graph+Make.swift",
                "Graph+Stats.swift",
                "Graph.swift"
              ],
              "target_dependencies" : [
                "DependencyModule"
              ],
              "type" : "library"
            }
          ],
          "tools_version" : "5.5"
        }
        """
        
        let (dependencies, targetDependencies) = try extracPackageModules(from: rawPackage, target: "SPMExtractor")
        
        XCTAssertEqual(dependencies.map(\.name).sorted(), ["DependencyGraph", "DependencyModule", "SPMExtractor", "Shell"])
        XCTAssertEqual(targetDependencies.sorted(), ["DependencyGraph", "DependencyModule", "Shell"])
    }
    
    func testNonExistentTargetModulesFromPackage() throws {
        let rawPackage = """
        {
          "dependencies" : [

          ],
          "manifest_display_name" : "Example",
          "name" : "Example",
          "path" : "/Users/oswaldo.rubio/Desktop/Example",
          "platforms" : [

          ],
          "products" : [
            {
              "name" : "Example",
              "targets" : [
                "Example"
              ],
              "type" : {
                "library" : [
                  "automatic"
                ]
              }
            }
          ],
          "targets" : [
            {
              "c99name" : "ExampleTests",
              "module_type" : "SwiftTarget",
              "name" : "ExampleTests",
              "path" : "Tests/ExampleTests",
              "sources" : [
                "ExampleTests.swift"
              ],
              "target_dependencies" : [
                "Example"
              ],
              "type" : "test"
            },
            {
              "c99name" : "Example",
              "module_type" : "SwiftTarget",
              "name" : "Example",
              "path" : "Sources/Example",
              "product_memberships" : [
                "Example"
              ],
              "sources" : [
                "Example.swift"
              ],
              "type" : "library"
            }
          ],
          "tools_version" : "5.7"
        }
        """

        XCTAssertThrowsError(try extracPackageModules(from: rawPackage, target: "NonExistentTarget"))
    }

    func testTargetDependantFromTarget() throws {
        let rawPackage = """
        {
          "dependencies" : [
            {
              "identity" : "yams",
              "requirement" : {
                "range" : [
                  {
                    "lower_bound" : "5.0.1",
                    "upper_bound" : "6.0.0"
                  }
                ]
              },
              "type" : "sourceControl",
              "url" : "https://github.com/jpsim/Yams.git"
            }
          ],
          "manifest_display_name" : "SamplePackage",
          "name" : "SamplePackage",
          "path" : "/Users/oswaldo.rubio/Desktop/SamplePackage",
          "platforms" : [

          ],
          "products" : [
            {
              "name" : "SamplePackage",
              "targets" : [
                "SamplePackage"
              ],
              "type" : {
                "library" : [
                  "automatic"
                ]
              }
            }
          ],
          "targets" : [
            {
              "c99name" : "SamplePackageTests",
              "module_type" : "SwiftTarget",
              "name" : "SamplePackageTests",
              "path" : "Tests/SamplePackageTests",
              "sources" : [
                "SamplePackageTests.swift"
              ],
              "target_dependencies" : [
                "SamplePackage"
              ],
              "type" : "test"
            },
            {
              "c99name" : "SamplePackage",
              "module_type" : "SwiftTarget",
              "name" : "SamplePackage",
              "path" : "Sources/SamplePackage",
              "product_memberships" : [
                "SamplePackage"
              ],
              "sources" : [
                "SamplePackage.swift"
              ],
              "type" : "library"
            },
            {
              "c99name" : "LibraryTests",
              "module_type" : "SwiftTarget",
              "name" : "LibraryTests",
              "path" : "Tests/LibraryTests",
              "sources" : [
                "File.swift"
              ],
              "target_dependencies" : [
                "Library"
              ],
              "type" : "test"
            },
            {
              "c99name" : "Library",
              "module_type" : "SwiftTarget",
              "name" : "Library",
              "path" : "Sources/Library",
              "sources" : [
                "File.swift"
              ],
              "target_dependencies" : [
                "SamplePackage"
              ],
              "type" : "library"
            },
            {
              "c99name" : "BinaryTarget",
              "module_type" : "BinaryTarget",
              "name" : "BinaryTarget",
              "path" : "remote/archive/101116667.zip",
              "product_memberships" : [
              ],
              "sources" : [

              ],
              "type" : "binary"
            }
          ],
          "tools_version" : "5.7"
        }
        """
        
        
        let dependant = try extractDependantTargets(from: rawPackage, target: "SamplePackage")
        XCTAssertEqual(dependant.map(\.name).sorted(), ["Library", "LibraryTests", "SamplePackageTests"])
    }
    
    func testProductModulesFromPackage() throws {
        let rawPackage = """
        {
          "dependencies" : [
            {
              "identity" : "swift-algorithms",
              "requirement" : {
                "range" : [
                  {
                    "lower_bound" : "1.0.0",
                    "upper_bound" : "2.0.0"
                  }
                ]
              },
              "type" : "sourceControl",
              "url" : "https://github.com/apple/swift-algorithms"
            }
          ],
          "manifest_display_name" : "MyPackage",
          "name" : "MyPackage",
          "path" : "/Users/oswaldo.rubio/Desktop/MyPackage",
          "platforms" : [

          ],
          "products" : [
            {
              "name" : "MyPackage",
              "targets" : [
                "MyPackage"
              ],
              "type" : {
                "library" : [
                  "automatic"
                ]
              }
            },
            {
              "name" : "FeaturesContainer",
              "targets" : [
                "MyPackage"
              ],
              "type" : {
                "library" : [
                  "automatic"
                ]
              }
            }
          ],
          "targets" : [
            {
              "c99name" : "MyPackageTests",
              "module_type" : "SwiftTarget",
              "name" : "MyPackageTests",
              "path" : "Tests/MyPackageTests",
              "sources" : [
                "MyPackageTests.swift"
              ],
              "target_dependencies" : [
                "MyPackage"
              ],
              "type" : "test"
            },
            {
              "c99name" : "MyPackage",
              "module_type" : "SwiftTarget",
              "name" : "MyPackage",
              "path" : "Sources/MyPackage",
              "product_dependencies" : [
                "Algorithms"
              ],
              "product_memberships" : [
                "MyPackage",
                "FeaturesContainer"
              ],
              "sources" : [
                "MyPackage.swift"
              ],
              "type" : "library"
            }
          ],
          "tools_version" : "5.8"
        }
        """
        
        let (dependencies, targetDependencies) = try extracPackageModules(from: rawPackage, target: "FeaturesContainer")
        
        XCTAssertEqual(dependencies.map(\.name).sorted(), ["Algorithms", "MyPackage"])
        XCTAssertEqual(targetDependencies.sorted(), ["MyPackage"])
    }
}
