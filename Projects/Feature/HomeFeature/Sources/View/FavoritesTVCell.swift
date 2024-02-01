//
//  FavoritesTVCell.swift
//  HomeFeature
//
//  Created by gnksbm on 1/23/24.
//  Copyright © 2024 Pepsi-Club. All rights reserved.
//

import UIKit

import Core
import DesignSystem

class FavoritesTVCell: UITableViewCell {
    private let routeLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.NanumSquareNeoOTF.extraBold.font(
            size: 22
        )
        label.textColor = DesignSystemAsset.limeGreen.color
        return label
    }()
    
    private let firstArrivalInfoView = ArrivalInfoView()
    private let secondArrivalInfoView = ArrivalInfoView()
    
    let alarmBtn: UIButton = {
        var config = UIButton.Configuration.plain()
        let image = UIImage(systemName: "deskclock")
        let imgConfig = UIImage.SymbolConfiguration(
            font: .systemFont(ofSize: 13)
        )
        config.image = image
        config.preferredSymbolConfigurationForImage = imgConfig
        config.baseForegroundColor = DesignSystemAsset.mainColor.color
        let button = UIButton(configuration: config)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        let mainColor = DesignSystemAsset.mainColor.color
        alarmBtn.configuration?.baseForegroundColor = mainColor
        [routeLabel].forEach {
            $0.text = nil
        }
    }
    
    func updateUI(
        routeName: String,
        firstArrivalTime: String,
        firstArrivalRemaining: String,
        secondArrivalTime: String,
        secondArrivalRemaining: String
    ) {
        routeLabel.text = routeName
        firstArrivalInfoView.updateUI(
            time: firstArrivalTime, remainingStops: firstArrivalRemaining
        )
        secondArrivalInfoView.updateUI(
            time: secondArrivalTime, remainingStops: secondArrivalRemaining
        )
    }
    
    private func configureUI() {
        contentView.backgroundColor = DesignSystemAsset.gray1.color
        
        [
            routeLabel,
            firstArrivalInfoView,
            secondArrivalInfoView,
            alarmBtn
        ].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ).isActive = true
        }
        
        NSLayoutConstraint.activate([
            routeLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),
            
            alarmBtn.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -15
            ),
            
            secondArrivalInfoView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: .screenWidth * -0.35
            ),
            
            firstArrivalInfoView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: .screenWidth * -0.6
            ),
        ])
    }
}