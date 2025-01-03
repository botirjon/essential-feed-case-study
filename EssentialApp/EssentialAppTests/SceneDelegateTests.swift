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
}
