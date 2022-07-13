//
//  SettingsView.swift
//  PrayerUmmah
//
//  Created by Jawwaad Sabree on 7/7/22.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @State var isLoggedOut = false

    var body: some View {
        VStack{
            Text("Settings")
            Spacer()
            NavigationLink(destination: ContentView(), isActive: $isLoggedOut) { EmptyView() }.isDetailLink(false)
            Button("Sign out") {
                do {
                    try Auth.auth().signOut()
                    isLoggedOut = true
                } catch {
                    print(error)
                }
            }
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsView()
        }
    }
}
