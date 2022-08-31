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
    @State private var isPresented = false;

    var body: some View {
        VStack{
            Text("Settings")
            Spacer()
            NavigationLink(destination: ContentView(), isActive: $isLoggedOut) { EmptyView() }.isDetailLink(false)
            HStack {
                Button("Sign out") {
                    do {
                        try Auth.auth().signOut()
                        isLoggedOut = true
                    } catch {
                        print(error)
                    }
                }
                Button("Delete account") {
                    isPresented = true
                }
                .foregroundColor(.red)
                .alert(isPresented: $isPresented) {
                    Alert(
                        title: Text("Are you sure?"),
                        message: Text("This action cannot be undone"),
                        primaryButton: .destructive(Text("Delete")) {
                            Auth.auth().currentUser?.delete()
                            isLoggedOut = true
                        },
                        secondaryButton: .cancel()
                    )
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
