//
//  FromUIKit.swift
//  UIKitSwiftView
//
//  Created by Romain Roche on 16/09/2024.
//

import SwiftUI
import UIKit

public struct FromUIKit<V: UIView>: UIViewRepresentable {
    
    @State
    private var view: V
    
    private let coordinator: UIKitCoordinator
    
    public init(
        with view: @autoclosure @escaping () -> V,
        _ setup: @MainActor @escaping (V) -> Void
    ) {
        self.view = view()
        self.coordinator = .init(setup: setup)
    }
    
    public init(
        _ typeOf: V.Type,
        _ setup: @MainActor @escaping (V) -> Void
    ) {
        self.view = .init(frame: .zero)
        self.coordinator = .init(setup: setup)
    }
    
    public func makeCoordinator() -> UIKitCoordinator {
        self.coordinator
    }
    
    public func makeUIView(context: Context) -> V {
        return view
    }
    
    public func updateUIView(_ uiView: V, context: Context) {
        self.coordinator.setup(view)
    }
    
    @available(iOS 16, *)
    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: V,
        context: Context
    ) -> CGSize? {
        let proposal = proposal.replacingUnspecifiedDimensions(
            by: uiView.intrinsicContentSize
        )
        return view.systemLayoutSizeFitting(
            CGSize(width: proposal.width, height: proposal.height)
        )
    }
    
    public class UIKitCoordinator {
        
        internal var setup: (V) -> Void
        
        init(setup: @escaping (V) -> Void) {
            self.setup = setup
        }
        
    }
    
}

#Preview {
    FromUIKit(UILabel.self) { label in
        label.text = "Hello UIKit"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .red
        label.backgroundColor = .orange
    }
    .background(Color.blue)
}

@available(iOS 17, *)
#Preview {
    @Previewable @State var imageName = "rectangle.and.pencil.and.ellipsis.rtl"
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        imageName = "pencil.tip.crop.circle.badge.minus.fill"
    }
    
    return FromUIKit(UIImageView.self) { image in
        image.image = .init(systemName: imageName)
        image.backgroundColor = .clear
        image.tintColor = .red
    }
    .background(Color.gray)
}
