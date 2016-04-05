//
//  PinPersistence.swift
//  Virtual Tourist - HoffSilva
//
//  Created by Hoff Henry Pereira da Silva on 07/03/16.
//  Copyright © 2016 Hoff Silva. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PinPersistence: NSObject, NSFetchedResultsControllerDelegate  {
    
    
    var temporaryContext: NSManagedObjectContext!
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    func tryPerformFetch(){
    
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Nao foi possivel executar o fetchedResultsController.performFetch")
        }
        
        fetchedResultsController.delegate = self
        
        let sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
        
        temporaryContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        temporaryContext.persistentStoreCoordinator = sharedContext.persistentStoreCoordinator
        
    }
    
    func buscarPins() -> [Pin]{
        
        let requsicaoDeBusca = NSFetchRequest(entityName: "Pin")
        
        do{
            let resultados = try sharedContext.executeFetchRequest(requsicaoDeBusca)
            return resultados as! [Pin]
            
        }catch let error as NSError{
            print("Não foi possível salvar \(error). \(error.userInfo)")
        }
        
        return []
    }
    
    
    func buscarSelectedPin(selectedPin: CLLocationCoordinate2D) -> [Pin]{
        
        let requsicaoDeBusca = NSFetchRequest(entityName: "Pin")
        
        var lat : NSNumber!
        lat = selectedPin.latitude
        
        var long : NSNumber!
        long = selectedPin.longitude
        
        requsicaoDeBusca.predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", lat, long);

        do{
            let resultados = try sharedContext.executeFetchRequest(requsicaoDeBusca)
            print(resultados)
            return resultados as! [Pin]
            
        }catch let error as NSError{
            print("Não foi possível salvar \(error). \(error.userInfo)")
        }
        
        return []
    }
    
    
    func savePin(coordinate: CLLocationCoordinate2D ) -> Pin {
        print(coordinate)
        let dictionary: [String : AnyObject] = [
            Pin.Keys.Latitude : coordinate.latitude,
            Pin.Keys.Longitude : coordinate.longitude,
            //Pin.Keys.Photos : photos
        ]
        print(dictionary)
        let newPin = Pin(dictionary: dictionary, context: sharedContext)
        CoreDataStackManager.sharedInstance().saveContext()
        return newPin
    }
}
