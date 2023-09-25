import UIKit

final class TrackersVC: UIViewController {
    private let analyticsService = AnalyticsService()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerStore = TrackerStore()
    private let colors = Colors()
    private let titleTrackers = NSLocalizedString("trackersTitle", tableName: "LocalizableString", comment: "Title Trackers")
    private let filtersButtonTitle = NSLocalizedString("filters", tableName: "LocalizableString", comment: "Title Trackers")
    private let stubTitle = NSLocalizedString("stubTitle", tableName: "LocalizableString", comment: "stubTitle")
    private let nothingFound = NSLocalizedString("nothingFound", tableName: "LocalizableString", comment: "nothingFound")
    private let search = NSLocalizedString("search", tableName: "LocalizableString", comment: "search")
    private let cancel = NSLocalizedString("cancel", tableName: "LocalizableString", comment: "cancel")
   
    //трекеры, которые были «выполнены» в выбранную дату
    private var completedTrackers: [TrackerRecord] = []
    
    //отображается при поиске и/или изменении дня недели
    private var visibleCategories: [TrackerCategoryModel] = []
    private var pinnedTrackers: [Tracker] = []
    private var currentDate: Int?
    private var searchText: String = ""
    private var widthAnchor: NSLayoutConstraint?
    private var selectedFilter: Filter?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .ypBlack
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "star")
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.text = stubTitle
        label.font = .mediumSystemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.backgroundColor = .datePickerColor
        datePicker.layer.cornerRadius = 8
        datePicker.tintColor = .ypBlack
        datePicker.overrideUserInterfaceStyle = .light
        datePicker.layer.masksToBounds = true
        
        return datePicker
    }()
    
    private lazy var searchTextField: UITextField = {
        let searchTextField = UITextField()
        searchTextField.placeholder = search
        searchTextField.textColor = .ypBlack
        searchTextField.font = .systemFont(ofSize: 17)
        searchTextField.backgroundColor = .searchTextFieldColor
        searchTextField.layer.cornerRadius = 10
        searchTextField.indent(size: 30)
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        searchTextField.delegate = self
        return searchTextField
    }()
    
    private lazy var loupeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "loupe")
        return imageView
    }()
    
    private lazy var cancelEditingButton: UIButton = {
        let button = UIButton()
        button.setTitle(search, for: .normal)
        button.setTitleColor(.ypBlue, for: .normal)
        button.layer.cornerRadius = 17
        button.addTarget(self, action: #selector(cancelEditingButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton()
        button.setTitle(filtersButtonTitle, for: .normal)
        button.backgroundColor = .ypBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17.0, weight: .regular)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filtersButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var collectionView: UICollectionView = {
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
        analyticsService.report(event: .open, params: ["Screen" : "Main"])
        print("Event: open")
        view.backgroundColor = colors.viewBackgroundColor
        setDayOfWeek()
        updateCategories(with: trackerCategoryStore.trackerCategories)
        completedTrackers = trackerRecordStore.trackerRecords
        makeNavBar()
        addSubviews()
        setupLayoutSearchTextFieldAndButton()
        setupLayout()
        trackerCategoryStore.delegate = self
        trackerStore.delegate = self
        trackerRecordStore.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: .close, params: ["Screen" : "Main"])
        print("Event: close")
    }
    private func makeNavBar() {
        if let navBar = navigationController?.navigationBar {
            title = titleTrackers
            let leftButton = UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(addTracker)
            )
            leftButton.tintColor = .ypBlack
            
            navBar.topItem?.setLeftBarButton(leftButton, animated: false)
            datePicker.preferredDatePickerStyle = .compact
            datePicker.datePickerMode = .date
            datePicker.accessibilityLabel = dateFormatter.string(from: datePicker.date)
            
            let rightButton = UIBarButtonItem(customView: datePicker)
            datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
            rightButton.accessibilityLabel = dateFormatter.string(from: datePicker.date)
            rightButton.customView?.tintColor = .ypBlue
            navBar.topItem?.setRightBarButton(rightButton, animated: false)
            navBar.prefersLargeTitles = true
        }
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let components = Calendar.current.dateComponents([.weekday], from: sender.date)
        if let day = components.weekday {
            currentDate = day
            updateCategories(with: trackerCategoryStore.trackerCategories)
        }
    }
    
    @objc func addTracker() {
        let trackersVC = RegularOrIrregularEventVC()
        trackersVC.delegate = self
        present(trackersVC, animated: true)
        analyticsService.report(event: .click, params: ["Screen" : "Main", "Item" : Items.add_track.rawValue])
        print("Event: add_track")
    }
    
    @objc private func cancelEditingButtonAction() {
        searchTextField.text = ""
        widthAnchor?.constant = 0
        setupLayout()
        searchText = ""
    }
    
    @objc private func filtersButtonAction() {
        analyticsService.report(event: .click, params: ["Screen" : "Main", "Item" : Items.filter.rawValue])
        print("Event: filter")
        let filtersVC = FiltersVC()
        filtersVC.delegate = self
        filtersVC.selectedFilter = selectedFilter
        present(filtersVC, animated: true)
    }
    
    private func addSubviews() {
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(searchTextField)
        searchTextField.addSubview(loupeImageView)
        view.addSubview(cancelEditingButton)
        view.addSubview(collectionView)
        collectionView.addSubview(activityIndicator)
        view.addSubview(filtersButton)
    }
    
    private func setupLayoutSearchTextFieldAndButton() {
        widthAnchor = cancelEditingButton.widthAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: cancelEditingButton.leadingAnchor, constant: -5),
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            
            loupeImageView.heightAnchor.constraint(equalToConstant: 16),
            loupeImageView.widthAnchor.constraint(equalToConstant: 16),
            loupeImageView.leadingAnchor.constraint(equalTo: searchTextField.leadingAnchor, constant: 8),
            loupeImageView.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor),
            
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
            
            activityIndicator.widthAnchor.constraint(equalToConstant: 51),
            activityIndicator.heightAnchor.constraint(equalToConstant: 51),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -17),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.widthAnchor.constraint(equalToConstant: 114)
        ])
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setDayOfWeek() {
        let components = Calendar.current.dateComponents([.weekday], from: Date())
        currentDate = components.weekday
    }
    
    private func updateCategories(with categories: [TrackerCategoryModel]) {
        var newCategories: [TrackerCategoryModel] = []
        var pinnedTrackers: [Tracker] = []
        activityIndicator.startAnimating()
        for category in categories {
            var newTrackers: [Tracker] = []
            for tracker in category.visibleTrackers(filterString: searchText, pin: nil) {
                guard let schedule = tracker.schedule else { return }
                let scheduleInts = schedule.map { $0.numberOfDay }
                if let day = currentDate, scheduleInts.contains(day) {
                    if selectedFilter == .completed {
                        if !completedTrackers.contains(where: { record in
                            record.idTracker == tracker.id &&
                            record.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
                        }) {
                            continue
                        }
                    }
                    if selectedFilter == .uncompleted {
                        if completedTrackers.contains(where: { record in
                            record.idTracker == tracker.id &&
                            record.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
                        }) {
                            continue
                        }
                    }
                    if tracker.pinned == true {
                        pinnedTrackers.append(tracker)
                    } else {
                        newTrackers.append(tracker)
                    }
                }
            }
            if newTrackers.count > 0 {
                let newCategory = TrackerCategoryModel(name: category.name, trackers: newTrackers)
                newCategories.append(newCategory)
            }
        }
        visibleCategories = newCategories
        
        self.pinnedTrackers = pinnedTrackers
        collectionView.reloadData()
        activityIndicator.stopAnimating()
    }
    
    func deleteTracker(_ tracker: Tracker) {
        try? self.trackerStore.deleteTracker(tracker)
    }
    
    private func actionSheet(trackerToDelete: Tracker) {
        let alert = UIAlertController(title: "Уверены, что хотите удалить трекер?",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Удалить",
                                      style: .destructive) { [weak self] _ in
            self?.deleteTracker(trackerToDelete)
        })
        alert.addAction(UIAlertAction(title: "Отменить",
                                      style: .cancel) { _ in
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func makeContextMenu(_ indexPath: IndexPath) -> UIMenu {
        let tracker: Tracker
        if indexPath.section == 0 {
            tracker = pinnedTrackers[indexPath.row]
        } else {
            tracker = visibleCategories[indexPath.section - 1].visibleTrackers(filterString: searchText, pin: false)[indexPath.row]
        }
        let pinTitle = tracker.pinned == true ? "Открепить" : "Закрепить"
        let pin = UIAction(title: pinTitle, image: nil) { [weak self] action in
            try? self?.trackerStore.togglePinTracker(tracker)
        }
        let rename = UIAction(title: "Редактировать", image: nil) { [weak self] action in
            self?.analyticsService.report(event: .click, params: ["Screen" : "Main", "Item" : Items.edit.rawValue])
            print("Event: edit")
            let editTrackerVC = CreateEventVC(.regular)
            editTrackerVC.editTracker = tracker
            editTrackerVC.editTrackerDate = self?.datePicker.date ?? Date()
            editTrackerVC.category = tracker.category
            self?.present(editTrackerVC, animated: true)
        }
        let delete = UIAction(title: "Удалить", image: nil, attributes: .destructive) { [weak self] action in
            self?.actionSheet(trackerToDelete: tracker)
            self?.analyticsService.report(event: .click, params: ["Screen" : "Main", "Item" : Items.delete.rawValue])
            print("Event: delete")
        }
        return UIMenu(children: [pin, rename, delete])
    }
}

extension TrackersVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = visibleCategories.count
        collectionView.isHidden = count == 0 && pinnedTrackers.count == 0
        filtersButton.isHidden = collectionView.isHidden && selectedFilter == nil
        return count + 1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if section == 0 {
            return pinnedTrackers.count
        } else {
            return visibleCategories[section - 1].visibleTrackers(filterString: searchText, pin: false).count
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.identifier, for: indexPath) as? TrackersCollectionViewCell else { return UICollectionViewCell() }
        cell.delegate = self
        let tracker: Tracker
        if indexPath.section == 0 {
            tracker = pinnedTrackers[indexPath.row]
        } else {
            tracker = visibleCategories[indexPath.section - 1].visibleTrackers(filterString: searchText, pin: false)[indexPath.row]
        }
         
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
            completedCount: completedCount,
            pinned: tracker.pinned ?? false
        )
        return cell
    }
}

