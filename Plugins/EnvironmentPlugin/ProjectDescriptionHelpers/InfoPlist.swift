//
//  InfoPlist.swift
//  AppStore
//
//  Created by gnksbm on 2023/11/19.
//  Copyright © 2023 https://github.com/gnksbm/Clone_AppStore. All rights reserved.
//

import ProjectDescription

public extension InfoPlist {
    static let appInfoPlist: Self = .extendingDefault(
        with: .baseInfoPlist
            .merging(.additionalInfoPlist) { oldValue, newValue in
                newValue
            }
            .merging(.secrets) { oldValue, newValue in
                newValue
            }
    )
    
    static func demoAppInfoPlist(name: String) -> Self {
        .extendingDefault(
            with: .baseInfoPlist
                .merging(.additionalInfoPlist) { oldValue, newValue in
                    newValue
                }
                .merging(.secrets) { oldValue, newValue in
                    newValue
                }
                .merging([
                    "CFBundleDisplayName": "\(name)"
                ]) { oldValue, newValue in
                    newValue
                }
        )
    }
    
    static let frameworkInfoPlist: Self = .extendingDefault(
        with: .framework
            .merging(.secrets) { oldValue, newValue in
                newValue
            }
    )
    
    static let notificationInfoPlist: Self = .extendingDefault(
        with: .framework
            .merging(.secrets) { oldValue, newValue in
                newValue
            }
            .merging([
                "NSExtension": [
                    "NSExtensionPointIdentifier": "com.apple.usernotifications.service",
                    "NSExtensionPrincipalClass": "$(PRODUCT_MODULE_NAME).NotificationService"
                ]
            ]) { oldValue, newValue in
                newValue
            }
    )
}

public extension [String: Plist.Value] {
    static let secrets: Self = [
        "SERVER_KEY": "$(SERVER_KEY)",
        "KAKAO_APP_KEY": "$(KAKAO_APP_KEY)",
        "KAKAO_PHASE": "alpha",
    ]
    
    static let additionalInfoPlist: Self = [
        "ITSAppUsesNonExemptEncryption": "NO",
        "NSAppTransportSecurity": [
            "NSExceptionDomains": [
                "ws.bus.go.kr": [
                    "NSIncludesSubdomains": true,
                    "NSExceptionAllowsInsecureHTTPLoads": true,
                ]
            ]
        ],
        "UIBackgroundModes": [
            "fetch",
            "processing",
            "remote-notification"
        ],
        "BGTaskSchedulerPermittedIdentifiers" : [.string(.bundleID)]
    ]
    
    static let baseInfoPlist: Self = [
        "CFBundleDisplayName": .bundleDisplayName,
        "CFBundleShortVersionString": .bundleShortVersionString,
        "CFBundleVersion": .bundleVersion,
        "UILaunchStoryboardName": "LaunchScreen.storyboard",
        "UIApplicationSceneManifest": [
            "UIApplicationSupportsMultipleScenes": false,
            "UISceneConfigurations": [
                "UIWindowSceneSessionRoleApplication": [
                    [
                        "UISceneConfigurationName": "Default Configuration",
                        "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                    ],
                ]
            ]
        ],
    ]
    
    static let framework: Self = [
        "CFBundleDevelopmentRegion": "$(DEVELOPMENT_LANGUAGE)",
        "CFBundleExecutable": "$(EXECUTABLE_NAME)",
        "CFBundleIdentifier": "$(PRODUCT_BUNDLE_IDENTIFIER)",
        "CFBundleInfoDictionaryVersion": "6.0",
        "CFBundleName": "$(PRODUCT_NAME)",
        "CFBundlePackageType": "FMWK",
        "CFBundleShortVersionString": "1.0",
        "CFBundleVersion": "1",
    ]
}
