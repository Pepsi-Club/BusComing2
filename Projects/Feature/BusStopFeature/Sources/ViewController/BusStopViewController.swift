import UIKit

import FeatureDependency
import DesignSystem
import Domain

import RxSwift

public final class BusStopViewController: UIViewController {
    private let viewModel: BusStopViewModel
    
    private let disposeBag = DisposeBag()
    private let mapBtnTapEvent = PublishSubject<Void>()
    private let likeBusBtnTapEvent = PublishSubject<BusArrivalInfoResponse>()
    private let alarmBtnTapEvent = PublishSubject<BusArrivalInfoResponse>()
    private let alarmCellTapEvent = PublishSubject<IndexPath>()
    
    private var dataSource: BusStopDataSource!
    private var snapshot: BusStopSnapshot!
    private var flow: FlowState
    
    private let headerView: BusStopInfoHeaderView = BusStopInfoHeaderView()
    private let scrollView: UIScrollView = UIScrollView()
    private let contentView = UIView()
    private lazy var busStopTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(
            BusStopTVHeaderView.self,
            forHeaderFooterViewReuseIdentifier: BusStopTVHeaderView.identifier
        )
        table.delegate = self
        table.isScrollEnabled = false
        table.backgroundColor = .systemGray6
        return table
    }()
    
    public init(
        viewModel: BusStopViewModel,
        flow: FlowState
    ) {
        self.viewModel = viewModel
        self.flow = flow
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind()
        configureDataSource()
        tableCellTap()
    }
    
    private func bind() {
        let refreshControl = scrollView.enableRefreshControl(
            refreshStr: "당겨서 새로고침"
        )
        
        let input = BusStopViewModel.Input(
            viewWillAppearEvent: rx
                .methodInvoked(#selector(UIViewController.viewWillAppear))
                .map { _ in },
            likeBusBtnTapEvent: likeBusBtnTapEvent.asObservable(),
            alarmBtnTapEvent: alarmBtnTapEvent.asObservable(),
            mapBtnTapEvent: headerView.mapBtn.rx.tap.asObservable(),
            refreshLoading
            : refreshControl.rx.controlEvent(.valueChanged).asObservable(),
            navigationBackBtnTapEvent
            : headerView.navigationBtn.rx.tap.asObservable(),
            cellSelectTapEvent: alarmCellTapEvent.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        bindTableView(output: output)
        
        output.isRefreshing
            .subscribe(onNext: { refresh in
                print("\(refresh)")
                switch refresh {
                case .fetchComplete:
                    refreshControl.endRefreshing()
                case .fetching:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindTableView(output: BusStopViewModel.Output) {
        output.busStopArrivalInfoResponse
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(
                onNext: { viewController, response in
                    viewController.headerView.bindUI(
                        routeId: response.busStopId,
                        busStopName: response.busStopName,
                        nextStopName: response.direction
                    )
                    
                    viewController.updateSnapshot(busStopResponse: response)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func tableCellTap() {
        guard flow == .fromAlarm else { return }
        
        busStopTableView.rx.itemSelected
            .map { indexPath in
                print("\(indexPath)")
                return indexPath
            }
            .bind(to: alarmCellTapEvent)
            .disposed(by: disposeBag)
    }
    
    private func updateSnapshot(busStopResponse: BusStopArrivalInfoResponse) {
        snapshot = .init()
        for busInfo in busStopResponse.buses {
            let busTypeSection = busInfo.busType
            if !snapshot.sectionIdentifiers.contains(busTypeSection) {
                snapshot.appendSections([busTypeSection])
            }
            snapshot.appendItems([busInfo], toSection: busTypeSection)
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func configureDataSource() {
        dataSource = .init(
            tableView: busStopTableView,
            cellProvider: { [weak self] tableView, indexPath, response in
                switch self?.flow {
                case .fromHome:
                    tableView.register(
                        BusTableViewCell.self,
                        forCellReuseIdentifier: BusTableViewCell.identifier
                    )
                    guard let self = self,
                          let cell = self.configureCell(
                            tableView: tableView,
                            indexPath: indexPath,
                            response: response
                          )
                    else { return UITableViewCell() }
                    
                    return cell
                case .fromAlarm:
                    tableView.register(
                        RegularAlarmForBusTableViewCell.self,
                        forCellReuseIdentifier
                        : RegularAlarmForBusTableViewCell.identifier
                    )
                    guard let self = self,
                          let cell = self.configureAlarmCell(
                            tableView: tableView,
                            indexPath: indexPath,
                            response: response
                          )
                    else { return UITableViewCell() }
                    
                    return cell
                case .none:
                    return UITableViewCell()
                }
            }
        )
    }
    
    private func configureAlarmCell(
        tableView: UITableView,
        indexPath: IndexPath,
        response: BusArrivalInfoResponse
    ) -> RegularAlarmForBusTableViewCell? {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: RegularAlarmForBusTableViewCell.identifier,
            for: indexPath
        ) as? RegularAlarmForBusTableViewCell
        
        cell?.updateUI(
            busNumber: response.busName,
            nextStopName: response.nextStation
        )
        
        cell?.busNumberLb.textColor = response.busType.toColor
        
        return cell
    }
    
    private func configureCell(
        tableView: UITableView,
        indexPath: IndexPath,
        response: BusArrivalInfoResponse
    ) -> BusTableViewCell? {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: BusTableViewCell.identifier,
            for: indexPath
        ) as? BusTableViewCell
        
        cell?.updateBtn(
            favorite: response.isFavorites,
            alarm: response.isAlarmOn
        )
        cell?.updateBusRoute(
            routeName: response.busName,
            nextRouteName: response.nextStation
        )
        cell?.updateFirstArrival(
            firstArrivalTime: response.firstArrivalState.toString,
            firstArrivalRemaining: response.firstArrivalRemaining
        )
        cell?.updateSecondArrival(
            secondArrivalTime: response.secondArrivalState.toString,
            secondArrivalRemaining: response.secondArrivalRemaining
        )
        cell?.busNumber.textColor = response.busType.toColor
        
        cell?.selectionStyle = .none
        
        cell?.starBtnTapEvent
            .map({ _ in
                return response
            })
            .subscribe(onNext: { [weak self] busInfo in
                self?.likeBusBtnTapEvent.onNext(busInfo)
            })
            .disposed(by: cell!.disposeBag)
        
//        cell?.alarmBtnTapEvent
//            .map { _ in
//                return response
//            }
//            .bind(to: self.alarmBtnTapEvent)
//            .disposed(by: cell!.disposeBag)
        
        return cell
    }
}

extension BusStopViewController {
    public func configureUI() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        
        view.addSubview(scrollView)
        
        [scrollView, contentView, headerView, busStopTableView]
            .forEach { components in
                components.translatesAutoresizingMaskIntoConstraints = false
            }
        
        [headerView, busStopTableView]
            .forEach { components in
                contentView.addSubview(components)
            }
        
        scrollView.addSubview(contentView)
        scrollView.contentInsetAdjustmentBehavior = .never
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            headerView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            headerView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            
            busStopTableView.topAnchor.constraint(
                equalTo: headerView.bottomAnchor
            ),
            busStopTableView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            busStopTableView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            busStopTableView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            ),
            
            contentView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),
            contentView.centerXAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerXAnchor
            ),
            contentView.widthAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.widthAnchor
            ),
            contentView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            ),
            contentView.heightAnchor.constraint(
                greaterThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor
            ),
            
            scrollView.frameLayoutGuide.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
        ])
    }
}

extension BusStopViewController: UITableViewDelegate {
    public func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 60
    }
    
    public func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: BusStopTVHeaderView.identifier
        ) as? BusStopTVHeaderView else { return UIView() }
        
        let sectionIdentifier = dataSource.snapshot()
            .sectionIdentifiers[section]
        
        headerView.bind(with: sectionIdentifier.toString)
        
        return headerView
    }
}

extension BusStopViewController {
    typealias BusStopDataSource =
    UITableViewDiffableDataSource
    <BusType, BusArrivalInfoResponse>
    typealias BusStopSnapshot =
    NSDiffableDataSourceSnapshot
    <BusType, BusArrivalInfoResponse>
    
}