extension TrackersVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: (self.collectionView.bounds.width - 7) / 2, height: 148)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 7
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
        if indexPath.section == 0 {
            view.titleLabel.text = "Закрепленные"
        } else {
            view.titleLabel.text = visibleCategories[indexPath.section - 1].name
        }
        
        return view
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if section == 0 && pinnedTrackers.count == 0 {
            return .zero
        }
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
}

extension TrackersVC: RegularOrIrregularEventVCDelegate {
    
    func createTracker(
        _ tracker: Tracker, categoryName: String
    ) {
        var categoryToUpdate: TrackerCategoryModel?
        let categories: [TrackerCategoryModel] = trackerCategoryStore.trackerCategories
        for i in 0..<categories.count {
            if categories[i].name == categoryName {
                categoryToUpdate = categories[i]
            }
        }
        if categoryToUpdate != nil {
            try? trackerCategoryStore.addTracker(tracker, to: categoryToUpdate!)
        } else {
            let newCategory = TrackerCategoryModel(name: categoryName, trackers: [tracker])
            categoryToUpdate = newCategory
            try? trackerCategoryStore.addNewTrackerCategory(categoryToUpdate!)
        }
        dismiss(animated: true)
    }
}

extension TrackersVC {
    
    @objc func textFieldChanged() {
        searchText = searchTextField.text ?? ""
        imageView.image = searchText.isEmpty ? UIImage(named: "star") : UIImage(named: "notFound")
        label.text = searchText.isEmpty ? stubTitle : nothingFound
        widthAnchor?.constant = 85
        updateCategories(with: trackerCategoryStore.predicateFetch(nameTracker: searchText))
    }
    

}

