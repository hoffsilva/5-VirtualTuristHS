//
//  Constants.swift
//  Virtual Tourist - HoffSilva
//
//  Created by Hoff Henry Pereira da Silva on 01/04/16.
//  Copyright © 2016 Hoff Silva. All rights reserved.
//

import UIKit

class Constants: NSObject {
    
    
    static let BASE_URL = "https://api.flickr.com/services/rest/"
    static let METHOD_NAME = "flickr.photos.search"
    static let API_KEY = "a0ac80c1a6e0ac5887e97dfab3d6467e"
    static let SAFE_SEARCH = "1"
    static let EXTRAS = "url_m"
    static let DATA_FORMAT = "json"
    static let NO_JSON_CALLBACK = "1"
    static var PAGE = ""
    
    //@changed: used 24 instead of 12 so we know for sure the collectionview does need to scroll (12 images on iPhone 6 will work without scrolling)
    static let per_page = "15"
    
    static let defaultLatitude = 21.3607893295259
    static let defaultLongitude = -84.6174999722512
    static let defaultCameraAltitude = 529610340.6583709
    
    


}
