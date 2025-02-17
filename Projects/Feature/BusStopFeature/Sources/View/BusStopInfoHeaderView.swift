//
//  BusStopInfoHeaderView.swift
//  BusStopFeatureDemo
//
//  Created by Jisoo HAM on 2/1/24.
//  Copyright © 2024 Pepsi-Club. All rights reserved.
//

import UIKit

import DesignSystem

public final class BusStopInfoHeaderView: UIView {
    
    private let totalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 7
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    public let navigationBtn: UIButton = {
        var config = UIButton.Configuration.plain()
        
        config.image = UIImage(systemName: "chevron.left")
        config.baseForegroundColor = .white
        config.imagePadding = 7
        var imgConfig = UIImage.SymbolConfiguration(
            font: .systemFont(ofSize: 17)
        )
        imgConfig = UIImage.SymbolConfiguration(weight: .semibold)
        config.preferredSymbolConfigurationForImage = imgConfig
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let busIconStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .center
        stack.spacing = -2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let btnStack: UIStackView = {
        let stack = UIStackView()
        stack.backgroundColor = DesignSystemAsset.headerBlue.color
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let busStopNumLb: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DesignSystemFontFamily.NanumSquareNeoOTF
            .regular.font(size: 15)
        label.textColor = .white
        return label
    }()
    
    private let busStopNameLb: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DesignSystemFontFamily.NanumSquareNeoOTF
            .extraBold.font(size: 18)
        label.textColor = .white
        return label
    }()
    
    private let nextStopNameLb: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DesignSystemFontFamily.NanumSquareNeoOTF
            .regular.font(size: 14)
        label.textColor = .white
        return label
    }()
    
    public let mapBtn: UIButton = {
        var config = UIButton.Configuration.filled()
        
        config.image = UIImage(systemName: "map")
        
        var title = AttributedString.init(stringLiteral: "지도")
        title.font = DesignSystemFontFamily.NanumSquareNeoOTF
            .regular.font(size: 10)
        config.attributedTitle = title
        config.baseBackgroundColor = .white
        config.baseForegroundColor = DesignSystemAsset.favoritesOrange.color
        config.imagePadding = 7
        let imgConfig = UIImage.SymbolConfiguration(
            font: .systemFont(ofSize: 11)
        )
        config.preferredSymbolConfigurationForImage = imgConfig
        config.cornerStyle = .capsule
        let btn = UIButton(configuration: config)
        return btn
    }()
    
    private let busStopIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.busStop.image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = DesignSystemAsset.headerBlue.color
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func bindUI(
        routeId: String?,
        busStopName: String,
        nextStopName: String
    ) {
            busStopNumLb.text = routeId
            busStopNameLb.text = busStopName
            nextStopNameLb.text = nextStopName
    }
}

extension BusStopInfoHeaderView {
    private func configureUI() {
        configureSetup()
        configureLayouts()
    }
    
    private func configureSetup() {
        addSubview(totalStack)
        addSubview(btnStack)
        addSubview(navigationBtn)
        
        [busStopIcon, busStopNumLb]
            .forEach { components in
                busIconStack.addArrangedSubview(components)
            }
        
        [busIconStack, busStopNameLb, nextStopNameLb]
            .forEach { components in
                totalStack.addArrangedSubview(components)
            }
        
        [mapBtn]
            .forEach { components in
                btnStack.addArrangedSubview(components)
            }
    }
    
    private func configureLayouts() {
        
        NSLayoutConstraint.activate([
            navigationBtn.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 60
            ),
            navigationBtn.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 15
            ),
            totalStack.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            totalStack.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            totalStack.topAnchor.constraint(
                equalTo: navigationBtn.bottomAnchor,
                constant: -50
            ),
            btnStack.topAnchor.constraint(
                equalTo: totalStack.bottomAnchor,
                constant: 15
            ),
            btnStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            btnStack.bottomAnchor.constraint(
                equalTo: bottomAnchor, constant: -15
            )
        ])
    }
}
