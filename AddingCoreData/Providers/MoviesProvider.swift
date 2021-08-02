import CoreData
import UIKit

final class MoviesProvider: NSObject {
    let storage: StorageProvider
    fileprivate let fetchedResultsController: NSFetchedResultsController<Movie>
    
    // NOTICE is published so we can subscribe to it
    @Published var snapshot: NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?
    
    // MARK: - Initializer
    init(storageProvider: StorageProvider) {
        self.storage = storageProvider
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "popularity", ascending: false)]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                                   managedObjectContext: storageProvider.persistentContainer.viewContext,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: nil)
        
        super.init()
        
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension MoviesProvider: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        var newSnapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
        
        let idsToReload = newSnapshot.itemIdentifiers.filter { identifier in
            // Check if this identifier is in the old snapshot
            // and that it didn't move to a new oposition
            guard let oldIndex = self.snapshot?.indexOfItem(identifier),
                  let newIndex = newSnapshot.indexOfItem(identifier),
                  oldIndex == newIndex else {
                return false
            }
            
            // Check if we need to update this object
            guard (try? controller.managedObjectContext.existingObject(with: identifier))?.isUpdated == true else {
                return false
            }
            
            return true
        }
        
        newSnapshot.reloadItems(idsToReload)
        self.snapshot = newSnapshot
    }
}
