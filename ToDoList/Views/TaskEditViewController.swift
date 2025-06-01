import UIKit

final class TaskEditViewController: UIViewController{
    var task: ToDoTask?
    var titleTextfield = UITextField()
    var descriptionTextfield = UITextField()
    var dateLabel = UILabel()
    var isNewTask = false
    
    init(task: ToDoTask, isNew: Bool = false) {
        self.task = task
        self.isNewTask = isNew
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backToTasks()
    }
    private func setupUI(){
        navigationController?.navigationBar.tintColor = .yellow
        view.backgroundColor = .black
        titleTextfield.text = task?.title
        titleTextfield.textColor = .white
        titleTextfield.font = .systemFont(ofSize: 34, weight: .bold)
        titleTextfield.attributedPlaceholder = NSAttributedString(
            string: "Название задачи",
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        descriptionTextfield.text = task?.description
        descriptionTextfield.textColor = .white
        descriptionTextfield.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionTextfield.attributedPlaceholder = NSAttributedString(
            string: "Описание задачи",
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        dateLabel.text = task?.date
        dateLabel.textColor = .gray
        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        
        titleTextfield.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextfield.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let textStack = UIStackView(arrangedSubviews: [titleTextfield,dateLabel, descriptionTextfield ])
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textStack)
        NSLayoutConstraint.activate([
            textStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            textStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            textStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])
    }
    private func backToTasks(){
        let titleText = titleTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let descriptionText = descriptionTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let isSameTask = task?.title == titleText && task?.description == descriptionText ? true : false
        
        guard !(titleText.isEmpty && descriptionText.isEmpty) else { return }
        if isNewTask{
            let newTask = ToDoTask(id: UUID(),title: titleText, description: descriptionText, date: dateLabel.text ?? "", isCompleted: false)
            DispatchQueue.global(qos: .background).async{
                CoreDataService.shared.saveTask(newTask)
            }
        }
        else { if !isSameTask{
            let updatedTask = ToDoTask(id: task!.id, title:titleText, description: descriptionText, date: task!.date,isCompleted: task!.isCompleted)
            DispatchQueue.global(qos: .background).async{
                CoreDataService.shared.update(task: updatedTask)
            }
        } else { return }
        }
    }
}
