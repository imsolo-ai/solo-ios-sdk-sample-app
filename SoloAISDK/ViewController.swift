//
//  ViewController.swift
//  SoloAISDK
//
//  Created by kiryanovevg on 12/27/2021.
//  Copyright (c) 2021 kiryanovevg. All rights reserved.
//

import UIKit
import SoloAISDK

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var openMonitoringBtn: UIButton!

    private var solo: Solo?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        button.isEnabled = false
        openMonitoringBtn.isEnabled = false
        label.text = "Loading..."

        let creds = SoloCredentials(
            apiKey: getConfigValue(from: "Solo - API Key"),
            appId: getConfigValue(from: "Solo - App ID")
        )
        
        Solo.initialize(credentials: creds) { (solo: Solo?, status: InitializeStatus) in
            if status == .success, let solo = solo {
                self.solo = solo
                solo.setIdentify(
                    SoloIdentify(
                        userId: "iOS",
                        userName: "App",
                        groupId: "GroupId",
                        groupName: "GroupName",
                        sessionId: "Mobile SDK Example"
                    )
                )
                solo.setFramesPerSecond(fps: solo.getConfig().minFps)

                self.label.text = "Ready!"
                self.button.isEnabled = true
                self.openMonitoringBtn.isEnabled = true
            } else if status == .unauthorized {
                self.label.text = "Wrong credentials"
            } else {
                self.label.text = "Something went wrong"
            }
        }
    }

    @IBAction func buttonPress(_ sender: UIButton) {
        solo?.cameraDelegate = self
        guard let vc = solo?.createViewController() else {
            fatalError("Solo object not initialized!")
        }

        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func openMonitoringMode(_ sender: UIButton) {
        let controller = storyboard!.instantiateViewController(
            withIdentifier: "Monitoring"
        ) as! MonitoringViewController
        
        controller.solo = self.solo
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func getConfigValue(from key: String) -> String {
        guard let value = (Bundle.main.infoDictionary?[key] as? String) else {
            fatalError("Value from key = \(key) doesn't exists in info.plist!")
        }
        return value
    }

}

extension ViewController : SoloCameraDelegate {

    func checkupResults(result: EmotionalResult?) {
        self.navigationController?.popViewController(animated: true)
        solo?.cameraDelegate = nil
        guard let result = result else {
            self.label.text = "Result error"
            return
        }
        self.label.text = String(describing: result)
    }

    func checkupWasStarted() {
        self.navigationController?.topViewController?.title = "Checkup started"
    }

    func checkupWasEnded() {
        self.navigationController?.topViewController?.title = "Checkup ended"
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
