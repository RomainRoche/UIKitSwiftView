//
//  UIKitSwiftView.swift
//  tit
//
//  Created by Romain Roche on 06/05/2024.
//  Copyright © 2024 Romain Roche. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

public final class UIKitSwiftView: UIView {

    private let host: UIHostingController<AnyView>
    
    private lazy var setup: Void = {
        host.loadViewIfNeeded()
        addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.topAnchor
            .constraint(equalTo: topAnchor)
            .isActive = true
        host.view.leadingAnchor
            .constraint(equalTo: leadingAnchor)
            .isActive = true
        bottomAnchor
            .constraint(equalTo: host.view.bottomAnchor)
            .isActive = true
        trailingAnchor
            .constraint(equalTo: host.view.trailingAnchor)
            .isActive = true
    }()
    
    private var cancels = Set<AnyCancellable>()
    
    private let builder: () -> AnyView
    
    public override var backgroundColor: UIColor? {
        didSet {
            host.view.backgroundColor = backgroundColor
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        host.view.intrinsicContentSize
    }
    
    public init(
        observing observable: some ObservableObject = VoidObservable(),
        builder: @escaping () -> some View
    ) {
        self.builder = { AnyView(builder()) }
        self.host = UIHostingController(rootView: self.builder())
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        observable.objectWillChange.sink { [weak self] _ in
            self?.setNeedsLayout()
        }.store(in: &cancels)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    deinit {
        cancels.forEach { $0.cancel() }
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            _ = setup
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        host.rootView = builder()
    }

}

public final class VoidObservable: ObservableObject {
    public init() {}
}

