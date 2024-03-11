//
//  DefaultAfterSearchCoordinator.swift
//  SearchFeature
//
//  Created by 유하은 on 2024/03/07.
//  Copyright © 2024 Pepsi-Club. All rights reserved.
//

import UIKit

import Domain
import FeatureDependency

public final class DefaultAfterSearchCoordinator: AfterSearchCoordinator {
    
    public var parent: Coordinator?
    public var childs: [Coordinator] = []
    public var navigationController: UINavigationController
    public let coordinatorProvider: CoordinatorProvider
    
    private let busStopId: String
    
    public init(
        parent: Coordinator?,
        navigationController: UINavigationController,
        coordinatorProvider: CoordinatorProvider,
        busStopId: String
    ) {
        self.navigationController = navigationController
        self.parent = parent
        self.coordinatorProvider = coordinatorProvider
        self.busStopId = busStopId
    }
    
    public func start() {
//        let afterSearchViewController = AfterSearchCoordinator(
//            viewModel: AfterSearchCoordinator(coordinator: self)
//        )
    }
    
    public func finish() {
        
    }
    
    public func startBusStopFlow() {
        let busStopCoordinator =
        coordinatorProvider.makeBusStopCoordinator(
            navigationController: navigationController,
            busStopId: busStopId
        )
        
        childs.append(busStopCoordinator)
        busStopCoordinator.start()
    }
}
