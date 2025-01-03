//
//  UIView+TestHelpers.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 03/01/25.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
