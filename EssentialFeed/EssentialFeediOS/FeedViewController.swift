//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Botirjon Nasridinov on 18/12/24.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController {
    var loader: FeedLoader?
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?
            .addTarget(self, action: #selector(load), for: .valueChanged)
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        self.load()
    }
    
    @objc private func load() {
        self.refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
    
    private func beginRefreshing() {
        if let refreshControl = self.refreshControl {
            refreshControl.beginRefreshing()
            let offset = CGPoint(x: 0, y: -refreshControl.frame.size.height)
            tableView.setContentOffset(offset, animated: true)
        }
    }
}
