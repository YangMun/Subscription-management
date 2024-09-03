import CoreData
import SwiftUI

class PersistenceController {
    static let shared = PersistenceController()

    // Preview instance for SwiftUI Previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        controller.addSampleData(context: controller.container.viewContext)
        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model") // Name should match your .xcdatamodeld file
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    var context: NSManagedObjectContext {
        return container.viewContext
    }

    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func addSampleData(context: NSManagedObjectContext) {
        let sampleSubscriptions = [
            ("Netflix", 13900, "월별", Date(), "https://www.netflix.com", "Entertainment", UIColor.red),
            ("Spotify", 10900, "월별", Date(), "https://www.spotify.com", "Music", UIColor.green)
        ]
        
        for (name, price, cycle, date, link, category, color) in sampleSubscriptions {
            let newSubscription = SubscriptionModel(context: context)
            newSubscription.name = name
            newSubscription.price = Int64(price)
            newSubscription.cycle = cycle
            newSubscription.date = date
            newSubscription.link = link
            newSubscription.category = category
            newSubscription.color = color
        }

        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
