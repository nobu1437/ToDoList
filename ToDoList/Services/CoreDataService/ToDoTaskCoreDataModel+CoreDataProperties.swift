//
//  ToDoTaskCoreDataModel+CoreDataProperties.swift
//  ToDoList
//
//  Created by Andrey Nobu on 26.05.2025.
//
//

import Foundation
import CoreData


extension ToDoTaskCoreDataModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoTaskCoreDataModel> {
        return NSFetchRequest<ToDoTaskCoreDataModel>(entityName: "ToDoTaskCoreDataModel")
    }

    @NSManaged public var title: String
    @NSManaged public var toDoDescription: String?
    @NSManaged public var uuid: UUID
    @NSManaged public var date: String
    @NSManaged public var completed: Bool

}

extension ToDoTaskCoreDataModel : Identifiable {

}
