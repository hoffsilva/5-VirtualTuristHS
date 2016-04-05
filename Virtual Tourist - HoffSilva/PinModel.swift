//
//  PinModel.swift
//  Virtual Tourist - HoffSilva
//
//  Created by Hoff Henry Pereira da Silva on 07/03/16.
//  Copyright © 2016 Hoff Silva. All rights reserved.
//

import UIKit
import MapKit

class PinModel: NSObject {
    
    init(coordinate : CLLocationCoordinate2D, listPhotos : [Photo]) {
        
        self.coordinate = coordinate
        self.listPhotos = listPhotos
        
    }
    
    var coordinate : CLLocationCoordinate2D
    var listPhotos : [Photo]
    
    
    var arrayOfPins = [PinModel]()

}
