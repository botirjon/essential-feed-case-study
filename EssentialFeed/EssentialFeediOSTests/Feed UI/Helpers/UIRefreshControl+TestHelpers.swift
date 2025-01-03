//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 03/01/25.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
