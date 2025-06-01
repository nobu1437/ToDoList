import Foundation

extension Todo{
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
    func toToDoTask() -> ToDoTask{
        let parsedDate = Todo.dateFormatter.string(from: Date())
        return ToDoTask(
            id: UUID(),
            title: todo,
            description: "some description",
            date: parsedDate,
            isCompleted: completed
        )
    }
}
