//
//  LastPosition.swift
//  Virtual Tourist - HoffSilva
//
//  Created by Hoff Henry Pereira da Silva on 11/03/16.
//  Copyright © 2016 Hoff Silva. All rights reserved.
//

import UIKit
import CoreData
import MapKit

//@CHANGED: added the @objc(), this makes it possible for the compiler to understand what we are trying to do here (core date still heavily depends on objective-c
@objc(LastPosition)

class LastPosition: NSManagedObject {
    
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let TimeStamp = "timeStamp"
        static let Altitude = "altitude"
    }
    
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var timeStamp: NSDate?
    @NSManaged var altitude: NSNumber?
    
    // 4. Include this standard Core Data init method.
     override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("LastPosition", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        latitude = dictionary[Keys.Latitude] as! Double
        
        longitude = dictionary[Keys.Longitude] as? Double
        
        timeStamp = dictionary[Keys.TimeStamp] as? NSDate
        
        altitude = dictionary[Keys.Altitude] as? Double
        
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude as! Double, longitude: longitude as! Double)
    }

}
