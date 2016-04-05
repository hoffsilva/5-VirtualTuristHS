//
//  LastPositionPersistence.swift
//  Virtual Tourist - HoffSilva
//
//  Created by Hoff Henry Pereira da Silva on 11/03/16.
//  Copyright © 2016 Hoff Silva. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class LastPositionPersistence: NSObject, NSFetchedResultsControllerDelegate  {

    
    
    var temporaryContext: NSManagedObjectContext!
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "LastPosition")
        
        
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
    
    func buscarLastLocation() -> [LastPosition]{
        
        let requsicaoDeBusca = NSFetchRequest(entityName: "LastPosition")
        let sectionSortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        requsicaoDeBusca.sortDescriptors = sortDescriptors
        requsicaoDeBusca.fetchLimit = 1
       
        
        
        do{
            let resultados = try sharedContext.executeFetchRequest(requsicaoDeBusca)
           print(resultados)
            return resultados as! [LastPosition]
            
        }catch let error as NSError{
            print("Não foi possível salvar \(error). \(error.userInfo)")
        }
        
        return []
    }
    
    
    func updatePosition(coordinate: CLLocationCoordinate2D, objectIDFromNSManagedObject: NSManagedObjectID ){
         
         let predicate = NSPredicate(format: "objectID == %@", objectIDFromNSManagedObject)
         
         let fetchRequest = NSFetchRequest(entityName: "LastPosition")
         fetchRequest.predicate = predicate
         
         do {
         let fetchedEntities = try sharedContext.executeFetchRequest(fetchRequest) as! [LastPosition]
         fetchedEntities.first?.latitude = coordinate.latitude
         fetchedEntities.first?.longitude = coordinate.longitude
         // ... Update additional properties with new values
         } catch {
         // Do something in response to error condition
         }
         
         do {
         try sharedContext.save()
         } catch {
         // Do something in response to error condition
         }

    }
    
    func savePin(coordinate: CLLocationCoordinate2D, timeStamp: NSDate, altitude: CLLocationDistance ){
        
            let dictionary: [String : AnyObject] = [
                LastPosition.Keys.Latitude : coordinate.latitude,
                LastPosition.Keys.Longitude : coordinate.longitude,
                LastPosition.Keys.TimeStamp : timeStamp,
                LastPosition.Keys.Altitude : altitude
            ]
            let _ = LastPosition(dictionary: dictionary, context: sharedContext)
            CoreDataStackManager.sharedInstance().saveContext()
    }
    
    
}
