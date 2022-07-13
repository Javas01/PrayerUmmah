//
//  PrayerUmmahApp.swift
//  Shared
//
//  Created by Jawwaad Sabree on 7/5/22.
//

import SwiftUI

@main
struct PrayerUmmahApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}
