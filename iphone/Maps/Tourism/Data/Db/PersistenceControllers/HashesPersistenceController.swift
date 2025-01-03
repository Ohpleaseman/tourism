import Foundation
import CoreData

class HashesPersistenceController {
  static let shared = HashesPersistenceController()
  
  let container: NSPersistentContainer
  
  init(inMemory: Bool = false) {
    container = NSPersistentContainer(name: "Place")
    if inMemory {
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }
    container.loadPersistentStores { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
  }
  
  // MARK: - CRUD Operations
  func insertHashes(hashes: [Hash]) {
    let context = container.viewContext
    
    do {
      for hash in hashes {
        let newHash = HashEntity(context: context)
        newHash.categoryId = hash.categoryId
        newHash.value = hash.value
      }
      try context.save()
    } catch {
      print("Failed to save context: \(error)")
    }
  }
  
  func getHash(categoryId: Int64) -> Hash? {
    let context = container.viewContext
    let fetchRequest: NSFetchRequest<HashEntity> = HashEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "categoryId == %lld", categoryId)
    fetchRequest.fetchLimit = 1
    
    do {
      let result = try context.fetch(fetchRequest).first
      if let result = result {
        return Hash(categoryId: result.categoryId, value: result.value!)
      } else {
        return nil
      }
    } catch {
      print("Failed to fetch hash: \(error)")
      return nil
    }
  }
  
  func getHashes() -> [Hash] {
    let context = container.viewContext
    let fetchRequest: NSFetchRequest<HashEntity> = HashEntity.fetchRequest()
    
    do {
      let result = try context.fetch(fetchRequest)
      let hashes = result.map { hashEntity in
        Hash(categoryId: hashEntity.categoryId, value: hashEntity.value!)
      }
      return hashes
    } catch {
      print("Failed to fetch hashes: \(error)")
      return []
    }
  }
  
  func deleteHash(hash: Hash) {
    let context = container.viewContext
    let fetchRequest: NSFetchRequest<HashEntity> = HashEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "categoryId == %lld", hash.categoryId)
    
    do {
      if let hash = try context.fetch(fetchRequest).first {
        context.delete(hash)
        try context.save()
      }
    } catch {
      print(error)
      print("Failed to delete review: \(error)")
    }
  }
}
