import XCTest
@testable import ToDoList

final class CoreDataServiceTests: XCTestCase {
    var coreDataService: CoreDataService!
    
    override func setUp() {
        super.setUp()
        coreDataService = CoreDataService.shared
    }
    
    override func tearDown() {
        coreDataService = nil
        super.tearDown()
    }
    
    func testSaveAndFetchTask() {
        // Given
        let task = ToDoTask(
            title: "Test Task",
            description: "Test Description",
            date: "01/01/24",
            isCompleted: false
        )
        
        // When
        coreDataService.saveTask(task)
        let fetchedTasks = coreDataService.fetchTasks()
        
        // Then
        XCTAssertFalse(fetchedTasks.isEmpty)
        XCTAssertEqual(fetchedTasks.first?.title, task.title)
        XCTAssertEqual(fetchedTasks.first?.description, task.description)
        XCTAssertEqual(fetchedTasks.first?.date, task.date)
        XCTAssertEqual(fetchedTasks.first?.isCompleted, task.isCompleted)
    }
    
    func testUpdateTask() {
        // Given
        let task = ToDoTask(
            title: "Original Task",
            description: "Original Description",
            date: "01/01/24",
            isCompleted: false
        )
        coreDataService.saveTask(task)
        
        // When
        var updatedTask = task
        updatedTask.title = "Updated Task"
        updatedTask.description = "Updated Description"
        updatedTask.isCompleted = true
        coreDataService.update(task: updatedTask)
        
        // Then
        let fetchedTasks = coreDataService.fetchTasks()
        XCTAssertEqual(fetchedTasks.first?.title, "Updated Task")
        XCTAssertEqual(fetchedTasks.first?.description, "Updated Description")
        XCTAssertTrue(fetchedTasks.first?.isCompleted ?? false)
    }
    
    func testDeleteTask() {
        // Given
        let task = ToDoTask(
            title: "Task to Delete",
            description: "Will be deleted",
            date: "01/01/24",
            isCompleted: false
        )
        coreDataService.saveTask(task)
        
        // When
        coreDataService.delete(task: task)
        
        // Then
        let fetchedTasks = coreDataService.fetchTasks()
        XCTAssertTrue(fetchedTasks.isEmpty)
    }
    
    func testFetchEmptyTasks() {
        // When
        let fetchedTasks = coreDataService.fetchTasks()
        
        // Then
        XCTAssertTrue(fetchedTasks.isEmpty)
    }
} 