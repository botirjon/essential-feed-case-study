//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 03/01/25.
//

import Foundation
import EssentialFeediOS

extension FeedImageCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }
    
    var isShowingRetryButton: Bool {
        return !feedImageRetryButton.isHidden
    }
    
    func simulateRetryAction() {
        self.feedImageRetryButton.simulateTouchUpInside()
    }
}
