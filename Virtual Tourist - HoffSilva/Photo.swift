//
//  Photo.swift
//  Virtual Tourist - HoffSilva
//
//  Created by Hoff Henry Pereira da Silva on 04/03/16.
//  Copyright © 2016 Hoff Silva. All rights reserved.
//

import Foundation
import CoreData

//@CHANGED: added the @objc(), this makes it possible for the compiler to understand what we are trying to do here (core date still heavily depends on objective-c
@objc(Photo)

class Photo: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    struct Keys {
        static let Titulo = "titulo"
        static let URL = "url"
        static let Place = "place"
        static let jpgName = "jpgName"
    }
    
    @NSManaged var titulo: String?
    @NSManaged var url: String?
    @NSManaged var place: Pin?
    // Will store the filepath to the actual JPG
    @NSManaged var jpgName: String?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        titulo = dictionary[Keys.Titulo] as? String
        url = dictionary[Keys.URL] as? String
        place = (dictionary[Keys.Place] as! Pin)
    }

}
