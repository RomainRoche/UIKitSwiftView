//
//  FromUIKit.swift
//  UIKitSwiftView
//
//  Created by Romain Roche on 16/09/2024.
//

import SwiftUI
import UIKit

public struct FromUIKit<V: UIView>: UIViewRepresentable {
    
    @available(iOS 16, *)
    public enum SizingPolicy {
        /// Will use the system layout fitting size
        case systemLayout
        /// Will use intrinsic content size
        case intrinsic
        /// Will use the proposed size for the dimension where `true` is specified, intrinsic dimension otherwise
        case followProposal(width: Bool, height: Bool)
        /// A fully custom policy.
        case custom((_ proposal: ProposedViewSize, _ view: UIView) -> CGSize)
    }
    
    @State
    private var view: V
    
    private let coordinator: UIKitCoordinator
    
    @available(iOS 16, *)
    public init(
        with view: @autoclosure @escaping () -> V,
        sizingPolicy: SizingPolicy,
        _ setup: @MainActor @escaping (V) -> Void
    ) {
        self.view = view()
        self.coordinator = .init(withPolicy: sizingPolicy, setup: setup)
    }
    
    public init(
        with view: @autoclosure @escaping () -> V,
        _ setup: @MainActor @escaping (V) -> Void
    ) {
        self.view = view()
        if #available(iOS 16, *) {
            self.coordinator = .init(withPolicy: .systemLayout, setup: setup)
        } else {
            self.coordinator = .init(setup: setup)
        }
    }
    
    @available(iOS 16, *)
    public init(
        _ typeOf: V.Type,
        sizingPolicy: SizingPolicy,
        _ setup: @MainActor @escaping (V) -> Void
    ) {
        self.view = .init(frame: .zero)
        self.coordinator = .init(withPolicy: sizingPolicy, setup: setup)
    }
    
    public init(
        _ typeOf: V.Type,
        _ setup: @MainActor @escaping (V) -> Void
    ) {
        self.view = .init(frame: .zero)
        if #available(iOS 16, *) {
            self.coordinator = .init(withPolicy: .systemLayout, setup: setup)
        } else {
            self.coordinator = .init(setup: setup)
        }
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
    private func intrinsicSizing(for uiView: UIView) -> CGSize {
        uiView.intrinsicContentSize
    }
    
    @available(iOS 16, *)
    private func systemLayoutSizing(
        for uiView: UIView,
        proposal: ProposedViewSize,
        context: Context
    ) -> CGSize {
        let proposal = proposal.replacingUnspecifiedDimensions(
            by: uiView.intrinsicContentSize
        )
        return view.systemLayoutSizeFitting(
            CGSize(width: proposal.width, height: proposal.height)
        )
    }
    
    @available(iOS 16, *)
    private func proposalSizing(
        for uiView: UIView,
        proposal: ProposedViewSize,
        forWidth: Bool,
        forHeight: Bool
    ) -> CGSize {
        let intrinsicContentSize = uiView.intrinsicContentSize
        var proposalResult = proposal.replacingUnspecifiedDimensions(
            by: intrinsicContentSize
        )
        if !forWidth { proposalResult.width = intrinsicContentSize.width }
        if !forHeight { proposalResult.height = intrinsicContentSize.height }
        return proposalResult
    }
    
    @available(iOS 16, *)
    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: V,
        context: Context
    ) -> CGSize? {
        switch coordinator.sizingPolicy {
        case .systemLayout:
            systemLayoutSizing(for: uiView, proposal: proposal, context: context)
        case .intrinsic:
            intrinsicSizing(for: uiView)
        case .followProposal(let forWidth, let forHeight):
            proposalSizing(
                for: uiView,
                proposal: proposal,
                forWidth: forWidth,
                forHeight: forHeight
            )
        case .custom(let calculator):
            calculator(proposal, uiView)
        }
    }
    
    public class UIKitCoordinator {
        
        internal var setup: (V) -> Void
        
        private let _sizingPolicy: Any
        
        @available(iOS 16, *)
        internal var sizingPolicy: SizingPolicy {
            _sizingPolicy as! SizingPolicy
        }
        
        init(
            setup: @escaping (V) -> Void
        ) {
            self._sizingPolicy = 0
            self.setup = setup
        }
        
        @available(iOS 16, *)
        init(
            withPolicy sizingPolicy: SizingPolicy,
            setup: @escaping (V) -> Void
        ) {
            self._sizingPolicy = sizingPolicy
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
    .padding(.horizontal, 64)
    .background(Color.blue)
}

@available(iOS 17, *)
#Preview("Follow size proposal") {
    VStack {
        FromUIKit(UILabel.self, sizingPolicy: .followProposal(width: true, height: false)) { label in
            label.text = "Hello UIKit"
            label.font = .systemFont(ofSize: 17, weight: .bold)
            label.textColor = .red
            label.backgroundColor = .orange
        }
        .padding(.horizontal, 32)
        .background(Color.blue)
    }
    .padding(.horizontal, 16)
    .background(Color.gray.tertiary)
}

@available(iOS 16, *)
#Preview("Custom sizing") {
    FromUIKit(UILabel.self, sizingPolicy: .custom({ proposal, view in
        CGSize(
            width: proposal.width ?? view.intrinsicContentSize.width,
            height: view.intrinsicContentSize.height + 64
        )
    })) { label in
        label.text = "Hello UIKit"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .red
        label.backgroundColor = .orange
    }
    .padding(.horizontal, 32)
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
