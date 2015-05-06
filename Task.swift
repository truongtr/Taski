//
//  Task.swift
//  Taski
//
//  Created by Truc Truong on 04/05/15.
//  Copyright (c) 2015 Truc Truong. All rights reserved.
//

import Foundation
import CoreData

class Task: NSManagedObject {

    @NSManaged var text: String
    @NSManaged var completed: NSNumber

}
