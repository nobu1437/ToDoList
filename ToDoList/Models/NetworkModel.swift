import Foundation

struct NetworkModel:Codable {
    let todos: [Todo]
}

struct Todo: Codable{
    let id: Int
    let todo: String
    let completed: Bool
}
