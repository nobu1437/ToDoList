import XCTest
@testable import ToDoList

final class NetworkServiceTests: XCTestCase {
    var networkService: NetworkService!
    
    override func setUp() {
        super.setUp()
        networkService = NetworkService.shared
    }
    
    override func tearDown() {
        networkService = nil
        super.tearDown()
    }
    
    func testFetchTodos() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch todos from API")
        
        // When
        networkService.fetchTodos { result in
            // Then
            switch result {
            case .success(let response):
                XCTAssertFalse(response.todos.isEmpty)
                XCTAssertNotNil(response.todos.first?.id)
                XCTAssertNotNil(response.todos.first?.todo)
                XCTAssertNotNil(response.todos.first?.completed)
            case .failure(let error):
                XCTFail("Failed to fetch todos: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testTodoToToDoTaskConversion() {
        // Given
        let todo = Todo(id: 1, todo: "Test Todo", completed: false)
        
        // When
        let toDoTask = todo.toToDoTask()
        
        // Then
        XCTAssertEqual(toDoTask.title, "Test Todo")
        XCTAssertEqual(toDoTask.description, "some description")
        XCTAssertFalse(toDoTask.isCompleted)
        XCTAssertNotNil(toDoTask.date)
    }
} 