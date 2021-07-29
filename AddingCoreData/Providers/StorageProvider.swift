import CoreData

protocol StorageProviderContract {
    func saveMovie(named name: String)
    func getAllMovies() -> [Movie]
    func deleteMovie(_ movie: Movie) throws
    func updateMovies()
}

enum StorageProviderError: Error {
    case couldNotSaveChanges
}

class StorageProvider {
    let persistentContainer: NSPersistentContainer
    
    init() {
        // Preferred to be set before initializing the persistent container
        ValueTransformer.setValueTransformer(UIImageTransformer(), forName: NSValueTransformerName("UIImageTransformer"))
        
        // Needs to be the name of the model file
        persistentContainer = NSPersistentContainer(name: "Model")
        
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data store failed to load with error \(error)")
            }
        }
    }
}

extension StorageProvider: StorageProviderContract {
    func saveMovie(named name: String) {
        let movie = Movie(context: persistentContainer.viewContext)
        movie.title = name
        
        do {
            try persistentContainer.viewContext.save()
            print("Movie Saved Successfully")
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to save movie: \(error)")
        }
    }
    
    func getAllMovies() -> [Movie] {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch movies: \(error)")
            return []
        }
    }
    
    func deleteMovie(_ movie: Movie) throws {
        persistentContainer.viewContext.delete(movie)
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to save context: \(error)")
            throw StorageProviderError.couldNotSaveChanges
        }
    }
    
    func updateMovies() {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to save context: \(error)")
        }
    }
}
