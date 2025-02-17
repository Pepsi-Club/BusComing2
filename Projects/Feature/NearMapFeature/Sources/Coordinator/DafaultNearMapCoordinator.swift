import UIKit

import FeatureDependency

import RxSwift
import KakaoMapsSDK

public final class DefaultNearMapCoordinator: NearMapCoordinator {
    public var parent: Coordinator?
    public var childs: [Coordinator] = []
    public var navigationController: UINavigationController
    public var coordinatorProvider: CoordinatorProvider
    public let flow: FlowState
    
    private let disposeBag = DisposeBag()
    
    public init(
        parent: Coordinator?,
        navigationController: UINavigationController,
        coordinatorProvider: CoordinatorProvider,
        flow: FlowState
    ) {
        self.parent = parent
        self.navigationController = navigationController
        self.coordinatorProvider = coordinatorProvider
        self.flow = flow

    }
	
	// MARK: - Function
    
    public func start() {
        let nearmapViewController = NearMapViewController(
            viewModel: NearMapViewModel(coordinator: self)
        )
        navigationController.pushViewController(
            nearmapViewController,
            animated: true
        )
    }
}

extension DefaultNearMapCoordinator {
    public func startBusStopFlow(busStopId: String) {
        let busStopCoordinator = coordinatorProvider.makeBusStopCoordinator(
            navigationController: navigationController,
            busStopId: busStopId,
            flow: flow
        )
        childs.append(busStopCoordinator)
        busStopCoordinator.start()
    }
	
}
