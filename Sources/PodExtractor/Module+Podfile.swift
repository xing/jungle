import Yams
import DependencyModule
import Foundation

public enum PodError: Error {
    case yamlParsingFailed
    case missingPodsDictionary
    case missingSpecReposDictionary
    case failedParsingPod
    case failedParsingPodName
    case podTargetNotFound
}

public struct Target: Decodable {
    let name: String
    let dependencies: [String]
}

struct Podfile: Decodable {
    let sources: [String]
    let targetDefinitions: [TargetDefinition]
    
    struct TargetDefinition: Decodable {
        let abstract: Bool
        let name: String
        let children: [ChildrenDefinition]
    }
    
    struct ChildrenDefinition: Decodable {
        let name: String
        let dependencies: [Dependency]
        struct Dependency: Decodable {
            let name: String?
            
            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let name = try? container.decode(String.self) {
                    self.name = name
                } else if let keyName = try? container.decode([String: [String]].self).keys.first {
                    self.name = keyName
                    
                } else if let keyName = try? container.decode([String: [[String: String]]].self).keys.first {
                    self.name = keyName
                } else {
                    self.name = nil
                }
            }
       
        }
    }
}

public func extractTargetsFromPodfile(_ contents: String) throws -> [Target] {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    
    guard let data = contents.data(using: .utf8),
            let pod = try? decoder.decode(Podfile.self, from: data)
    else {
        throw PodError.failedParsingPod
    }
    //first target is always Pods
    guard let targetsRaw = pod.targetDefinitions.first?.children
    else {
        throw PodError.podTargetNotFound
    }
    return targetsRaw.map { Target(name: $0.name, dependencies: $0.dependencies.compactMap(\.name)) }
}

public func extractModulesFromPodfile(_ contents: String) throws -> [Module] {
    // parse YAML to JSON
    guard let yaml = try? Yams.load(yaml: contents) else {
        throw PodError.yamlParsingFailed
    }

    // parse JSON "PODS" to [Pod]
    guard let podsDictionary = yaml as? [String: Any],
          let rawPods = podsDictionary["PODS"] as? [Any]
    else {
        throw PodError.missingPodsDictionary
    }

    // parse JSON "SPEC REPOS" to [String]
    let externalsDictionary = podsDictionary["SPEC REPOS"] as? [AnyHashable: Any]
    let externals = externalsDictionary?.values.first as? [String] ?? []


    let pods = try rawPods.map(extractPodFromJSON)

    // Exclude Test and External Pods
    let podsWithoutExternalsOrSubspecs = pods
        .filter { !externals.contains($0.name) }
        .filter { !$0.name.contains("/") } // SubSpecs like Tests and Externals Subspecs

    return podsWithoutExternalsOrSubspecs
}

private func extractPodFromJSON(_ json: Any) throws -> Module {
    if let name = json as? String {
        return try .init(name: clean(name), dependencies: [])

    } else if let container = json as? [String: [String]],
              let name = container.keys.first,
              let dependencies = container.values.first {

        return try .init(
            name: clean(name),
            dependencies: dependencies.map(clean)
        )

    } else {
        throw PodError.failedParsingPod
    }
}

private func clean(_ name: String) throws -> String {
    guard let cleanName = name.split(separator: " ").first else {
        throw PodError.failedParsingPodName
    }
    return String(cleanName)
}


