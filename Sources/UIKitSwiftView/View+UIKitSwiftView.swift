//
//  View+UIKitSwiftView.swift
//  
//
//  Created by Romain Roche on 21/08/2024.
//

import SwiftUI

public extension View {
    
    /// Wrap the SwiftUI view in a UIView you can add in your view hierarchy.
    /// - Parameter observable: The `ObservableObject` to observe to relayout the view when needed. Optional.
    /// - Returns: A `UIKitSwiftView`.
    func asUIKit(
        observing observable: some ObservableObject = VoidObservable()
    ) -> UIKitSwiftView {
        UIKitSwiftView(observing: observable) {
            AnyView(self)
        }
    }
    
}
