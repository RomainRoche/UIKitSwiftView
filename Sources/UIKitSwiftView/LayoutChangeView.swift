//
//  LayoutChangeView.swift
//  UIKitSwiftView
//
//  Created by Romain Roche on 10/09/2024.
//

import SwiftUI

private struct FramePreferenceKey: PreferenceKey {
    public static var defaultValue: CGRect = .zero
    
    public static func reduce(
        value: inout CGRect,
        nextValue: () -> CGRect
    ) {
        value = nextValue()
    }
}

struct LayoutChangeView: View {
    
    @MainActor private let builder: () -> AnyView
    @MainActor private let onLayoutChange: () -> Void
    
    init(
        @ViewBuilder builder: @escaping () -> some View,
        onLayoutChange: @MainActor @escaping () -> Void
    ) {
        self.builder = {
            AnyView(builder())
        }
        self.onLayoutChange = onLayoutChange
    }
    
    var body: some View {
        if #available(iOS 18, *) {
            builder()
                .onGeometryChange(for: CGRect.self) { proxy in
                    proxy.frame(in: .global)
                } action: { frame in
                    onLayoutChange()
                }
        } else {
            builder().overlay(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: FramePreferenceKey.self,
                        value: proxy.frame(in: .global)
                    )
                }
            )
            .onPreferenceChange(FramePreferenceKey.self) { _ in
                onLayoutChange()
            }
        }
    }
}

#Preview {
    LayoutChangeView {
        Text("Hello world")
    } onLayoutChange: {
        
    }
}
