//
//  FeedUIIntegrationTests+Assertions.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 03/01/25.
//

import EssentialFeediOS
import EssentialFeed
import XCTest

extension FeedUIIntegrationTests {
    func assertThat(
        _ sut: FeedViewController,
        isRendering feed: [FeedImage],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard feed.count == sut.numberOfRenderedFeedImageViews() else {
            XCTFail(
                "Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead"
            )
            return
        }
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index,  file: file, line: line)
        }
    }
    
    func assertThat(
        _ sut: FeedViewController,
        hasViewConfiguredFor image: FeedImage,
        at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            XCTFail(
                "Expected \(FeedImageCell.self) instance, got \(String.init(describing: view)) instead", file: file, line: line
            )
            return
        }
        
        let shouldLocationBeVisible = image.location != nil
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at \(index)", file: file, line: line)
        
        XCTAssertEqual(
            cell.locationText,
            image.location,
            "Expected location to be \(String(describing: image.location)) for image view at \(index)",
            file: file,
            line: line
        )
        XCTAssertEqual(
            cell.descriptionText,
            image.description,
            "Expected description to be \(String(describing: image.description)) for image view at \(index)",
            file: file,
            line: line
        )
    }
}
