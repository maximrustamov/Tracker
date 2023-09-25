import UIKit

class StatisticsViewController: UIViewController {
    private let colors = Colors()
    private let trackerRecordStore = TrackerRecordStore()
    private var completedTrackers: [TrackerRecord] = []
    
    private lazy var titleStatistics: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.text = NSLocalizedString("statistics", tableName: "LocalizableString", comment: "statistics")
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var imageNoStatistics: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "noStatistics")
        return imageView
    }()
    
    private lazy var titleImageNoStatistics: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.text = "Анализировать пока нечего"
        label.font = .mediumSystemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var completedTrackerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var resultTitle: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var resultSubTitle: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .mediumSystemFont(ofSize: 12)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colors.viewBackgroundColor
        
        addTitleStatistics()
        addImageNoStatistics()
        addTitleImageNoStatistics()
        addCompletedTreckerView()
        addResultTitle()
        addResultSubTitle()
        trackerRecordStore.delegate = self
        updateCompletedTrackers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        completedTrackerView.setGradientBorder(width: 1, colors: [.gradientColor1, .gradientColor2, .gradientColor3])
    }
    
    private func addTitleStatistics() {
        view.addSubview(titleStatistics)
        NSLayoutConstraint.activate([
            titleStatistics.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleStatistics.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func addImageNoStatistics() {
        view.addSubview(imageNoStatistics)
        NSLayoutConstraint.activate([
            imageNoStatistics.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageNoStatistics.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageNoStatistics.widthAnchor.constraint(equalToConstant: 80),
            imageNoStatistics.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func addTitleImageNoStatistics() {
        view.addSubview(titleImageNoStatistics)
        NSLayoutConstraint.activate([
            titleImageNoStatistics.topAnchor.constraint(equalTo: imageNoStatistics.bottomAnchor, constant: 8),
            titleImageNoStatistics.centerXAnchor.constraint(equalTo: imageNoStatistics.centerXAnchor)
        ])
    }
    
    private func addCompletedTreckerView() {
        view.addSubview(completedTrackerView)
        NSLayoutConstraint.activate([
            completedTrackerView.topAnchor.constraint(equalTo: titleStatistics.bottomAnchor, constant: 77),
            completedTrackerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            completedTrackerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            completedTrackerView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    private func addResultTitle() {
        completedTrackerView.addSubview(resultTitle)
        NSLayoutConstraint.activate([
            resultTitle.topAnchor.constraint(equalTo: completedTrackerView.topAnchor, constant: 12),
            resultTitle.leadingAnchor.constraint(equalTo: completedTrackerView.leadingAnchor, constant: 12),
            resultTitle.trailingAnchor.constraint(equalTo: completedTrackerView.trailingAnchor, constant: -12),
            resultTitle.heightAnchor.constraint(equalToConstant: 41)
        ])
    }
    
    private func addResultSubTitle() {
        completedTrackerView.addSubview(resultSubTitle)
        NSLayoutConstraint.activate([
            resultSubTitle.bottomAnchor.constraint(equalTo: completedTrackerView.bottomAnchor, constant: -12),
            resultSubTitle.leadingAnchor.constraint(equalTo: completedTrackerView.leadingAnchor, constant: 12),
            resultSubTitle.trailingAnchor.constraint(equalTo: completedTrackerView.trailingAnchor, constant: -12),
            resultSubTitle.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    func updateCompletedTrackers() {
        completedTrackers = trackerRecordStore.trackerRecords
        resultTitle.text = "\(completedTrackers.count)"
        resultSubTitle.text = String.localizedStringWithFormat(NSLocalizedString("trackerCompleted", comment: "Число дней"), completedTrackers.count)
        imageNoStatistics.isHidden = completedTrackers.count > 0
        titleImageNoStatistics.isHidden = completedTrackers.count > 0
        completedTrackerView.isHidden = completedTrackers.count == 0
    }
}

extension StatisticsViewController: TrackerRecordStoreDelegate {
    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate) {
        updateCompletedTrackers()
    }
}
