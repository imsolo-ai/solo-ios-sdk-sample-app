# SOLO AI - SDK - iOS Library
Empower Your Android App with Emotional AI: Introducing SOLO AI - iOS Sample App"

Discover the transformative potential of Emotional AI in your Android app with our SOLO iOS Sample App.
This iOS Sample App showcases the seamless integration of our cutting-edge Emotional AI technology into your mobile applications, unlocking new dimensions of user engagement, personalization, and insight.
With SOLO SDK, developers can effortlessly implement advanced emotion recognition, facial micro-expression analysis, and sentiment analysis features into their iOS apps.
For more details: www.imsolo.ai 

## Using
Add dependency to your `Podfile`
```ruby
pod 'SoloAISDK', '~> 1.0.0'
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Create file `ApiKey.xcconfig` in `SoloAISDK` directory.

Full path from project folder: `SoloAISDK/ApiKey.xcconfig`

Put your `APP_ID` and `APP_KEY` variables into `ApiKey.xcconfig`

```text
API_KEY = apikey123example
APP_ID = app-id-123-example
```

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

#### LandmarkerResults

```swift
public struct LandmarkerResults {
    let blendshapes: [String: BlendshapeScore]
    let headAngles: HeadAngles
}
```

#### BlendshapeScore

```swift
public struct BlendshapeScore: Codable {
    public let score: Float
}
```

#### HeadAngles

```swift
public struct HeadAngles: Codable {
    public let yaw: Float
    public let pitch: Float
    public let roll: Float
}
```
