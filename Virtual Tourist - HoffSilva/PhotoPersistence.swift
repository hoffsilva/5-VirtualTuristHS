//
//  PhotoPersistence.swift
//  Virtual Tourist - HoffSilva
//
//  Created by Hoff Henry Pereira da Silva on 07/03/16.
//  Copyright © 2016 Hoff Silva. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotoPersistence: NSObject, NSFetchedResultsControllerDelegate {
    
    
    var temporaryContext: NSManagedObjectContext!
    
    
    var coordinates = CLLocationCoordinate2D()
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "titulo", ascending: true)]
        
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
    
    func buscarPhotos() -> [Photo]{
        
        let requisicaoDeBusca = NSFetchRequest(entityName: "Photo")
        
        var lat : NSNumber!
        lat = self.coordinates.latitude
        
        var long : NSNumber!
        long = self.coordinates.longitude
        
        requisicaoDeBusca.predicate = NSPredicate(format: "place.latitude == %@ AND place.longitude == %@", lat, long);
        
        do{
            let resultados = try sharedContext.executeFetchRequest(requisicaoDeBusca)
            return resultados as! [Photo]
            
        }catch let error as NSError{
            print("Não foi possível salvar \(error). \(error.userInfo)")
        }
        
        return []
    }
    
    func savePhotos(photos: [[String : AnyObject]], place: Pin ){
        
        
         var teste = [String:AnyObject]()
        
        
        for t in photos{
                        
            guard let titulo = t["title"] as? String else{
                print("nao achei o titulo!")
                return
            }
            guard let url = t["url_m"] as? String else{
                print("Nao achei a url!")
                return
            }
            
            teste[Photo.Keys.Titulo] = titulo
            teste[Photo.Keys.URL] = url
            teste[Photo.Keys.Place] = place
            
            let _ = Photo(dictionary: teste, context: sharedContext)
        }
        
        CoreDataStackManager.sharedInstance().saveContext()
        
    }
    
    
    


}
