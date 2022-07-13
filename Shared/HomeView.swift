//
//  HomeView.swift
//  PrayerUmmah
//
//  Created by Jawwaad Sabree on 7/6/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @State var selectedTab = 2
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FriendsView()
                .tabItem{
                    Label("Friends", systemImage: "person.fill")
                }.tag(1)
            PrayerView()
                .tabItem{
                    Label("Home", systemImage: "house.fill")
                }.tag(2)
            SettingsView()
                .tabItem{
                    Label("Settings", systemImage: "gearshape.fill").tint(.red)
                }.tag(3)
        }
        .accentColor(Color("Primary"))
        .navigationBarBackButtonHidden(true)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
        }
    }
}