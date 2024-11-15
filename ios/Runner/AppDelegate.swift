import UIKit
import Flutter
import ZaloSDK
import PushKit
import flutter_callkit_incoming_custom

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        GeneratedPluginRegistrant.register(with: self)
        //Setup VOIP
        let mainQueue = DispatchQueue.main
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return ZDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }
    
    // Call back from Recent history
    override func application(_ application: UIApplication,
                              continue userActivity: NSUserActivity,
                              restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        guard let handleObj = userActivity.handle else {
            return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
        }
        
        guard let isVideo = userActivity.isVideo else {
            return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
        }
        do {
            let objData = handleObj.getDecryptHandle()
            if objData != nil {
                let nameCaller = objData["nameCaller"] as? String ?? ""
                let handle = objData["handle"] as? String ?? ""
                let data = flutter_callkit_incoming_custom.Data(id: UUID().uuidString, nameCaller: nameCaller, handle: handle, type: isVideo ? 1 : 0)
                SwiftFlutterCallkitIncomingPlugin.sharedInstance?.startCall(data, fromPushKit: true)
            }
        } catch {
            print("Error while decrypting handle: \(error)")
            //return false
        }
        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    
    // Handle updated push credentials
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        print(credentials.token)
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        print(deviceToken)
        //Save deviceToken to your server
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("didInvalidatePushTokenFor")
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        NSLog("==================didReceiveIncomingPushWith==================")
        debugPrint(payload.dictionaryPayload)
        NSLog("==============================================================")
        guard type == .voIP else { return }
        
        let roomName = payload.dictionaryPayload["roomName"] as? String ?? ""
        let receiverId = payload.dictionaryPayload["receiverId"] as? Int ?? 0
        let dialerId = payload.dictionaryPayload["dialerId"] as? Int ?? 0
        let status = payload.dictionaryPayload["status"] as? String ?? ""
        let dialerImage = payload.dictionaryPayload["dialerImage"] as? String ?? ""
        let callId = payload.dictionaryPayload["callId"] as? Int ?? 0
        let email = payload.dictionaryPayload["email"] as? String ?? ""
        let callType = payload.dictionaryPayload["callType"] as? String ?? ""
        
        let id = UUID().uuidString
        let nameCaller = payload.dictionaryPayload["name"] as? String ?? ""
        let handle = payload.dictionaryPayload["phone"] as? String ?? ""
        let isVideo = (payload.dictionaryPayload["callType"] as? String ?? "") == "video"
        
        let data = flutter_callkit_incoming_custom.Data(id: id, nameCaller: nameCaller, handle: handle, type: isVideo ? 1 : 0)
        //set more data
        data.extra = ["roomName": roomName, "receiverId": receiverId, "dialerId" : dialerId,
                      "status" : status, "dialerImage" : dialerImage, "callId" : callId, "email" : email,
                      "callType" : callType, "name": nameCaller, "phone": handle]
        
        
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(data, fromPushKit: true)
        
        //Make sure call completion()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            completion()
        }
    }
}
