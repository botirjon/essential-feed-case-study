//
//  SceneDelegateTests.swift
//  EssentialApp
//
//  Created by Botirjon Nasridinov on 03/01/25.
//

import XCTest
@testable import EssentialApp
import EssentialFeediOS

final class SceneDelegateTests: XCTestCase {
    
    func test_configureWindow_setsWindowAsKeyAndVisible() {
        let window = UIWindowSpy()
        let sut = SceneDelegate()
        sut.window = window
        sut.configureWindow()
        
        XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1)
    }
    
    func test_sceneWillConnectToSession_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation)
        XCTAssertTrue(topController is FeedViewController)
    }
    
    // MARK: - Helpers
    
    private class UIWindowSpy: UIWindow {
        private(set) var makeKeyAndVisibleCallCount: Int = 0
        
        override func makeKeyAndVisible() {
            super.makeKeyAndVisible()
            makeKeyAndVisibleCallCount += 1
        }
    }
}
