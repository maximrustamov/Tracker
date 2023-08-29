import UIKit

final class CategoryTableViewCell: UITableViewCell {
    
    static let identifier = "CategoryTableViewCell"
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: CategoryTableViewCell.identifier)
        setupView()
        setupLayout()
    }
    
    private func setupView() {
        self.contentView.addSubview(label)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


