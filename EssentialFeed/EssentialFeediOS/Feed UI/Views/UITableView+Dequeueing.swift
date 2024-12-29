//
//  UITableView+Dequeueing.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 29/12/24.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
