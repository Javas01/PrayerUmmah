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
    @StateObject var prayerModel = PrayerModel()
    @StateObject var userModel = UserModel()
    @State var selectedTab = 2
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GraphView(prayerModel: prayerModel, userModel: userModel)
                .tabItem{
                    Label("History", systemImage: "chart.xyaxis.line")
                }.tag(1)
            PrayerView(prayerModel: prayerModel, userModel: userModel)
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
        .task {
            await prayerModel.fetch()
            await userModel.getUsers()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
        }
    }
}
