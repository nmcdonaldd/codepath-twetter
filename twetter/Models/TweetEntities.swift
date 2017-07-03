//
//  TweetEntities.swift
//  twetter
//
//  Created by Nick McDonald on 2/2/17.
//  Copyright © 2017 Nick McDonald. All rights reserved.
//

import UIKit

class TweetEntities {
    
    // Holds info about the width/height and url of the medias
    var mediaInfo: [TweetMedia]?
    
    init(entitiesDictionary: NSDictionary) {
        if let mediaDictionary: [NSDictionary] = entitiesDictionary["media"] as? [NSDictionary] {
            self.mediaInfo = mediaDictionary.map({ (mediaDictionary) -> TweetMedia in
                TweetMedia(mediaDictionary: mediaDictionary)
            })
        }
    }
}
