//
//  CoordinatorProvider.swift
//  FeatureDependency
//
//  Created by gnksbm on 1/26/24.
//  Copyright © 2024 Pepsi-Club. All rights reserved.
//

import UIKit

import Domain

public protocol CoordinatorProvider {
    func makeSearchCoordinator(
        navigationController: UINavigationController
    ) -> SearchCoordinator
    
    func makeBusStopCoordinator(
        navigationController: UINavigationController,
        arrivalInfoData: ArrivalInfoRequest
    ) -> BusStopCoordinator

    func makeAddRegularAlarmCoordinator(
        navigationController: UINavigationController
    ) -> AddRegularAlarmCoordinator
}