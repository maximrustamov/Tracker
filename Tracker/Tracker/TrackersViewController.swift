import UIKit

final class TrackersViewController: UIViewController {
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    

    private var categories: [TrackerCategory] = []//MockData.categories
    

    private var completedTrackers: [TrackerRecord] = []
    

    private var visibleCategories: [TrackerCategory] = []
    private var currentDate: Int?
    private var searchText: String = ""
    private var widthAnchor: NSLayoutConstraint?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "star")
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var datePicker = UIDatePicker()
    
    private lazy var searchTextField: UISearchTextField = {
        let searchTextField = UISearchTextField()
        searchTextField.placeholder = "Поиск"
        searchTextField.textColor = .ypBlack
        searchTextField.font = .systemFont(ofSize: 17)
        searchTextField.backgroundColor = .searchColor
        searchTextField.layer.cornerRadius = 10
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        searchTextField.delegate = self
        return searchTextField
    }()
    
    private lazy var cancelEditingButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypBlue, for: .normal)
        button.layer.cornerRadius = 17
        button.addTarget(self, action: #selector(cancelEditingButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(TrackersCollectionViewCell.self,
                                forCellWithReuseIdentifier: TrackersCollectionViewCell.identifier)
        collectionView.register(TrackersSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackersSupplementaryView.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setDayOfWeek()
        updateCategories()
        completedTrackers = try! self.trackerRecordStore.fetchTrackerRecord()
        makeNavBar()
        addSubviews()
        setupLayoutsearchTextFieldAndButton()
        setupLayout()
        trackerCategoryStore.delegate = self
    }
    
    private func makeNavBar() {
        if let navBar = navigationController?.navigationBar {
            title = "Трекеры"
            let leftButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTracker))
            leftButton.tintColor = .black
            navBar.topItem?.setLeftBarButton(leftButton, animated: false)
            datePicker.preferredDatePickerStyle = .compact
            datePicker.datePickerMode = .date
            datePicker.locale = Locale(identifier: "ru_RU")
            datePicker.accessibilityLabel = dateFormatter.string(from: datePicker.date)
            let rightButton = UIBarButtonItem(customView: datePicker)
            datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
            rightButton.accessibilityLabel = dateFormatter.string(from: datePicker.date)
            navBar.topItem?.setRightBarButton(rightButton, animated: false)
            navBar.prefersLargeTitles = true
        }
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let components = Calendar.current.dateComponents([.weekday], from: sender.date)
        if let day = components.weekday {
            currentDate = day
            updateCategories()
        }
    }
    
    @objc func addTracker() {
        let trackersVC = CreateTrackerVC()
        trackersVC.delegate = self
        present(trackersVC, animated: true)
    }
    
    @objc private func cancelEditingButtonAction() {
        searchTextField.text = ""
        widthAnchor?.constant = 0
        setupLayout()
        searchText = ""
        updateCategories()
    }
    
    private func addSubviews() {
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(searchTextField)
        view.addSubview(cancelEditingButton)
        view.addSubview(collectionView)
    }
    
    private func setupLayoutsearchTextFieldAndButton() {
        widthAnchor = cancelEditingButton.widthAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: cancelEditingButton.leadingAnchor, constant: -5),
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            
            cancelEditingButton.centerXAnchor.constraint(equalTo: searchTextField.centerXAnchor),
            cancelEditingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            widthAnchor!,
            cancelEditingButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
        ])
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 400),
            
            label.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setDayOfWeek() {
        let components = Calendar.current.dateComponents([.weekday], from: Date())
        currentDate = components.weekday
    }
    
    private func updateCategories() {
        var newCategories: [TrackerCategory] = []
        visibleCategories = trackerCategoryStore.trackerCategories
        for category in visibleCategories {
            var newTrackers: [Tracker] = []
            for tracker in category.visibleTrackers(filterString: searchText) {
                guard let schedule = tracker.schedule else { return }
                let scheduleInts = schedule.map { $0.numberOfDay }
                if let day = currentDate, scheduleInts.contains(day) {
                    newTrackers.append(tracker)
                }
            }
            if newTrackers.count > 0 {
                let newCategory = TrackerCategory(name: category.name, trackers: newTrackers)
                newCategories.append(newCategory)
            }
        }
        visibleCategories = newCategories
        collectionView.reloadData()
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = visibleCategories.count
        collectionView.isHidden = count == 0
        return count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return visibleCategories[section].visibleTrackers(filterString: searchText).count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.identifier, for: indexPath) as? TrackersCollectionViewCell else { return UICollectionViewCell() }
        cell.delegate = self
        let tracker = visibleCategories[indexPath.section].visibleTrackers(filterString: searchText)[indexPath.row]
        let isCompleted = completedTrackers.contains(where: { record in
            record.idTracker == tracker.id &&
            record.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
        })
        let isEnabled = datePicker.date < Date() || Date().yearMonthDayComponents == datePicker.date.yearMonthDayComponents
        let completedCount = completedTrackers.filter({ record in
            record.idTracker == tracker.id
        }).count
        cell.configure(
            tracker.id,
            name: tracker.name,
            color: tracker.color ?? .ypBlue,
            emoji: tracker.emoji ?? "",
            isCompleted: isCompleted,
            isEnabled: isEnabled,
            completedCount: completedCount
        )
        return cell
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 167, height: 148)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 10
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 10
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? TrackersSupplementaryView else { return UICollectionReusableView() }
        view.titleLabel.text = visibleCategories[indexPath.section].name
        return view
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
}

extension TrackersViewController: CreateTrackerVCDelegate {
    
    func createTracker(
        _ tracker: Tracker, categoryName: String
    ) {
        var categoryToUpdate: TrackerCategory?
        let categories: [TrackerCategory] = trackerCategoryStore.trackerCategories
        for i in 0..<categories.count {
            if categories[i].name == categoryName {
                categoryToUpdate = categories[i]
            }
        }
        if categoryToUpdate != nil {
            try? trackerCategoryStore.addTracker(tracker, to: categoryToUpdate!)
        } else {
            let newCategory = TrackerCategory(name: categoryName, trackers: [tracker])
            categoryToUpdate = newCategory
            try? trackerCategoryStore.addNewTrackerCategory(categoryToUpdate!)
        }
        updateCategories()
        dismiss(animated: true)
    }
}

extension TrackersViewController {
    
    @objc func textFieldChanged() {
        searchText = searchTextField.text ?? ""
        imageView.image = searchText.isEmpty ? UIImage(named: "star") : UIImage(named: "notFound")
        label.text = searchText.isEmpty ? "Что будем отслеживать?" : "Ничего не найдено"
        widthAnchor?.constant = 85
        visibleCategories = trackerCategoryStore.predicateFetch(nameTracker: searchText)
        collectionView.reloadData()
    }
}

extension TrackersViewController: TrackersCollectionViewCellDelegate {
    
    func completedTracker(id: UUID) {
        if let index = completedTrackers.firstIndex(where: { record in
            record.idTracker == id &&
            record.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
        }) {
            completedTrackers.remove(at: index)
            try? trackerRecordStore.deleteTrackerRecord(TrackerRecord(idTracker: id, date: datePicker.date))
        } else {
            completedTrackers.append(TrackerRecord(idTracker: id, date: datePicker.date))
            try? trackerRecordStore.addNewTrackerRecord(TrackerRecord(idTracker: id, date: datePicker.date))
        }
        collectionView.reloadData()
    }
}

extension TrackersViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        widthAnchor?.constant = 85
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        setupLayoutsearchTextFieldAndButton()
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        visibleCategories = trackerCategoryStore.trackerCategories
        collectionView.reloadData()
    }
}
