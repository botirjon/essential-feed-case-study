//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Botirjon Nasridinov on 03/01/25.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class FeedSnapshotTests: XCTestCase {
    
    func test_emptyFeed() {
        
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        assert(snapshot: sut.snapshot(for: .iPhone16Pro(style: .light)), named: "EMPTY_FEED_light")
        assert(snapshot: sut.snapshot(for: .iPhone16Pro(style: .dark)), named: "EMPTY_FEED_dark")
    }
    
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        assert(snapshot: sut.snapshot(for: .iPhone16Pro(style: .light)), named: "FEED_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone16Pro(style: .dark)), named: "FEED_WITH_CONTENT_dark")
    }
    
    func test_feedWithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(viewModel: .error("This is a\nmultiline \nerror message"))
        
        assert(snapshot: sut.snapshot(for: .iPhone16Pro(style: .light)), named: "FEED_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone16Pro(style: .dark)), named: "FEED_WITH_ERROR_MESSAGE_dark")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(feedWithFailedImageLoading())
        
        assert(snapshot: sut.snapshot(for: .iPhone16Pro(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone16Pro(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feed = storyboard.instantiateInitialViewController() as! FeedViewController
        feed.tableView.showsVerticalScrollIndicator = false
        feed.tableView.showsHorizontalScrollIndicator = false
        feed.loadViewIfNeeded()
        return feed
    }
    
    
    
    private func emptyFeed() -> [FeedImageCellController] {
        return []
    }
    
    private func feedWithContent() -> [ImageStub] {
        return [
            ImageStub(
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                location: "East Side Gallery\nMemorial in Berlin, Germany",
                image: UIImage.make(withColor: .red)
            ),
            ImageStub(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Garth Pier",
                image: UIImage.make(withColor: .green)
            )
        ]
    }
    
    private func feedWithFailedImageLoading() -> [ImageStub] {
        return [
            ImageStub(
                description: nil,
                location: "Cannon street, London",
                image: nil
            ),
            ImageStub(
                description: nil,
                location: "Brighton Seafront",
                image: nil
            )
        ]
    }
    
    private func assert(
        snapshot: UIImage,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail(
                "Failed to load stored snapshot at URL: \(snapshotURL), Use the `record` method to store a snapshot before asserting",
                file: file,
                line: line
            )
            return
        }
        
        if snapshotData != storedSnapshotData {
            let temporarySnapshotURL = URL(
                fileURLWithPath: NSTemporaryDirectory(),
                isDirectory: true
            ).appending(
                component: snapshotURL.lastPathComponent,
                directoryHint: .notDirectory
            )
            
            try? snapshotData?.write(to: temporarySnapshotURL)
            
            XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), stored snapshot URL: \(snapshotURL)", file: file, line: line)
        }
    }
    
    private func record(
        snapshot: UIImage,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        do {
            try FileManager.default
                .createDirectory(
                    at: snapshotURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
            
            try snapshotData?.write(to: snapshotURL)
            
        } catch {
            XCTFail("Failed to record snapshot with error \(error)", file: file, line: line)
        }
        
    }
    
    private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        return URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appending(component: "snapshots", directoryHint: .isDirectory)
            .appending(component: "\(name).png", directoryHint: .notDirectory)
    }
    
    private func makeSnapshotData(for snapshot: UIImage, file: StaticString = #filePath, line: UInt = #line) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail(
                "Failed to generate PNG data representation from snapshot",
                file: file,
                line: line
            )
            return nil
        }
        
        return data
    }
}

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        return SnapshotWindow(configuration: configuration, root: self)
            .snapshot()
    }
}

struct SnapshotConfiguration {
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traitCollection: UITraitCollection
    
    static func iPhone16Pro(style: UIUserInterfaceStyle) -> SnapshotConfiguration {
        return SnapshotConfiguration(
            size: CGSize(width: 390, height: 844),
            safeAreaInsets: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
            layoutMargins: UIEdgeInsets(top: 55, left: 8, bottom: 42, right: 8),
            traitCollection: UITraitCollection(mutations: { traits in
                traits.forceTouchCapability = .unavailable
                traits.layoutDirection = .leftToRight
                traits.preferredContentSizeCategory = .medium
                traits.userInterfaceIdiom = .phone
                traits.horizontalSizeClass = .compact
                traits.verticalSizeClass = .regular
                traits.displayScale = 3
                traits.accessibilityContrast = .normal
                traits.displayGamut = .P3
                traits.userInterfaceStyle = style
            }))
    }
}

private final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone16Pro(style: .light)
    
    convenience init(
        configuration: SnapshotConfiguration,
        root: UIViewController
    ) {
        self.init(frame: CGRect(origin: .zero, size: configuration.size))
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargins
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        return configuration.safeAreaInsets
    }
    
    override var traitCollection: UITraitCollection {
        return super.traitCollection.modifyingTraits({ mutableTraits in
            mutableTraits.forceTouchCapability = configuration.traitCollection.forceTouchCapability
            mutableTraits.layoutDirection = configuration.traitCollection.layoutDirection
            mutableTraits.preferredContentSizeCategory = configuration.traitCollection.preferredContentSizeCategory
            mutableTraits.userInterfaceIdiom = configuration.traitCollection.userInterfaceIdiom
            mutableTraits.horizontalSizeClass = configuration.traitCollection.horizontalSizeClass
            mutableTraits.verticalSizeClass = configuration.traitCollection.verticalSizeClass
            mutableTraits.displayScale = configuration.traitCollection.displayScale
            mutableTraits.accessibilityContrast = configuration.traitCollection.accessibilityContrast
            mutableTraits.displayGamut = configuration.traitCollection.displayGamut
            mutableTraits.userInterfaceStyle = configuration.traitCollection.userInterfaceStyle
        })
    }

    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(
            bounds: bounds,
            format: .init(for: traitCollection)
        )
        
        return renderer.image { action in
            return layer.render(in: action.cgContext)
        }
    }
}

private extension FeedViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [FeedImageCellController] = stubs.map { stub in
            let cellController = FeedImageCellController(delegate: stub)
            stub.controller = cellController
            return cellController
        }
        
        display(cells)
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    var viewModel: FeedImageViewModel<UIImage>
    weak var controller: FeedImageCellController?
    
    init(description: String?, location: String?, image: UIImage?) {
        viewModel = FeedImageViewModel(
            description: description,
            location: location,
            image: image,
            isLoading: false,
            shouldRetry: image == nil
        )
    }
    
    func didRequestImage() {
        controller?.display(viewModel)
    }

    func didCancelImageRequest() {
        
    }
}
