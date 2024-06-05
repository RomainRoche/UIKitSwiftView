//
//  ViewController.swift
//  UIKitSwiftViewExample
//
//  Created by Romain Roche on 01/06/2024.
//

import UIKit
import UIKitSwiftView
import SwiftUI
import Combine

class ViewController: UIViewController {

    final class Model: ObservableObject {
        @Published var scrollHeight: CGFloat = 0
    }
    
    private let titleLabel = UILabel()
    private var list: UIKitSwiftView!
    private var swiftUIButton: UIKitSwiftView!
    private let model = Model()
    
    private var cancels = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        setupTitle()
        setupList()
        setupButton()
    }
    
    private func setupTitle() {
        view.addSubview(titleLabel)
        titleLabel.text = "I am a UIKit UIViewController"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .darkGray
        titleLabel.setContentHuggingPriority(.required,
                                        for: .vertical)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.topAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
            .isActive = true
        titleLabel.leadingAnchor
            .constraint(equalTo: view.leadingAnchor, constant: 16)
            .isActive = true
        view.trailingAnchor
            .constraint(equalTo: titleLabel.trailingAnchor, constant: 16)
            .isActive = true
    }
    
    private func setupList() {
        list = UIKitSwiftView(observing: model) { [unowned self] in
            Divider()
            
            Text("I'm a SwiftUI Scroll View")
                .font(.title)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 12)
                .foregroundColor(.accentColor)
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    Text("Scroll model's height: \(self.model.scrollHeight)")
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 12)
                    
                    ForEach((0...200), id: \.self) { idx in
                        Text("Item n° \(idx)")
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.75))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.all, 24)
            }
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        
        view.addSubview(list)
        list.translatesAutoresizingMaskIntoConstraints = false
        list.topAnchor
            .constraint(equalTo: titleLabel.bottomAnchor, constant: 16)
            .isActive = true
        list.leadingAnchor
            .constraint(equalTo: view.leadingAnchor, constant: 16)
            .isActive = true
        view.trailingAnchor
            .constraint(equalTo: list.trailingAnchor, constant: 16)
            .isActive = true
    }
    
    private func setupButton() {
        swiftUIButton = UIKitSwiftView {
            Button {
                self.onButton()
            } label: {
                Label {
                    Text("Some other SwiftUI action")
                        .foregroundColor(.white)
                } icon: {
                    Image(systemName: "arrowshape.right.circle")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 8)
            .background(Color.accentColor)
            .clipShape(Capsule())
        }
        
        view.addSubview(swiftUIButton)
        swiftUIButton.setContentHuggingPriority(.required, for: .vertical)
        swiftUIButton.setContentCompressionResistancePriority(.required, for: .vertical)
        swiftUIButton.translatesAutoresizingMaskIntoConstraints = false
        swiftUIButton.topAnchor
            .constraint(equalTo: list.bottomAnchor, constant: 16)
            .isActive = true
        swiftUIButton.leadingAnchor
            .constraint(equalTo: view.leadingAnchor, constant: 16)
            .isActive = true
        view.safeAreaLayoutGuide.bottomAnchor
            .constraint(equalTo: swiftUIButton.bottomAnchor, constant: 16)
            .isActive = true
        view.trailingAnchor
            .constraint(equalTo: swiftUIButton.trailingAnchor, constant: 16)
            .isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        model.scrollHeight = list.frame.size.height
    }
    
    private func onButton() {
        print("button action")
    }

}

@available(iOS 17, *)
#Preview {
    ViewController()
}

