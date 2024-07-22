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

/// The `UIKitSwiftView` allows to wrap `SwiftUI` components as a `UIKit` subview.
public final class UIKitSwiftView: UIView {

    /// The host view controller.
    private let host: UIHostingController<AnyView>
    /// Cancellable object array.
    private var cancels = Set<AnyCancellable>()
    /// The view builder closure. 
    private let builder: () -> AnyView
    /// Need to re call builder
    @MainActor private var shouldBuild = true {
        didSet {
            if shouldBuild {
                self.setNeedsLayout()
            }
        }
    }
    
    /// Setup the host view controller's view and its constraints.
    /// - Note: This is done as a lazy var getter so it is done only once
    /// in the view's lifecycle.
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
    
    public override var backgroundColor: UIColor? {
        didSet {
            host.view.backgroundColor = backgroundColor
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        host.view.intrinsicContentSize
    }
    
    /// Init the view.
    /// - Parameter observable: The `ObservableObject` to observe to relayout the view when needed. Optional.
    /// - Parameter builder: The view builder closure.
    public init(
        observing observable: some ObservableObject = VoidObservable(),
        @ViewBuilder builder: @escaping () -> some View
    ) {
        self.builder = { AnyView(builder()) }
        self.host = UIHostingController(rootView: self.builder())
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        observable.objectWillChange.sink { [weak self] _ in
            self?.shouldBuild = true
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
        if shouldBuild {
            host.rootView = builder()
        }
        shouldBuild = false
    }

}

public final class VoidObservable: ObservableObject {
    public init() {}
}

