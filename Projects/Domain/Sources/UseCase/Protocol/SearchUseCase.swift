//
//  SearchUseCase.swift
//  Domain
//
//  Created by 유하은 on 2024/03/07.
//  Copyright © 2024 Pepsi-Club. All rights reserved.
//

import Foundation

import RxSwift

public protocol SearchUseCase {
    func getStationList()
    func getRecentSearchList()
    
    var recentSearchResult: BehaviorSubject<[BusStopInfoResponse]> {get}
    var jsontoSearchData: PublishSubject<[BusStopInfoResponse]> {get}
}
