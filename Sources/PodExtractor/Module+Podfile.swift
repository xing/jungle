import Yams
import DependencyModule

public enum PodError: Error {
    case yamlParsingFailed
    case missingPodsDictionary
    case missingTargetDefinition
    case missingTargetName
    case missingSpecReposDictionary
    case failedParsingPod
    case failedParsingPodName
}
 
public func extractDependencies(for target: String, _ contents: String) throws -> [String] {
    // parse YAML to JSON
    guard let yaml = try? Yams.load(yaml: contents) as? [String: Any] else {
        throw PodError.yamlParsingFailed
    }

    guard let target_definitions = yaml["target_definitions"] as? [[String: Any]],
          let children = target_definitions.first?["children"] as? [[String: Any]]
    else {
        throw PodError.missingTargetDefinition
    }

    // Find the children with same target name
    let filtered = children.filter { $0["name"] as? String == target }

    // get the plain list of dependencies for that target
    guard let target = filtered.first,
          let rawPods = target["dependencies"] as? [Any]
    else { throw PodError.missingTargetName }
    
    return try rawPods.map(extractPodNameFromJSON)
}

private func extractPodNameFromJSON(_ json: Any) throws -> String {
    if let name = json as? String {
        return name

    } else if let container = json as? [String: [Any]],
              let name = container.keys.first {
        return name
    } else {
        throw PodError.failedParsingPod
    }
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


