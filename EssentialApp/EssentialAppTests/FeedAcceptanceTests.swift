//
//  FeedAcceptanceTests.swift
//  EssentialApp
//
//  Created by Botirjon Nasridinov on 03/01/25.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

final class FeedAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let feed = launch(httpClient: .online(response(for:)), store: .empty)
        
        feed.simulateViewAppearance()
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData()
        )
    }
    
    func test_onLaunch_displaysCachedFeedWhenCustomerHasNoConnectivity() {
        let sharedStore = InMemoryFeedStore.empty
        let onlineFeed = launch(
            httpClient: .online(response(for:)),
            store: sharedStore
        )
        onlineFeed.simulateViewAppearance()
        onlineFeed.simulateFeedImageVisible(at: 0)
        onlineFeed.simulateFeedImageVisible(at: 1)
        
        let offlineFeed = launch(httpClient: .offline, store: sharedStore)
        offlineFeed.simulateViewAppearance()
        
        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData()
        )
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndCache() {
    }
    
    // MARK: - Helpers
    
    private func launch(httpClient: HTTPClientStub = .offline, store: InMemoryFeedStore = .empty) -> FeedViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        return nav?.topViewController as! FeedViewController
    }
    
    private class HTTPClientStub: HTTPClient {
        
        private class Task: HTTPClientTask {
            func cancel() {
                
            }
        }
        
        private let stub: (URL) -> HTTPClient.Result
        
        init(stub: @escaping (URL) -> HTTPClient.Result) {
            self.stub = stub
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> any EssentialFeed.HTTPClientTask {
            completion(stub(url))
            return Task()
        }
        
        static var offline: HTTPClientStub {
            HTTPClientStub { _ in .failure(NSError(domain: "offline", code: 0)) }
        }
        
        static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
            HTTPClientStub { url in .success(stub(url)) }
        }
    }

    private class InMemoryFeedStore: FeedStore, FeedImageDataStore {
        private var feedCache: CachedFeed?
        private var feedImageDataCache = [URL: Data]()
        
        static var empty: InMemoryFeedStore { InMemoryFeedStore() }
        
        func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
            feedCache = nil
            completion(.success(()))
        }

        func insert(
            _ feed: [EssentialFeed.LocalFeedImage],
            timestamp: Date,
            completion: @escaping FeedStore.InsertionCompletion
        ) {
            feedCache = CachedFeed(feed: feed, timestamp: timestamp)
            completion(.success(()))
        }

        func retreive(completion: @escaping FeedStore.RetreiveCompletion) {
            completion(.success(feedCache))
        }

        func insert(
            _ data: Data,
            for url: URL,
            completion: @escaping FeedImageDataStore.InsertionCompletion
        ) {
            feedImageDataCache[url] = data
        }

        func retreive(
            dataForURL url: URL,
            completion: @escaping FeedImageDataStore.RetreiveCompletion
        ) {
            completion(.success(feedImageDataCache[url]))
        }
    }
    
    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
            case "http://image.com":
                return makeImageData()
                
            default:
                return makeFeedData()
        }
    }
    
    private func makeImageData() -> Data {
        UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": UUID().uuidString, "image": "http://image.com"],
            ["id": UUID().uuidString, "image": "http://image.com"]
        ]])
    }
}
