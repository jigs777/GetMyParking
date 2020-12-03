//
//  DBManager.swift
//

import Foundation
import CoreData
import UIKit

struct CEntity {
    static let CountryList = "CountryList"

    
    
}

class DBManager {
    
    static let sharedDatabase = DBManager()
    
    // METHODS
    private init() {}
    
    struct once {
        static var onceToken: Int = 0
    }
    
    
    //MARK: Sort Array
    
    class func sortby(_ attribute: String, array: NSArray) -> NSArray {
        
        let sortDescriptor:NSSortDescriptor = NSSortDescriptor(key: attribute, ascending: true)
        let arr : NSArray = array.sortedArray(using: [sortDescriptor]) as NSArray
        return arr
    }
    
    class func getEntityObject(_ entity: String) -> NSManagedObject? {
        
        if let entity = NSEntityDescription.entity(forEntityName: entity, in: DBManager.sharedDatabase.managedObjectContext) {
            let object = NSManagedObject(entity: entity, insertInto: DBManager.sharedDatabase.managedObjectContext)
            return object
        }
        
        return nil
    }
    
    //MARK: SELECT QUERY
    
    class func select(_ entity: String, members member: NSArray, fromObjectContext ManagedObjectContext: NSManagedObjectContext) -> NSArray {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = member as? [Any]
        
        do{
            let results: NSArray = try ManagedObjectContext.fetch(fetchRequest) as NSArray
            return results
        }
        catch{
            DLog("Error in fetch request")
            return []
        }
    }
    
    //MARK: SELECT ALL QUERY
    
    func selectAll(_ entity: String, fromObjectContext ManagedObjectContext: NSManagedObjectContext) -> NSArray {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        do{
            let results: NSArray = try ManagedObjectContext.fetch(fetchRequest) as NSArray
            return results
        }
        catch{
            DLog("Error in fetch request")
            return []
        }
    }
    
    func select(_ entity: String, members member: NSArray, withpredicate predicate: NSPredicate, fromObjectContext ManagedObjectContext: NSManagedObjectContext) -> NSArray {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = member as? [Any]
        
        do{
            let results: NSArray = try ManagedObjectContext.fetch(fetchRequest) as NSArray
            return results
        }
        catch{
            DLog("Error in fetch request")
            return []
        }
    }
    
    func select(_ entity: String, withpredicate predicate: NSPredicate, sortDescriptor: [NSSortDescriptor]? = [], fromObjectContext ManagedObjectContext: NSManagedObjectContext) -> NSArray {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptor
        
        do {
            let results = try ManagedObjectContext.fetch(fetchRequest) as NSArray
            return results 
        }
        catch{
            DLog("Error in fetch request")
            return []
        }
    }
    
    
    func select(_ entity: String, withpredicate predicate: NSPredicate, priorityDict sortDic: NSArray, fromObjectContext ManagedObjectContext: NSManagedObjectContext) -> NSArray {
        
        let sortDescriptors: NSArray =  sortDic
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        do{
            let results: NSArray = try ManagedObjectContext.fetch(fetchRequest) as NSArray
            return results.sortedArray(using: sortDescriptors as! [NSSortDescriptor]) as NSArray
        }
        catch{
            DLog("Error in fetch request")
            return []
        }
    }
    
    func deleteAll(_ entity: String, fromObjectContext ManagedObjectContext: NSManagedObjectContext) -> Bool {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        do{
            let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            let _ = try ManagedObjectContext.execute(request)
            return true
        }
        catch{
            DLog("Error in fetch request")
            return false
        }
    }
    
    func selectSingle(_ entity: String, withpredicate predicate: NSPredicate? = nil, sortDescriptor: [NSSortDescriptor]? = [], fromObjectContext ManagedObjectContext: NSManagedObjectContext) -> Any? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = sortDescriptor
        
