import UIKit
import SoloAISDK

class BottomSheetViewController: UIViewController {

    private var sheetHeight: CGFloat = 340

    private let facesLabel = UILabel()
    private let durationLabel = UILabel()
    private let neutralLabel = UILabel()
    private let happyLabel = UILabel()
    private let sadLabel = UILabel()
    private let angryLabel = UILabel()
    private let fearfulLabel = UILabel()
    private let disgustedLabel = UILabel()
    private let surprisedLabel = UILabel()
    private let stressLabel = UILabel()
    private let wellbeingLabel = UILabel()
    private let engagementLabel = UILabel()
    private let moodLabel = UILabel()
    private let energyLabel = UILabel()
    private let interestLabel = UILabel()

    private var isSheetVisible = false {
        didSet {
            handleVisibility()
        }
    }
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.addArrangedSubviews([
            facesLabel,
            durationLabel,
            neutralLabel,
            happyLabel,
            sadLabel,
            angryLabel,
            fearfulLabel,
            disgustedLabel,
            surprisedLabel,
            stressLabel,
            wellbeingLabel,
            engagementLabel,
            moodLabel,
            energyLabel,
            interestLabel
        ])
        return stackView
    }()

    private lazy var sheetView: UIView = {
        let view = UIView()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        return view
    }()

    var handleDismiss: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSheet()
        addTapGesture()
    }

    private func setupSheet() {
        view.addSubview(sheetView)
        view.addSubview(stackView)

        sheetView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sheetView.heightAnchor.constraint(equalToConstant: sheetHeight)
        ])

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: sheetView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: sheetView.bottomAnchor, constant: -24)
        ])
    }

    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        isSheetVisible = false
    }

    private func handleVisibility() {
        if !isSheetVisible {
            dismiss(animated: true) { [weak self] in
                self?.handleDismiss?()
            }
        }
    }
}

extension BottomSheetViewController: SoloMonitoringEventDelegate {
    func monitoringEvent(event: MonitoringTracker) {
        DispatchQueue.main.async { [self] in
            facesLabel.text = "Faces: \(event.result.count)"
            durationLabel.text = "Duration: \(Int(event.monitoringDuration))s"
            neutralLabel.text = "Neutral: \(event.emotions.neutral ?? 0.0)"
            happyLabel.text = "Happy: \(event.emotions.happy ?? 0.0)"
            sadLabel.text = "Sad: \(event.emotions.sad ?? 0.0)"
            angryLabel.text = "Angry: \(event.emotions.angry ?? 0.0)"
            fearfulLabel.text = "Fearful: \(event.emotions.fearful ?? 0.0)"
            disgustedLabel.text = "Disgusted: \(event.emotions.disgusted ?? 0.0)"
            surprisedLabel.text = "Surprised: \(event.emotions.surprised ?? 0.0)"
            stressLabel.text = "Stress: \(event.emotions.stress ?? 0.0)"
            wellbeingLabel.text = "Wellbeing: \(event.emotions.wellbeing ?? 0.0)"
            engagementLabel.text = "Engagement: \(event.emotions.engagement ?? 0.0)"
            moodLabel.text = "Mood: \(event.emotions.mood ?? 0.0)"
            energyLabel.text = "Energy: \(event.emotions.energy ?? 0.0)"
            interestLabel.text = "Interest: \(event.emotions.interest ?? 0.0)"
        }
    }
}

extension UIStackView {
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach { view in
            addArrangedSubview(view)
        }
    }
}
