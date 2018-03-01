//
//  Category.swift
//  Todoey
//
//  Created by Kyle Wang on 2018-02-26.
//  Copyright © 2018 Kyle Wang. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    @objc dynamic var color : String = ""
    // forward relationship, one to many relationships with Item
    let items = List<Item>()
}

