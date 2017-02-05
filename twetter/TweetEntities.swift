//
//  TweetEntities.swift
//  twetter
//
//  Created by Nick McDonald on 2/2/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit

class TweetEntities: NSObject {
    
    var secureMediaURL: URL?
    var displayURL: URL?
    var expandedURL: URL?
    var mediaBeginIndex: Int = 0
    var mediaEndIndex: Int = 0
    
    init(mediaDictionary: NSDictionary) {
        if let mediaURLString: String = mediaDictionary["media_url_https"] as? String {
            self.secureMediaURL = URL(string: mediaURLString)
        }
        if let _displayURL: String = mediaDictionary["display_url"] as? String {
            self.displayURL = URL(string: _displayURL)
        }
        if let _expandedURL: String = mediaDictionary["expanded_url"] as? String {
            self.expandedURL = URL(string: _expandedURL)
        }
        let mediaIndicesInTweetText = mediaDictionary.mutableArrayValue(forKey: "indices")
        self.mediaBeginIndex = mediaIndicesInTweetText.object(at: 0) as! Int
        self.mediaEndIndex = mediaIndicesInTweetText.object(at: 1) as! Int
    }

}
