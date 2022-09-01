//
//  NotificationManager.swift
//  PrayerUmmah
//
//  Created by Jawwaad Sabree on 7/14/22.
//

import SwiftUI
import UserNotifications

class NotificationManager {
    static let instance = NotificationManager()
    
    func schedulePrayerNotifications(prayers: KeyValuePairs<String, String>) {
        let testPrayer = prayers.first
        let currUser = UserModel.currUser
        let userPrayerData = [
            "Fajr": currUser?.prayerData?.Fajr,
            "Dhuhr": currUser?.prayerData?.Dhuhr,
            "Asr": currUser?.prayerData?.Asr,
            "Maghrib": currUser?.prayerData?.Maghrib,
            "Isha": currUser?.prayerData?.Isha
        ]
        
        let content = UNMutableNotificationContent()
            content.title = "Did you make \(testPrayer?.key ?? "")"
            content.sound = .defaultCritical
            content.categoryIdentifier = "PRAYER_TIMES"
            content.userInfo = [
                "CURR_PRAYER" : testPrayer?.key ?? "",
                "USER_PRAYER_DATA" : userPrayerData,
                "USER_ID" : currUser?.id ?? ""
            ]
        var dateComponents = DateComponents()
            dateComponents.hour = 4
            dateComponents.minute = 18
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
