//
//  CityStored+CoreDataProperties.swift
//  WeatherApp
//
//  Created by Mariam Tsikarishvili on 23.02.25.
//
//

import Foundation
import CoreData


extension CityStored {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CityStored> {
        return NSFetchRequest<CityStored>(entityName: "CityStored")
    }

    @NSManaged public var name: String?

}

extension CityStored : Identifiable {

}
