//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Botirjon Nasridinov on 31/12/24.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(
            session: URLSession(configuration: .ephemeral)
        )
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL: NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite"))
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(
            store: store,
            currentDate: Date.init
        )
    }()
    
    convenience init(
        httpClient: HTTPClient,
        store: FeedStore & FeedImageDataStore
    ) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        configureWindow()
    }
    
    func configureWindow() {
        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        
        let remoteFeedLoader = RemoteFeedLoader(
            url: remoteURL,
            client: httpClient
        )
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        
        let localImageLoader = LocalFeedImageDataLoader(store: store)

        
        window?.rootViewController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: FeedLoaderWithFallbackComposite(
                primary: FeedLoaderCachingDecorator(
                    decoratee: remoteFeedLoader,
                    cache: localFeedLoader
                ),
                fallback: localFeedLoader
            ),
            imageLoader: FeedImageDataLoaderWithFallbackComposite(
                primary: localImageLoader,
                fallback: FeedImageDataLoaderCachingDecorator(
                    decoratee: remoteImageLoader,
                    cache: localImageLoader
                )
            )
        ))
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
}
