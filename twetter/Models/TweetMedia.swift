//
//  TweetMedia.swift
//  twetter
//
//  Created by Nick McDonald on 2/12/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit

class TweetMedia: NSObject {
    
    private var mediaURL: URL?
    private var mediaWidth: Int?
    private var mediaHeight: Int?
    
    private var mediaBeginIndex: Int?
    private var mediaEndIndex: Int?
    
    init(mediaDictionary: NSDictionary) {
        
        guard let sizesDict: NSDictionary = mediaDictionary["sizes"] as? NSDictionary else {
            return
        }
        
        guard let mediumSizeDict: NSDictionary = sizesDict["medium"] as? NSDictionary else {
            return
        }
        
        guard let width: Int = mediumSizeDict["w"] as? Int else {
            return
        }
        
        guard let height: Int = mediumSizeDict["h"] as? Int else {
            return
        }
        
        self.mediaWidth = width
        self.mediaHeight = height
        
        if let mediaURLString: String = mediaDictionary["media_url_https"] as? String {
            self.mediaURL = URL(string: mediaURLString)
        }
        
        let mediaIndicesInTweetText = mediaDictionary.mutableArrayValue(forKey: "indices")
        self.mediaBeginIndex = mediaIndicesInTweetText.object(at: 0) as? Int
        self.mediaEndIndex = mediaIndicesInTweetText.object(at: 1) as? Int
    }
    
    func mediaSize() -> CGSize? {
        guard let width: Int = self.mediaWidth, let height: Int = self.mediaHeight else {
            return nil
        }
        
        let size: CGSize = CGSize(width: width, height: height)
        return size
    }
    
    func URLOfMedia() -> URL? {
        return self.mediaURL
    }
}
