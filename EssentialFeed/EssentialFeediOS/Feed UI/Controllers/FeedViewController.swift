//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Botirjon Nasridinov on 18/12/24.
//

import UIKit
import EssentialFeed

public protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, FeedLoadingView, FeedErrorView {
    

    @IBOutlet private(set) public var errorView: ErrorView!
    
    private var loadingControllers = [IndexPath: FeedImageCellController]()
    
    public var delegate: FeedViewControllerDelegate?
    
    private var tableModel = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }
    
    private var viewAppeared: Bool = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    public func display(_ cellControllers: [FeedImageCellController]) {
        loadingControllers = [:]
        tableModel = cellControllers
    }
    
    public func display(viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    public func display(viewModel: EssentialFeed.FeedErrorViewModel) {
        if let errorMessage = viewModel.message {
            errorView.show(message: errorMessage)
        } else {
            errorView.hideMessage()
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        if !viewAppeared {
            self.refresh()
            viewAppeared = true
        }
    }
    
    deinit {
        loadingControllers.forEach { (indexPath: IndexPath, loadingController: FeedImageCellController) in
            loadingController.cancelLoad()
        }
        
        loadingControllers = [:]
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view(in: tableView)
    }
    
    public override func tableView(
        _ tableView: UITableView,
        didEndDisplaying cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public func tableView(
        _ tableView: UITableView,
        prefetchRowsAt indexPaths: [IndexPath]
    ) {
        indexPaths.forEach {
            cellController(forRowAt: $0).preload()
        }
    }
    
    public func tableView(
        _ tableView: UITableView,
        cancelPrefetchingForRowsAt indexPaths: [IndexPath]
    ) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        loadingControllers[indexPath]?.cancelLoad()
        loadingControllers[indexPath] = nil
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }
}
