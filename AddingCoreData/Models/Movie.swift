import CoreData

public class Movie: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }
    
    @NSManaged public var releaseDate: Date?
    @NSManaged public var title: String
    @NSManaged public var duration: Int64
    @NSManaged public var watched: Bool
    @NSManaged public var rating: Double
}
