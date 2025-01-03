//
//  UIButton+TestHelpers.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 03/01/25.
//

import UIKit

extension UIButton {
    func simulateTouchUpInside() {
        simulate(event: .touchUpInside)
    }
}
