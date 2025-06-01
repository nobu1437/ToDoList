import Foundation
import CoreData

final class CoreDataService {
    static let shared = CoreDataService()
    private init() {}

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yy"
        return formatter
    }()
    
    func fetchTasks() -> [ToDoTask] {
           let context = CoreDataManager.shared.context
           let request: NSFetchRequest<ToDoTaskCoreDataModel> = ToDoTaskCoreDataModel.fetchRequest()

           do {
               let tasks = try context.fetch(request)
               var todotasks: [ToDoTask] = []
               for task in tasks{
                   let toDoTask = ToDoTask(id: task.uuid,title: task.title, description: task.toDoDescription ?? "", date: task.date, isCompleted: task.completed)
                   todotasks.append(toDoTask)
               }
               return todotasks
           } catch {
               print("Ошибка при получении задач: \(error)")
               return []
           }
       }

    func saveTask(_ task: ToDoTask) {
        let context = CoreDataManager.shared.context
        let entity = ToDoTaskCoreDataModel(context: context)
        entity.uuid = task.id
        entity.title = task.title
        entity.toDoDescription = task.description
        entity.date = task.date
        entity.completed = task.isCompleted
        CoreDataManager.shared.saveContext()
    }

    func update(task: ToDoTask) {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<ToDoTaskCoreDataModel> = ToDoTaskCoreDataModel.fetchRequest()
        request.predicate = NSPredicate(format: "uuid == %@", task.id as CVarArg)

        do {
            if let existingTask = try context.fetch(request).first {
                existingTask.title = task.title
                existingTask.toDoDescription = task.description
                existingTask.date = task.date
                existingTask.completed = task.isCompleted
                CoreDataManager.shared.saveContext()
            } else {
                print("Задача с UUID \(task.id) не найдена")
            }
        } catch {
            print("Ошибка при обновлении задачи: \(error)")
        }
    }

    func delete(task: ToDoTask) {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<ToDoTaskCoreDataModel> = ToDoTaskCoreDataModel.fetchRequest()
        request.predicate = NSPredicate(format: "uuid == %@", task.id as CVarArg)
        do {
            let results = try context.fetch(request)
            print (task.title)
            if let objectToDelete = results.first {
                context.delete(objectToDelete)
                CoreDataManager.shared.saveContext()
            } else {
                print("Задача с UUID \(task.id) не найдена")
            }
        } catch {
            print("Ошибка при удалении задачи: \(error)")
        }
    }
}
