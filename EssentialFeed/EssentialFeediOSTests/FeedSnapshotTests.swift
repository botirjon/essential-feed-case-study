//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Botirjon Nasridinov on 03/01/25.
//

import XCTest
import EssentialFeediOS

final class FeedSnapshotTests: XCTestCase {
    
    func test_emptyFeed() {
        
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        record(snapshot: sut.snapshot(), named: "EMPTY_FEED")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feed = storyboard.instantiateInitialViewController() as! FeedViewController
        feed.loadViewIfNeeded()
        return feed
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        return []
    }
    
    private func record(
        snapshot: UIImage,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail(
                "Failed to generate PNG data representation from snapshot",
                file: file,
                line: line
            )
            return
        }
        
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appending(component: "snapshots", directoryHint: .isDirectory)
            .appending(component: "\(name).png", directoryHint: .notDirectory)
        
        do {
            try FileManager.default
                .createDirectory(
                    at: snapshotURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
            
            try snapshotData.write(to: snapshotURL)
            
        } catch {
            XCTFail("Failed to record snapshot with error \(error)", file: file, line: line)
        }
        
    }
}

extension UIViewController {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}
