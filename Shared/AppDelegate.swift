import SwiftUI
import UserNotifications
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth

// change to UIresponder
class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
//  var window: UIWindow?
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication
                     .LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()

    UNUserNotificationCenter.current().delegate = self
    let options: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: options) { (success, error) in
        if let error = error {
            print("ERROR: \(error)")
        } else {
            print("SUCCESS: \(success)")
        }
    }
                         
     // Define the custom actions.
     let acceptAction = UNNotificationAction(identifier: "SET_YES",
           title: "Yes",
        options: [])
     let declineAction = UNNotificationAction(identifier: "SET_NO",
           title: "No",
           options: [])
     // Define the notification type
     let prayerCategory =
           UNNotificationCategory(identifier: "PRAYER_TIMES",
           actions: [acceptAction, declineAction],
           intentIdentifiers: [],
           hiddenPreviewsBodyPlaceholder: "",
           options: .hiddenPreviewsShowTitle)
     
    UNUserNotificationCenter.current().setNotificationCategories([prayerCategory])
                         
    application.registerForRemoteNotifications()

    return true
  }

  func application(_ application: UIApplication,
                   didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Unable to register for remote notifications: \(error.localizedDescription)")
  }

  func application(_ application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("APNs token retrieved: \(deviceToken)")

  }
}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
      completionHandler([[.banner, .list, .badge, .sound]])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
      let db = Firestore.firestore()
      let userInfo = response.notification.request.content.userInfo
          let currPrayer = userInfo["CURR_PRAYER"] as! String
          let prayerData = userInfo["USER_PRAYER_DATA"] as! [String : Bool?]
          let userId = userInfo["USER_ID"] as! String
      let currDate = getCurrentDate()
      let todayPrayers = db.collection("users").document(userId).collection("prayerHistory").document(currDate)
      var copy = prayerData

      if response.actionIdentifier == "SET_YES" {
          copy[currPrayer] = true
      } else if response.actionIdentifier == "SET_NO" {
          copy[currPrayer] = false
      }

      do {
          try todayPrayers.setData(from: copy)
      } catch {
          print(error)
      }

      completionHandler()
  }
}
