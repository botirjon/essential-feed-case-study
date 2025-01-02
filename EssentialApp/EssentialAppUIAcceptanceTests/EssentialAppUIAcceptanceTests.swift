//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialApp
//
//  Created by Botirjon Nasridinov on 02/01/25.
//

import XCTest

final class EssentialAppUIAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        
        app.launch()
        
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 22)
        
        let firstImage = app.cells.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstImage.exists)
    }
    
    func test_onLaunch_displaysCachedFeedWhenCustomerHasNoConnectivity() {
        let onlineApp = XCUIApplication()
        onlineApp.launch()
        
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launch()
        
        let cachedFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(cachedFeedCells.count, 22)
        
        let cachedFirstImage = offlineApp.cells.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(cachedFirstImage.exists)
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndCache() {
        let app = XCUIApplication()
        app.launchArguments = ["-reset", "-connectivity", "offline"]
        app.launch()
        
        let cachedFeedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(cachedFeedCells.count, 0)
    }
}
