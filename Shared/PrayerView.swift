//
//  HomeView.swift
//  PrayerUmmah
//
//  Created by Jawwaad Sabree on 7/6/22.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct EmptyModifier: ViewModifier {

    let isEmpty: Bool

    func body(content: Content) -> some View {
        Group {
            if isEmpty {
                EmptyView()
            } else {
                content
            }
        }
    }
}

func getPrayerDateAndIndex(prayer: String) -> (date: String, index: Int){
    let currDate = getCurrentDate()
    var prayerIndex: Int

    switch prayer {
    case "Fajr":
        prayerIndex = 0
    case "Dhuhr":
        prayerIndex = 1
    case "Asr":
        prayerIndex = 2
    case "Maghrib":
        prayerIndex = 3
    default:
        prayerIndex = 4
    }
    return (currDate, prayerIndex)
}

struct PrayerView: View {
    @StateObject var prayerModel = PrayerModel()
    @StateObject var userModel = UserModel()
    @State private var isOverlayVisible = true
    @State var completedUsers: [User] = []
    @State var notCompletedUsers: [User] = []
    
    let db = Firestore.firestore()
    
    static func remindFriend() -> Void {
        print("This is a reminder")
    }
    
    func logPrayer(response: Bool) -> Void {
        isOverlayVisible = false
        let currPrayer = prayerModel.currPrayer
        var copy = userModel.currUser?.prayerData
        copy?[currPrayer] = response
        
        if copy == userModel.currUser?.prayerData {
            print("Nothing changed")
            return
        }

        let currDate = getCurrentDate()
        let userId = Auth.auth().currentUser?.uid ?? ""
        let todayPrayers = db.collection("users").document(userId).collection("prayerHistory").document(currDate)
        
        do {
            try todayPrayers.setData(from: copy)
        } catch {
            print(error)
        }
    }
    
    func getCompletedUsers() -> Void {
        let selectedPrayer = prayerModel.selectedPrayer
        
        completedUsers = userModel.users.filter {user in
            user.prayerData?[selectedPrayer] == true
        }
        notCompletedUsers = userModel.users.filter {user in
            user.prayerData?[selectedPrayer] == false
        }
    }

    var body: some View {
            VStack {
                HStack {
                    Image(systemName: "chevron.left")
                    Text(Date().display).font(.headline)
                    Image(systemName: "chevron.right")
                }
                HStack {
                    ForEach(prayerModel.prayers, id: \.self.key) { prayer in
                        let prayerName = prayer.key as? String ?? ""
                        let prayerTime = prayer.value as? String ?? ""

                        Button(action: {() -> Void in prayerModel.selectedPrayer = prayerName; getCompletedUsers()}) {
                            VStack {
                                Text(prayerName)
                                Text(to12hourString(time: prayerTime))
                                    .font(.footnote)
                            }
                        }
                        .foregroundColor(prayerModel.currPrayer == prayerName ? Color("Primary") : Color.black)
                        .padding(7)
                        .background(prayerModel.selectedPrayer == prayerName ? Color(UIColor.systemGray6) : nil)
                        .cornerRadius(5)
                    }
                }
                .offset(y: 12)
                ZStack{
                    List {
                        Section("Not Complete"){
                            ForEach(notCompletedUsers) { user in
                                UserPrayerRow(firstName: user.firstName, lastName: user.lastName)
                            }
                        }.blur(radius: isOverlayVisible ? 4 : 0)
                        Section("Completed") {
                            ForEach(completedUsers) { user in
                                UserPrayerRow(completed: true, firstName: user.firstName, lastName: user.lastName)
                            }
                        }.blur(radius: isOverlayVisible ? 4 : 0)
                    }
                    .onChange(of: userModel.users, perform: { _ in
                        getCompletedUsers()
                    })
                    .buttonStyle(BorderlessButtonStyle())
                    VStack {
                        Text("Did you pray \(prayerModel.currPrayer)?")
                            .font(.largeTitle)
                        HStack {
                            Button("No"){
                                logPrayer(response: false)
                            }
                                .frame(width: 100, height: 50)
                                .padding(10)
                                .background(Color("Primary"))
                                .cornerRadius(10)
                                .foregroundColor(Color.white)
                                .font(.largeTitle)
                                
                            Button("Yes"){
                                logPrayer(response: true)
                                
                            }
                                .frame(width: 100, height: 50)
                                .padding(10)
                                .background(Color("Primary"))
                                .cornerRadius(10)
                                .foregroundColor(Color.white)
                                .font(.largeTitle)
                        }
                    }.isEmpty(!isOverlayVisible)
                }
        }
        .onAppear {
            UITableView.appearance().backgroundColor = .systemGroupedBackground
            userModel.getUsers()
            prayerModel.fetch()
        }
    }
}

struct PrayerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
        }
    }
}

struct UserPrayerRow: View {
    var completed: Bool = false
    var firstName: String = "test"
    var lastName: String = "dummy"
    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle")
                .font(.headline)
                .foregroundColor(Color("Primary"))
            Text(firstName)
                .font(.headline)
                .foregroundColor(Color("Primary"))
            Text(lastName)
                .font(.headline)
                .foregroundColor(Color("Primary"))
            Spacer()
            if(!completed){
                Button(action: {PrayerView.remindFriend()}){
                    HStack{
                        Text("Remind")
                        Image(systemName: "bell.fill")
                    }
                }
                .padding(7)
                .background(Color("Primary"))
                .cornerRadius(10)
                .foregroundColor(Color.white)
                .font(.headline)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color("Tertiary"))
                    .font(.title)
            }
        }
    }
}
