//
//  BowTie+CoreDataProperties.swift
//  BowTies
//
//  Created by Andrew Cheberyako on 20.04.2021.
//
//

import UIKit
import CoreData


extension BowTie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BowTie> {
        return NSFetchRequest<BowTie>(entityName: "BowTie")
    }

    @NSManaged public var isFavorite: Bool
    @NSManaged public var lastWorn: Date?
    @NSManaged public var name: String?
    @NSManaged public var rating: Double
    @NSManaged public var searchKey: String?
    @NSManaged public var timesWorn: Int32
    @NSManaged public var photoData: Data?
    @NSManaged public var tintColor: UIColor?

}

extension BowTie : Identifiable {

}
