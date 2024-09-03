import Foundation
import CoreData
import SwiftUI

extension SubscriptionModel {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubscriptionModel> {
        return NSFetchRequest<SubscriptionModel>(entityName: "SubscriptionModel")
    }

    @NSManaged public var name: String?
    @NSManaged public var price: Int64
    @NSManaged public var cycle: String?
    @NSManaged public var date: Date?
    @NSManaged public var link: String?
    @NSManaged public var category: String?
    @NSManaged public var color: NSObject?

    // Computed properties for convenience
    public var wrappedName: String {
        name ?? ""
    }

    public var wrappedCycle: String {
        cycle ?? ""
    }

    public var wrappedLink: String {
        link ?? ""
    }

    public var wrappedCategory: String {
        category ?? "Independent"
    }

    public var wrappedColor: Color {
        if let uiColor = color as? UIColor {
            return Color(uiColor)
        } else {
            return Color.blue
        }
    }
}

extension SubscriptionModel : Identifiable {
    // If you don't have a specific 'id' property, you can use the object ID
    public var id: NSManagedObjectID { objectID }
}
