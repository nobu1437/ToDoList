import UIKit

final class TaskViewController: UIViewController {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
    
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let toolbar = UIToolbar()
    private let titleLabel = UILabel()
    private var countItem: UIBarButtonItem!
    
    var todos: [ToDoTask] = []
    var searchTodos: [ToDoTask] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTodos()
        updateToolbarCount()
        tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.reloadData()
        updateToolbarCount()
    }
    
    private func loadTodos(){
        if UserDefaults.standard.isFirstLaunch {
            loadTodosFromNetwork()
            UserDefaults.standard.isFirstLaunch = false
        }else {
            DispatchQueue.global(qos: .background).async{ [weak self] in
                guard let self = self else { return }
                var tasks = CoreDataService.shared.fetchTasks()
                tasks.sort{
                    guard let date1 = TaskViewController.dateFormatter.date(from: $0.date),
                          let date2 = TaskViewController.dateFormatter.date(from: $1.date) else {
                        return false
                    }
                    return date1 > date2 
                }
                DispatchQueue.main.async{
                    self.todos = tasks
                    self.tableView.reloadData()
                    self.updateToolbarCount()
                }
            }
        }
        self.searchTodos = self.todos
    }
    
    private func updateToolbarCount() {
        countItem.title = "\(todos.count) Задач"
    }
    private func setupUI(){
        setupTitleLabel()
        setupSearchBar()
        setupToolbar()
        setupTableView()
        view.backgroundColor = .black
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
    }
    private func setupTableView(){
        tableView.backgroundColor = .black
        tableView.register(ToDoTaskCell.self, forCellReuseIdentifier: ToDoTaskCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .darkGray
        tableView.keyboardDismissMode = .onDrag
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        ])
    }
    
    private func setupSearchBar(){
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = .white
        searchBar.barStyle = .black
        searchBar.placeholder = "Search"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    private func setupToolbar(){
        toolbar.barStyle = .black
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        countItem = UIBarButtonItem(title: "\(todos.count) Задач", style: .plain, target: nil, action: nil)
        countItem.tintColor = .white
        let addItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addTask))
        addItem.tintColor = .yellow
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spacer, countItem, spacer, addItem], animated: false)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    private func setupTitleLabel(){
        titleLabel.text = "Задачи"
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = .white
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        ])
    }
    @objc private func addTask(){
        let parsedDate = TaskViewController.dateFormatter.string(from: Date())
        let task = ToDoTask(title: "", description: "", date: parsedDate, isCompleted: false)
        let editVC = TaskEditViewController(task: task, isNew: true)
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    
    private func loadTodosFromNetwork(){
        NetworkService.shared.fetchTodos{[weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.todos = response.todos.compactMap {$0.toToDoTask()}
                DispatchQueue.global(qos: .background).async{ [weak self] in
                    guard let self = self else { return }
                    for todo in self.todos {
                        CoreDataService.shared.saveTask(todo)
                    }
                    DispatchQueue.main.async{
                        self.updateToolbarCount()
                        self.tableView.reloadData()
                    }
                }
            case .failure(let error):
                print (error)
            }
        }
    }
}

extension TaskViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ToDoTaskCell.identifier , for: indexPath)
        guard let toDoTaskCell = cell as? ToDoTaskCell else { return UITableViewCell() }
        configCell(for: toDoTaskCell, with: indexPath)
        toDoTaskCell.delegate = self
        return toDoTaskCell
    }
}

extension TaskViewController {
    func configCell(for cell: ToDoTaskCell, with indexPath: IndexPath) {
        let task = todos[indexPath.row]
        cell.titleLabel.attributedText = NSAttributedString(string: task.title, attributes: [
            .strikethroughStyle: task.isCompleted ? NSUnderlineStyle.single.rawValue : 0,
            .foregroundColor: task.isCompleted ? UIColor.gray : UIColor.white
        ])
        cell.descriptionLabel.text = task.description
        cell.descriptionLabel.textColor = task.isCompleted ? .gray : .white
        cell.dateLabel.text = task.date
        cell.checkmarkButton.tintColor = task.isCompleted ? .yellow : .gray
        cell.checkmarkButton.setImage(UIImage(systemName: task.isCompleted ? "checkmark.circle" : "circle"), for: .normal)
    }
}

extension TaskViewController: ToDoTaskCellDelegate{
    func ToDoTaskCellDidTapComplete(_ cell: ToDoTaskCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        todos[indexPath.row].isCompleted.toggle()
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            CoreDataService.shared.update(task: self.todos[indexPath.row])
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
}
extension TaskViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let task = todos[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let shareAction = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                let textToShare = task.title
                let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
                if let popoverController = activityVC.popoverPresentationController {
                    popoverController.sourceView = tableView.cellForRow(at: indexPath)
                    popoverController.sourceRect = tableView.cellForRow(at: indexPath)?.bounds ?? CGRect.zero
                }
                self.present(activityVC, animated: true)
            }
            
            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                let editVC = TaskEditViewController(task: task, isNew: false)
                self.navigationController?.pushViewController(editVC, animated: true)
            }
            
            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                guard let self = self else { return }
                print("Delete action triggered for task: \(task.title)")
                print("Task UUID: \(task.id)")
                DispatchQueue.global(qos: .background).async { [weak self] in
                    guard let self = self else { return }
                    CoreDataService.shared.delete(task: task)
                    DispatchQueue.main.async {
                        self.todos.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        self.updateToolbarCount()
                        print("Task removed from UI")
                    }
                }
            }
            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = todos[indexPath.row]
        let editVC = TaskEditViewController(task: task, isNew: false)
        navigationController?.pushViewController(editVC, animated: true)
    }
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.contentView.backgroundColor = .gray
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.contentView.backgroundColor = .black
        }
    }
}
extension TaskViewController:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            todos = searchTodos
        } else {
            todos = searchTodos.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
        updateToolbarCount()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
