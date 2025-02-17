import UIKit
import Domain

import Core
import DesignSystem

import RxSwift
import RxCocoa

public final class FavoritesViewController: UIViewController {
    private let viewModel: FavoritesViewModel
    
    private let disposeBag = DisposeBag()
    private let headerTapEvent = PublishSubject<Int>()
    private let alarmBtnTapEvent = PublishSubject<IndexPath>()
    private let isTableViewEditMode = BehaviorSubject(value: false)
    
    private var dataSource: FavoritesDataSource!
    private var snapshot: FavoritesSnapshot!
    private var headerInfoList: [[String: String]] = []
    
    private let busIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.bus.image
        return imageView
    }()
    
    private let searchBtn = SearchBusStopBtn(
        title: "버스 정류장을 검색하세요",
        image: UIImage(systemName: "magnifyingglass")
    )
    
    private let refreshBtn: UIButton = {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .black
        config.imagePadding = 5
        // Image
        let image = UIImage(systemName: "arrow.triangle.2.circlepath")
        let imgConfig = UIImage.SymbolConfiguration(
            font: .systemFont(ofSize: 13)
        )
        config.image = image
        config.preferredSymbolConfigurationForImage = imgConfig
        // Title
        var titleContainer = AttributeContainer()
        titleContainer.font = .systemFont(ofSize: 12)
        let timeStr = Date().toString(dateFormat: "HH:mm")
        config.attributedTitle = AttributedString(
            "\(timeStr) 업데이트",
            attributes: titleContainer
        )
        let button = UIButton(configuration: config)
        return button
    }()
    
    private let editBtn: UIButton = {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .black
        config.imagePadding = 5
        var titleContainer = AttributeContainer()
        titleContainer.font = .systemFont(ofSize: 13)
        config.attributedTitle = AttributedString(
            "편집",
            attributes: titleContainer
        )
        let button = UIButton(configuration: config)
        button.isHidden = true
        return button
    }()
    
    private lazy var favoritesTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.register(FavoritesHeaderView.self)
        tableView.register(FavoritesTVCell.self)
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.sectionHeaderTopPadding = .zero
        return tableView
    }()
    
    public init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        configureUI()
        bind()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        
        [
            busIconView,
            searchBtn,
            editBtn,
            refreshBtn,
            favoritesTableView
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            busIconView.topAnchor.constraint(
                equalTo: safeArea.topAnchor,
                constant: 10
            ),
            busIconView.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor,
                constant: .screenWidth * 0.07
            ),
            
            searchBtn.topAnchor.constraint(
                equalTo: busIconView.bottomAnchor,
                constant: -10
            ),
            searchBtn.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            searchBtn.widthAnchor.constraint(
                equalTo: safeArea.widthAnchor,
                multiplier: 0.95
            ),
            
            refreshBtn.topAnchor.constraint(
                equalTo: searchBtn.bottomAnchor,
                constant: 10
            ),
            refreshBtn.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor,
                constant: 15
            ),
            
            editBtn.topAnchor.constraint(
                equalTo: searchBtn.bottomAnchor,
                constant: 10
            ),
            editBtn.trailingAnchor.constraint(
                equalTo: safeArea.trailingAnchor,
                constant: -20
            ),
            
            favoritesTableView.topAnchor.constraint(
                equalTo: refreshBtn.bottomAnchor
            ),
            favoritesTableView.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor,
                constant: 10
            ),
            favoritesTableView.trailingAnchor.constraint(
                equalTo: safeArea.trailingAnchor,
                constant: -10
            ),
            favoritesTableView.bottomAnchor.constraint(
                equalTo: safeArea.bottomAnchor
            ),
        ])
    }
    
    private func bind() {
        let output = viewModel.transform(
            input: .init(
                viewWillAppearEvent: rx
                    .methodInvoked(
                        #selector(UIViewController.viewWillAppear)
                    )
                    .map { _ in },
                searchBtnTapEvent: searchBtn.rx.tap.asObservable(),
                refreshBtnTapEvent: refreshBtn.rx.tap.asObservable(),
                alarmBtnTapEvent: alarmBtnTapEvent.asObservable(),
                busStopTapEvent: headerTapEvent
            )
        )
        
        Observable.combineLatest(
            output.distanceFromTimerStart,
            output.busStopArrivalInfoResponse
        )
        .withUnretained(self)
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(
            onNext: { viewController, arg1 in
                let (timerTime, responses) = arg1
                let newResponses = responses.map {
                    return BusStopArrivalInfoResponse(
                        busStopId: $0.busStopId,
                        busStopName: $0.busStopName,
                        direction: $0.direction,
                        buses: $0.buses.map { busInfo in
                            let newFirstArrivalState: ArrivalState
                            let newSecondArrivalState: ArrivalState
                            switch busInfo.firstArrivalState {
                            case .soon, .pending, .finished:
                                newFirstArrivalState = busInfo.firstArrivalState
                            case .arrivalTime(let time):
                                newFirstArrivalState = time - timerTime > 60 ?
                                    .arrivalTime(time: time - timerTime):
                                    .soon
                            }
                            switch busInfo.secondArrivalState {
                            case .soon, .pending, .finished:
                                newSecondArrivalState 
                                = busInfo.secondArrivalState
                            case .arrivalTime(let time):
                                newSecondArrivalState = time - timerTime > 60 ?
                                    .arrivalTime(time: time - timerTime):
                                    .soon
                            }
                            let firstReaining = busInfo.firstArrivalRemaining
                            let secondReaining = busInfo.secondArrivalRemaining
                            return BusArrivalInfoResponse(
                                busId: busInfo.busId,
                                busName: busInfo.busName,
                                busType: busInfo.busType.rawValue,
                                nextStation: busInfo.nextStation,
                                firstArrivalState: newFirstArrivalState,
                                firstArrivalRemaining: firstReaining,
                                secondArrivalState: newSecondArrivalState,
                                secondArrivalRemaining: secondReaining,
                                isFavorites: busInfo.isFavorites,
                                isAlarmOn: busInfo.isAlarmOn
                            )
                        }
                    )
                }
                newResponses.forEach { response in
                    viewController.updateHeaderInfo(
                        name: response.busStopName,
                        direction: response.direction
                    )
                    let header = viewController.favoritesTableView
                        .tableHeaderView as? FavoritesHeaderView
                    header?.updateUI(
                        name: response.busStopName,
                        direction: response.direction
                    )
                }
                viewController.updateSnapshot(busStopResponse: newResponses)
            }
        )
        .disposed(by: disposeBag)
        
        output.favoritesState
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(
                onNext: { viewController, state in
                    viewController.updateState(state: state)
                    let timeStr = Date().toString(dateFormat: "HH:mm")
                    viewController.refreshBtn.setTitle(
                        "\(timeStr) 업데이트",
                        for: .normal
                    )
                }
            )
            .disposed(by: disposeBag)
        
        editBtn.rx.tap
            .asObservable()
            .withUnretained(self)
            .subscribe(
                onNext: { viewController, _ in
                    guard let isEditMode = try? viewController
                        .isTableViewEditMode.value()
                    else { return }
                    viewController.isTableViewEditMode
                        .onNext(!isEditMode)
                }
            )
            .disposed(by: disposeBag)
        
//        isTableViewEditMode
//            .withUnretained(self)
//            .subscribe(
//                onNext: { viewController, isEditMode in
//                    viewController.editBtn.setTitle(
//                        isEditMode ? "완료" : "편집",
//                        for: .normal
//                    )
//                    viewController.favoritesTableView.isEditing = isEditMode
//                }
//            )
//            .disposed(by: disposeBag)
    }
    
    private func configureDataSource() {
        dataSource = .init(
            tableView: favoritesTableView
        ) { [weak self] tableView, indexPath, response in
            guard let self else { return UITableViewCell() }
            let cell = self.configureCell(
                tableView: tableView,
                indexPath: indexPath,
                response: response
            )
            cell?.selectionStyle = .none
            cell?.alarmBtn.rx.tap
                .map { _ in indexPath }
                .bind(to: self.alarmBtnTapEvent)
                .disposed(by: self.disposeBag)
            return cell
        }
    }
    
    private func configureCell(
        tableView: UITableView,
        indexPath: IndexPath,
        response: BusArrivalInfoResponse
    ) -> FavoritesTVCell? {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FavoritesTVCell.identifier,
            for: indexPath
        ) as? FavoritesTVCell
        let isLastCell = tableView.numberOfRows(
            inSection: indexPath.section
        ) - 1 == indexPath.row
        if isLastCell {
            cell?.addCornerRadius(
                corners: [.bottomLeft, .bottomRight]
            )
        }
        let firstArrivalTime = response.firstArrivalState.toString
        let secondArrivalTime = response.secondArrivalState.toString
        cell?.updateUI(
            busName: response.busName, 
            busType: response.busType,
            firstArrivalTime: firstArrivalTime,
            firstArrivalRemaining: response.firstArrivalRemaining,
            secondArrivalTime: secondArrivalTime,
            secondArrivalRemaining: response.secondArrivalRemaining
        )
        return cell
    }
    
    private func updateHeaderInfo(
        name: String,
        direction: String
    ) {
        headerInfoList += [
            [
                "name": name,
                "direction": direction
            ]
        ]
    }
    
    private func updateSnapshot(busStopResponse: [BusStopArrivalInfoResponse]) {
        snapshot = .init()
        snapshot.appendSections(busStopResponse)
        busStopResponse.forEach { response in
            snapshot.appendItems(
                response.buses, 
                toSection: response
            )
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func updateState(state: FavoritesViewModel.FavoritesState) {
        switch state {
        case .emptyFavorites:
            favoritesTableView.backgroundView = EmptyFavoritesView()
            refreshBtn.isHidden = true
//            editBtn.isHidden = true
        case .fetching:
            favoritesTableView.loadingBackground()
            refreshBtn.isHidden = false
//            editBtn.isHidden = false
        case .fetchComplete:
            favoritesTableView.backgroundView = nil
        }
    }
}

extension FavoritesViewController: UITableViewDelegate {
    public func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        60
    }
    
    public func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        60
    }
    
    public func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: FavoritesHeaderView.identifier
        ) as? FavoritesHeaderView
        if section < headerInfoList.count {
            header?.updateUI(
                name: headerInfoList[section]["name"],
                direction: headerInfoList[section]["direction"]
            )
        }
        let tapGesture = UITapGestureRecognizer()
        header?.contentView.addGestureRecognizer(tapGesture)
        tapGesture.rx.event
            .map { _ in section }
            .bind(to: headerTapEvent)
            .disposed(by: disposeBag)
        return header
    }
}

extension FavoritesViewController {
    typealias FavoritesDataSource =
    UITableViewDiffableDataSource
    <BusStopArrivalInfoResponse, BusArrivalInfoResponse>
    
    typealias FavoritesSnapshot =
    NSDiffableDataSourceSnapshot
    <BusStopArrivalInfoResponse, BusArrivalInfoResponse>
}
