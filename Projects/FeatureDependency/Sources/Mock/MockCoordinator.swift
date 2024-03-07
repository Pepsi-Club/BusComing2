//
//  MockCoordinator.swift
//  FeatureDependency
//
//  Created by gnksbm on 3/1/24.
//  Copyright © 2024 Pepsi-Club. All rights reserved.
//

import UIKit

import Domain

#if DEBUG
public final class MockCoordinator: Coordinator {
    public var parent: Coordinator?
    public var childs: [Coordinator] = []
    
    private let testMessage: String
    public var navigationController: UINavigationController
    
    public init(
        testMessage: String,
        navigationController: UINavigationController
    ) {
        self.testMessage = testMessage
        self.navigationController = navigationController
    }
    
    public func start() {
        let testViewController = UIViewController()
        testViewController.view.backgroundColor = .white
        testViewController.title = testMessage
        navigationController.pushViewController(
            testViewController,
            animated: true
        )
    }
}

extension MockCoordinator: SearchCoordinator {
    
}

extension MockCoordinator: BusStopCoordinator {
    public func busStopMapLocation() {
        let coordinator = MockCoordinator(
            testMessage: "Map",
            navigationController: navigationController
        )
        coordinator.start()
        childs.append(coordinator)
    }
}

extension MockCoordinator: AddRegularAlarmCoordinator {
    public func start(with: RegularAlarmResponse) {
        
    }
    
    public func startSearchFlow() {
        
    }
    
    public func complete() {
        
    }
}
#endif