//
//  MonitoringViewController.swift
//  SoloAISDK_Example
//
//  Created by Evgeniy on 08.08.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import SoloAISDK

class MonitoringViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var showInfoBtn: UIButton!
    @IBOutlet weak var emotionLabel: UILabel!
    
    var solo: Solo!
    var monitoring: SoloMonitoring!
    private var isControllerPresented = false

    override func viewDidLoad() {
        super.viewDidLoad()
        monitoring = solo.createMonitoring()
        displayController(vc: monitoring)
        setMonitoringStarted(false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        setMonitoringStarted(false)
        hideController(vc: monitoring)
    }

    @IBAction func startMonitoring(_ sender: UIButton) {
        setMonitoringStarted(true)
    }

    @IBAction func stopMonitoring(_ sender: UIButton) {
        setMonitoringStarted(false)
    }

    @IBAction func showInfo(_ sender: UIButton) {
        let bottomSheetVC = BottomSheetViewController()
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        solo.addMonitoringEventListener(bottomSheetVC)
        bottomSheetVC.handleDismiss = { [weak self] in
            self?.solo.removeMonitoringEventListener(bottomSheetVC)
        }
        present(bottomSheetVC, animated: true)
    }

    private func setMonitoringStarted(_ isStarted: Bool) {
        self.startBtn.isEnabled = !isStarted
        self.stopBtn.isEnabled = isStarted
        self.showInfoBtn.isEnabled = isStarted

        if (isStarted) {
            solo.cameraDelegate = self
            //displayController(vc: controller)
            monitoring.startMonitoring()
            print("Start Monitoring")
        } else {
            //hideController(vc: controller)
            solo.cameraDelegate = nil
            solo.removeAllMonitoringEventListeners()
            monitoring.stopMonitoring()
            print("Stop Monitoring")
        }
    }

    private func displayController(vc: UIViewController) {
        if !isControllerPresented {
            addChild(vc)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(vc.view)
            NSLayoutConstraint.activate([
                vc.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                vc.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                vc.view.topAnchor.constraint(equalTo: containerView.topAnchor),
                vc.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            ])
            vc.didMove(toParent: self)
            isControllerPresented = true
        }
    }

    private func hideController(vc: UIViewController) {
        if isControllerPresented {
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
            isControllerPresented = false
        }
    }
}

extension MonitoringViewController : SoloCameraDelegate {

    func monitoringResult(result: EmotionalResult?) {
        print("MonitoringViewController Result")
        guard let result = result else {
            emotionLabel.text = ""
            return
        }
        
        let dict = [
            "happiness":result.avg.happiness,
            "neutral":result.avg.neutral,
            "angry":result.avg.angry,
            "disgusted":result.avg.disgusted,
            "surprised":result.avg.surprised,
            "sad":result.avg.sad,
            "fearful":result.avg.fearful,
        ]
        
        if let max = dict.max(by: { entry1, entry2 in
            return entry1.1 < entry2.1
        }) {
            emotionLabel.text = "\(max.0) = \(Int(max.1 * 100))%"
        } else {
            emotionLabel.text = ""
        }
    }

    func sessionWasInterrupted() {
        print("sessionWasInterrupted")
    }

    func didEndSessionInterruption() {
        print("didEndSessionInterruption")
    }

    func sessionRunTimeError() {
        print("sessionRunTimeError")
    }

    func videoConfigurationError() {
        print("videoConfigurationError")
    }

    func cameraPermissionsDenied() {
        print("cameraPermissionsDenied")
    }
}
