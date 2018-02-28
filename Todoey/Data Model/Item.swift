//
//  Item.swift
//  Todoey
//
//  Created by Kyle Wang on 2018-02-26.
//  Copyright © 2018 Kyle Wang. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated: Date?
    // inverse relationship with Items
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
