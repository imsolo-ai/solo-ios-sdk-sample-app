# Solo iOS Library

## Using
Add dependency to your `Podfile`
```ruby
pod 'SoloAISDK', '~> 1.0.0'
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Create file `ApiKey.xcconfig` in `Example/SoloAISDK` directory.

Full path from project folder: `Example/SoloAISDK/ApiKey.xcconfig`

Put your `APP_ID` and `APP_KEY` variables into `ApiKey.xcconfig`

```text
API_KEY = apikey123example
APP_ID = app-id-123-example
```

## Podspec 

Project contains development and release `.podspec` files.
1. Development Podspec file (version 0.0.1) depends on local source files and assets.
2. Release Podspec file depends on release `.xcframework` files with compiled library.

For changing selected Podspec file specify it in `Podfile`. After run `pod install` in `Example` folder.

## Library building & publishing

To publish a library, you need: 
1. Select `Development Podspec` file in `Podfile`. 
2. Run `pod install` in `Example` folder.
3. Run `build.sh` from project folder.

After execution of `build.sh` in project folder will be 2 files:
1. SoloAISDK.xcframework
2. TensorFlowLite.xcframework

You can test libraries building result:
1. Select `Release Podspec` file in `Podfile`.
2. Run `pod install` in `Example` folder.
3. Run Example.

After testing, it requires to be deployed to `Artifactory` repository.
Archive necessary files with `archive.sh`. Then upload to `Artifactory` in cocoapod repository.
You can do it manually via web site or via terminal (use `Set Me Up` button from web version to get instructions).

Repository file layout:
- [cocoapods_repo_name]
  - [library_name]
    - [version]
      - ['library_name'-'version'.tar.gz]
  - [library_name]
    - ...

After deploying change in Release Podspec file according with new version:
1. `s.version`
2. `s.source`

Update Podspec (Release) file on Cocoapod trunk repository.

`pod trunk push SoloAISDK.podspec`

Then you will be able to get library from Cocoapod. 
Change dependency in `Podfile` to remote version of pod. Run `pod install --repo-update` from `Example` folder. Run project to test.

## Encryption files

For files encryption was created `Encryption.playground`. 
Add files to playground resources into `Decrypted` folder.
Add enctypted names for decrypted files into config dictionary `ENCRYPTED_NAMES` in `EncryptionManager.swift`
Run playground and follow instructions from output to find encrypted files.
Pod `SoloAISDK` contains file `DataLoader.swift` which is the copy with changes of files `AES.swift` and `EnctyptionManager.swift`.

## Library Documentation

### Initialization

To be able to work with face expression estimating you should
initialize `Solo` object.
This method require network connection.

```swift
static func initialize(
    credentials: SoloCredentials,
    result: @escaping (Solo?, InitializeStatus) -> ()
)
```
```swift
public enum InitializeStatus: Int {
    case success = 0
    case unauthorized = 1
    case error = 2
}
```

Configure your session with `Solo` object
(`userId` and `sessionId` are required parameters 
in `SoloIdentify`). 

#### Methods:
```swift
func setIdentify(_ identify: SoloIdentify)
func setContent(contentId: String)
func setMetadata(metadata: [String:String])
func removeMetadata(keys: Set<String>)
func reset()
func createViewController() -> UIViewController
```

#### Example of initialization:
```swift
Solo.initialize(credentials: creds) { (solo: Solo?, status: InitializeStatus) in
    if status == .success, let solo = solo {
        self.solo = solo
        solo.cameraDelegate = self
        solo.setIdentify(SoloIdentify(userId: "iOS", sessionId: "App"))
        
        self.label.text = "Ready!"
        self.button.isEnabled = true
    } else if status == .unauthorized {
        self.label.text = "Wrong credentials"
    } else {
        self.label.text = "Something went wrong"
    }
}
```

### Estimation flow

#### ViewController initialization

Estimation flow works in a `UIViewController`. Create controller instance
with initialized `Solo` object.

```swift
guard let soloVC = solo?.createViewController() else {
    fatalError("Solo object not initialized!")
}
```

Then you will be able to push this `soloVC` in a `navigationController`.

#### Note
Also add `NSCameraUsageDescription` to your `Info.plist` file.

#### Callback initialization

To get estimation callbacks you should set `cameraDelegate` to `Solo` object.

Delegate methods:
```swift
public protocol SoloCameraDelegate {
    func sessionRunTimeError()
    func videoConfigurationError()
    func cameraPermissionsDenied()
    func sessionWasInterrupted()
    func didEndSessionInterruption()
    func checkupWasStarted()                                
    func checkupResults(result: EmotionalCheckupResult?)    
    func checkupWasEnded()                                  
}
```
### Real-time Data Access

To enable real-time data access, add a listener using `addMonitoringEventListener` method of `Solo` object
Listener object should conform to `SoloMonitoringEventDelegate` protocol

#### Example
```swift
solo.addMonitoringEventListener(listener)
```

#### Methods:
```swift
func addMonitoringEventListener(_ eventListener: SoloMonitoringEventDelegate)
func removeMonitoringEventListener(_ eventListener: SoloMonitoringEventDelegate)
func removeAllMonitoringEventListeners()
```

#### Delegate methods:
```swift
public protocol SoloMonitoringEventDelegate: AnyObject {
    func monitoringEvent(event: MonitoringTracker)
}
```

### Models

#### SoloCredentials

```swift
struct SoloCredentials {
    let apiKey: String
    let appId: String
}
```

#### SoloIdentify

```swift
struct SoloIdentify {
    let userId: String
    let sessionId: String
    let groupId: String?
}
```

#### EmotionalCheckupResult

```swift
struct EmotionalCheckupResult : Codable {
    let avg: AvgEmotion
    let valence: Double
    let energy: Double
    let wellbeing: Double
    let stress: Double
    let interest: Double
    let engagement: Double
    let soloSessionId: Int
}
```

#### AvgEmotion

```swift
struct AvgEmotion : Codable {
    let happiness: Float
    let neutral: Float
    let angry: Float
    let disgusted: Float
    let surprised: Float
    let sad: Float
    let fearful: Float
}
```

#### MonitoringTracker

```swift
public struct MonitoringTracker: Codable {
    public let index: Int
    public let emotions: ExpressionResult
    public let monitoringDuration: Float   // total monitoring time
    public let playedSeconds: Float        // current interval duration
    public let duration: Float             // interval total duration
    public let result: [TrackingResult]
}
```

#### TrackingResult

```swift
public struct TrackingResult: Codable {
    public let emotions: ExpressionResult
    public let box: TrackingBox
    public let imageDims: ImageDimensions
}
```

#### ExpressionResult

```swift
public struct ExpressionResult: Codable {
    public let neutral: Float?
    public let happy: Float?
    public let sad: Float?
    public let angry: Float?
    public let fearful: Float?
    public let disgusted: Float?
    public let surprised: Float?
    public let stress: Float?
    public let wellbeing: Float?
    public let engagement: Float?
    public let mood: Float?
    public let energy: Float?
    public let interest: Float?
}
```

#### TrackingBox

```swift
public struct TrackingBox: Codable {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double
}
```

#### ImageDimensions

```swift
public struct ImageDimensions: Codable {
    public let width: Double
    public let height: Double
}
```