        do{
            let results: NSArray = try ManagedObjectContext.fetch(fetchRequest) as NSArray
            return results.lastObject
        }
        catch{
            DLog("Error in fetch request")
            return nil
        }
    }
    
    func clone(_ source: NSManagedObject, inContext context: NSManagedObjectContext) -> NSManagedObject {
        
        let entityName: String = source.entity.name!
        //create new object in data store
        let cloned: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        //loop through all attributes and assign then to the clone
        let attributes: Dictionary = NSEntityDescription.entity(forEntityName: entityName, in: context)!.attributesByName
        
        for (key, value) in attributes {
            
            cloned.setValue(value, forKey: key)
        }
        
        return cloned
    }
    
    class func writeErrorLogsToFile(_ strErr: String) {
        
        // Build the path, and create if needed.
        let filePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileName: String = DBManager.sharedDatabase.errorLogFile
        let fileAtPath: String = filePath.appending("/\(fileName)")
        if !FileManager.default.fileExists(atPath: fileAtPath) {
            FileManager.default.createFile(atPath: fileAtPath, contents: nil, attributes: nil)
        }
        var strLog:String!
        var strFileData:String = ""
        
        do {
            strFileData  = try NSString(contentsOfFile: fileAtPath, usedEncoding: nil) as String
            
        } catch {
            // contents could not be loaded
        }
        
        if strFileData.count > 0 {
            
            strLog = "\n\(strErr)"
        }
        else {
            strLog = strErr
        }        
        
        let handle: FileHandle = FileHandle.init(forWritingAtPath: fileAtPath)!
        handle.truncateFile(atOffset: handle.seekToEndOfFile())
        handle.write(strLog.data(using: String.Encoding.utf8)!)
    }
    
    class func readErrorFile() -> String {
        // Build the path...
        let filePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileName: String = DBManager.sharedDatabase.errorLogFile
        let fileAtPath: String = filePath.appending(fileName)
        // The main act...
        
        let strFileData:String!
        
        do {
            strFileData  = try NSString(contentsOfFile: fileAtPath, usedEncoding: nil) as String
            
        } catch {
            strFileData = ""
        }
        return strFileData
    }
    
    var syncDatabase: DBManager? = nil
    var errorLogFile: String = "CoreDataCoreDataCoreData"
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.razeware.HitList" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "GetMyParking", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        objc_sync_enter(self)
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("GetMyParking.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        
        let mOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
                        NSInferMappingModelAutomaticallyOption: true]
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: mOptions)
        } catch {
            // Report any error we got.
            var dict = [String: Any]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as Any
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as Any
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        objc_sync_exit(self)
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
  
   
    // MARK: - Core Data Saving support
    
    func saveContext ()->Bool {
        
        if managedObjectContext.hasChanges {
            do {
                try DBManager.sharedDatabase.managedObjectContext.save()
                return true
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                return false
                
            }
        }
        return false
    }
    
    // MARK:- Attachment Related Methods
    
    func deleteMultipleRecords(entityName: String, predicate: NSPredicate?) {
        
       // self.managedObjectContext.performAndWait {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            fetchRequest.predicate = predicate
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                
                let result = try self.managedObjectContext.execute(batchDeleteRequest)
                DLog(result)
                
            } catch {
                DLog(error)
            }
            
            // runOnMainThread {
            if !DBManager.sharedDatabase.saveContext(){
                DBManager.writeErrorLogsToFile("LOG: \(Date())\t METHOD: \("checkParkingDataForDict"):\(#line) \t ERROR: \("")")
            }
            //}
        //}
    }
    
    
    // MARK: - delete Parking data
    func clearParkingDataFromDB() -> Bool {
        return self.deleteAll(CEntity.CountryList, fromObjectContext: self.managedObjectContext)
    }
    
    // MARK: - DeleteAll Rename Data
    func deleteAllData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CEntity.CountryList)
               let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
               do {
                   try managedObjectContext.execute(batchDeleteRequest)
               } catch{}
    }
    
 

    // MARK: - Common Methods
    ///Delete All data from Coredata for particular entity
    func deleteAllDataForEntity(entityName:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedObjectContext.execute(batchDeleteRequest)
        } catch{}
    }
    // MARK: - FilterData
    /// it stores companydata and vehicledata to Coredata
    
    
    
}

// MARK: - Inspection Images

extension DBManager {
    

    // MARK: - Save Rename Data
    func saveAllData(data:Data) {
        
        let CrenameLable = CountryList(context: DBManager.sharedDatabase.managedObjectContext)
        CrenameLable.data = data 
        if !DBManager.sharedDatabase.saveContext(){
            DBManager.writeErrorLogsToFile("LOG: \(Date())\t METHOD: \("checkParkingDataForDict"):\(#line) \t ERROR: \("")")
        }
        
    }
    
    // MARK: - Get Rename Data
    func getAllData() -> [CountryList]  {
       
        var arrList = [CountryList]()

        let fetchRequest = NSFetchRequest<CountryList>(entityName: CEntity.CountryList)
        do {
            arrList =   try DBManager.sharedDatabase.managedObjectContext.fetch(fetchRequest)
               } catch {
                   debugPrint("Could not Fetch: \(error.localizedDescription)")
               }
        
        return arrList
        
    }

}
