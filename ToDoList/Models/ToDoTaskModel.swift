import Foundation

struct ToDoTask:Identifiable{
    let id: UUID
    var title: String
    var description: String
    var date: String
    var isCompleted: Bool
    
    init(id: UUID = UUID(), title: String, description: String, date: String, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.isCompleted = isCompleted
    }
}