extension TrackersVC: TrackersCollectionViewCellDelegate {
    
    func completedTracker(id: UUID) {
        if let index = completedTrackers.firstIndex(where: { record in
            record.idTracker == id &&
            record.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
        }) {
            completedTrackers.remove(at: index)
            try? trackerRecordStore.deleteTrackerRecord(with: id, date: datePicker.date)
        } else {
            completedTrackers.append(TrackerRecord(idTracker: id, date: datePicker.date))
            try? trackerRecordStore.addNewTrackerRecord(TrackerRecord(idTracker: id, date: datePicker.date))
            analyticsService.report(event: .click, params: ["Screen" : "Main", "Item" : Items.track.rawValue])
            print("Event: track")
        }
        updateCategories(with: trackerCategoryStore.trackerCategories)
    }
}

extension TrackersVC: UITextFieldDelegate {
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    internal override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        widthAnchor?.constant = 85
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        setupLayoutSearchTextFieldAndButton()
    }
}

extension TrackersVC: TrackerCategoryStoreDelegate {
    
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        updateCategories(with: trackerCategoryStore.trackerCategories)
        collectionView.reloadData()
    }
}

extension TrackersVC: TrackerStoreDelegate {
    
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
        updateCategories(with: trackerCategoryStore.trackerCategories)
        collectionView.reloadData()
    }
}

extension TrackersVC: TrackerRecordStoreDelegate {
    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate) {
        completedTrackers = trackerRecordStore.trackerRecords
        collectionView.reloadData()
    }
}

extension TrackersVC: UICollectionViewDelegate {
    func collectionView(
         _ collectionView: UICollectionView,
         contextMenuConfigurationForItemAt indexPath: IndexPath,
         point: CGPoint
     ) -> UIContextMenuConfiguration? {
         let identifier = "\(indexPath.row):\(indexPath.section)" as NSString
         return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) {
             suggestedActions in
              return self.makeContextMenu(indexPath)
         }
     }
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let identifier = configuration.identifier as? String else { return nil }
        let components = identifier.components(separatedBy: ":")
        print(identifier)
        guard let rowString = components.first,
              let sectionString = components.last,
              let row = Int(rowString),
              let section = Int(sectionString) else { return nil }
        let indexPath = IndexPath(row: row, section: section)
                
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackersCollectionViewCell else { return nil }
        
        return UITargetedPreview(view: cell.menuView)
    }
}

extension TrackersVC: FiltersVCDelegate {
    func filterSelected(filter: Filter) {
        selectedFilter = filter
        searchText = ""
        switch filter {
        case .all:
            updateCategories(with: trackerCategoryStore.trackerCategories)
        case .today:
            datePicker.date = Date()
            dateChanged(datePicker)
            updateCategories(with: trackerCategoryStore.trackerCategories)            
        case .completed:
            updateCategories(with: trackerCategoryStore.trackerCategories)
        case .uncompleted:
            updateCategories(with: trackerCategoryStore.trackerCategories)
        }
    }
}

extension UIDatePicker {

    var textColor: UIColor? {
        set {
            setValue(newValue, forKeyPath: "textColor")
        }
        get {
            return value(forKeyPath: "textColor") as? UIColor
        }
    }

}
