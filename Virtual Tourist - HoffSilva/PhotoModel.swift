//
//  PhotoModel.swift
//  Virtual Tourist - HoffSilva
//
//  Created by Hoff Henry Pereira da Silva on 10/03/16.
//  Copyright © 2016 Hoff Silva. All rights reserved.
//

import UIKit

class PhotoModel: NSObject {
    
    init(titulo : String, URL : String) {
        
        self.titulo = titulo
        self.URL = URL
        
    }
    
    var titulo : String
    var URL : String
    
    var arrayOfPhotos = [PhotoModel]()
}
