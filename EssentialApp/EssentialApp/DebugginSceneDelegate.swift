//
//  DebugginSceneDelegate.swift
//  EssentialApp
//
//  Created by Botirjon Nasridinov on 02/01/25.
//

#if DEBUG
import UIKit
import EssentialFeed

class DebugginSceneDelegate: SceneDelegate {
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: localStoreURL)
        }
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    override func makeRemoteClient() -> HTTPClient {
        if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
            return AlwaysFailingHTTPClient()
        }
        
        return super.makeRemoteClient()
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
#endif
