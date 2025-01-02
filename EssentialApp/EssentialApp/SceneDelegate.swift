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


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let remoteClient = makeRemoteClient()
        let remoteFeedLoader = RemoteFeedLoader(
            url: remoteURL,
            client: remoteClient
        )
        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
        
        let localStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite")
        
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: localStoreURL)
        }
        
        let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
        let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: localStore)

        
        window?.rootViewController = FeedUIComposer.feedComposedWith(
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
        )
    }
    
    private func makeRemoteClient() -> HTTPClient {
        switch UserDefaults.standard.string(forKey: "connectivity") {
            case "offline":
                return AlwaysFailingHTTPClient()
                
            default:
                return URLSessionHTTPClient(
                    session: URLSession(configuration: .ephemeral)
                )
        }
        
    }
}


private class AlwaysFailingHTTPClient: HTTPClient {
    
    private class Task: HTTPClientTask {
        func cancel() {
            
        }
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> any EssentialFeed.HTTPClientTask {
        completion(.failure(NSError(domain: "offline", code: 0)))
        return Task()
    }
}
