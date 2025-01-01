//
//  FeedImageDataLoaderCompositeTests.swift
//  EssentialApp
//
//  Created by Botirjon Nasridinov on 01/01/25.
//

import XCTest
import EssentialFeed

final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    
    let primary: FeedImageDataLoader
    let fallback: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        
        init() {}
        
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any EssentialFeed.FeedImageDataLoaderTask {
        
        var task = TaskWrapper()
        task.wrapped = primary.loadImageData(from: url) { [weak self] result in
            switch result {
                case .success:
                    completion(result)
                    
                case .failure:
                    task.wrapped = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
        
        return task
    }
}

final class FeedImageDataLoaderCompositeTests: XCTestCase {
    
    func test_loadImageDataFromURL_deliversPrimaryDataOnPrimarySuccess() {
        let url = URL(string: "https://any-url.com")!
        let primaryData = Data("primary-data".utf8)
        let fallbackData = Data("fallback-data".utf8)
        let primaryLoader = LoaderStub(result: .success(primaryData))
        let fallbackLoader = LoaderStub(result: .success(fallbackData))
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        let exp = expectation(description: "Wait for load image data completion")
        
        _ = sut.loadImageData(from: url) { result in
            switch result {
                case let .success(receivedData):
                    XCTAssertEqual(receivedData, primaryData)
                    
                case .failure:
                    XCTFail("Expected successful load image data, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadImageDataFromURL_deliversFallbackDataOnPrimaryFailure() {
        let url = URL(string: "https://any-url.com")!
        let fallbackData = Data("fallback-data".utf8)
        let primaryLoader = LoaderStub(result: .failure(anyNSError()))
        let fallbackLoader = LoaderStub(result: .success(fallbackData))
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        let exp = expectation(description: "Wait for load image data completion")
        
        _ = sut.loadImageData(from: url) { result in
            switch result {
                case let .success(receivedData):
                    XCTAssertEqual(receivedData, fallbackData)
                    
                case .failure:
                    XCTFail("Expected successful load image data, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private class LoaderStub: FeedImageDataLoader {
    
        let result: FeedImageDataLoader.Result
        
        init(result: FeedImageDataLoader.Result) {
            self.result = result
        }
        
        private class Task: FeedImageDataLoaderTask {
            private var completion: ((FeedImageDataLoader.Result) -> Void)?
            
            init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
                self.completion = completion
            }
            
            func complete(with result: FeedImageDataLoader.Result) {
                completion?(result)
            }
            
            func cancel() {
                preventFurtherCompletions()
            }
            
            private func preventFurtherCompletions() {
                completion = nil
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any EssentialFeed.FeedImageDataLoaderTask {
            let task = Task(completion)
            task.complete(with: result)
            return task
        }
    }
}
