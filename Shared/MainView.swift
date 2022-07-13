//
//  MainView.swift
//  PrayerUmmah
//
//  Created by Jawwaad Sabree on 7/7/22.
//

import SwiftUI

struct MainView: View {
    @State var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                        Label("Friends", systemImage: "person.fill")
                }.tag(0)
            HomeView()
                .tabItem {
                        Label("Home", systemImage: "house.fill")
                }.tag(1)
            ContentView()
                .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                }.tag(2)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView()
        }
    }
}
