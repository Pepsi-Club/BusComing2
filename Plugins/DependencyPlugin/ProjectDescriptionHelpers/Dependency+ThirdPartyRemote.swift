//
//  ThirdPartyLibs.swift
//  Environment
//
//  Created by gnksbm on 2023/11/19.
//

import ProjectDescription

public extension Array<Package> {
    struct ThirdPartyRemote {
    }
}

public extension Array<Package>.ThirdPartyRemote {
    enum SPM: CaseIterable {
        case rxSwift, swiftyXMLParser
        
        public var url: String {
            switch self {
            case .rxSwift:
                return "https://github.com/ReactiveX/RxSwift"
            case .swiftyXMLParser:
                return "https://github.com/yahoojapan/SwiftyXMLParser"
            }
        }
        
        public var upToNextMajor: Version {
            switch self {
            case .rxSwift:
                return "6.0.0"
            case .swiftyXMLParser:
                return "5.6.0"
            }
        }
    }
}
