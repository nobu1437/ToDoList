import Foundation

final class NetworkService{
    static let shared = NetworkService()
    private var task: URLSessionTask?
    private init(){}
    func fetchTodos(_ completion: @escaping (Result<NetworkModel,Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            assertionFailure("[NetworkService Error]: WrongURL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = HttpConstants.get.rawValue
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<NetworkModel, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let task):
                print (task)
                completion(.success(task))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
}

