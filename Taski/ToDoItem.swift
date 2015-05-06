//
//  ToDoItem.swift
//  Taski
//
//  Created by Truc Truong on 27/04/15.
//  Copyright (c) 2015 Truc Truong. All rights reserved.
//

import Foundation

class ToDoItem:NSObject{
    // A text description of this item.
    var text: String
    var completed: Bool
    //@NSManaged var date: NSDate
    
    
    
    
    // A Boolean value that determines the completed state of this item.
   // @NSManaged var completed: NSNumber
    
    
    // Returns a ToDoItem initialized with the given text and default completed value.
    init(text: String) {
        self.text = text
        self.completed = false
    }
}