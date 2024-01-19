//
//  Dependency+Module.swift
//  Environment
//
//  Created by gnksbm on 2023/11/19.
//

import ProjectDescription

public extension TargetDependency {
    static let app: Self = .module(name: "App")
    static let mainPresentation: Self = .module(name: "MainPresentation")
    static let feature: Self = .moduleWithAdditionalPath(
        name: "Feature",
        path: "Presentation"
    )
    static let presentationDependency: Self = .module(name: "PresentationDependency")
    static let core: Self = .module(name: "Core")
    static let data: Self = .module(name: "Data")
    static let domain: Self = .module(name: "Domain")
    static let networks: Self = .module(name: "Networks")
    static let designSystem: Self = .module(name: "DesignSystem")
    static let thirdPartyLibs: Self = .module(name: "ThirdPartyLibs")
    
    private static func module(name: String) -> Self {
        .project(target: name, path: .relativeToRoot("Projects/\(name)"))
    }
    private static func moduleWithAdditionalPath(name: String, path: String) -> Self {
        .project(target: name, path: .relativeToRoot("Projects/\(path)/\(name)"))
    }
}
