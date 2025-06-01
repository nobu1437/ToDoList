import UIKit

final class ToDoTaskCell: UITableViewCell{
    static let identifier = "ToDoTaskCell"
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let dateLabel = UILabel()
    let checkmarkButton = UIButton()
    
    weak var delegate:ToDoTaskCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        contentView.backgroundColor = .black
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        descriptionLabel.font = .systemFont(ofSize: 12, weight: .regular)
        descriptionLabel.numberOfLines = 2
        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = .gray
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, dateLabel])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.alignment = .leading
        checkmarkButton.addTarget(self, action: #selector(didTapCheckmark), for: .touchUpInside)
        
        textStack.translatesAutoresizingMaskIntoConstraints = false
        checkmarkButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(checkmarkButton)
        contentView.addSubview(textStack)
        
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            contentView.heightAnchor.constraint(lessThanOrEqualToConstant: 120),
            checkmarkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            checkmarkButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            checkmarkButton.trailingAnchor.constraint(equalTo: textStack.leadingAnchor, constant: -8),
            checkmarkButton.widthAnchor.constraint(equalToConstant: 24),
            checkmarkButton.heightAnchor.constraint(equalToConstant: 24),
            checkmarkButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    @objc private func didTapCheckmark(_ sender:UIButton) {
        delegate?.ToDoTaskCellDidTapComplete(self)
    }
}
