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

struct PrayerView: View {
    @ObservedObject var prayerModel: PrayerModel
    @ObservedObject var userModel: UserModel
    @State private var isOverlayVisible = true
    @State var completedUsers: [User] = []
    @State var notCompletedUsers: [User] = []
    
    let db = Firestore.firestore()
    
    func logPrayer(response: Bool) -> Void {
        isOverlayVisible = false
        let fajrTime = prayerModel.prayers.first?.value ?? ""
        let currTime = getCurrentTime()
        let isNewDay = currTime > fajrTime
        let currPrayer = prayerModel.currPrayer
        var copy = UserModel.currUser?.prayerData
        copy?[currPrayer] = response
        
        if copy == UserModel.currUser?.prayerData {
            return
        }
        
        let currDate = isNewDay ? getCurrentDate() : getCurrentDate(date: Date().dayBefore)
        let userId = Auth.auth().currentUser?.uid ?? ""
        let todayPrayers = db.collection("users").document(userId).collection("prayerHistory").document(currDate)
        
        do {
            try todayPrayers.setData(from: copy)
        } catch {
            print(error)
        }
    }
    
    func getCompletedUsers() -> Void {
        let selectedPrayer = prayerModel.selectedPrayer // make static
        
        completedUsers = userModel.users.filter {user in
            user.prayerData?[selectedPrayer] == true
        }
        notCompletedUsers = userModel.users.filter {user in
            user.prayerData?[selectedPrayer] == false
        }
    }
    
    var body: some View {
        VStack {
            let fajrTime = prayerModel.prayers.first?.value ?? ""
            let currTime = getCurrentTime()
            let isNewDay = currTime > fajrTime
            HStack {
                Image(systemName: "chevron.left")
                Text(isNewDay ? Date().display : Date().dayBefore.display).font(.headline)
                Image(systemName: "chevron.right")
            }
            HStack {
                ForEach(prayerModel.prayers, id: \.self.key) { prayer in
                    let prayerName = prayer.key
                    let prayerTime = prayer.value
                    
                    Button(action: {() -> Void in prayerModel.selectedPrayer = prayerName; getCompletedUsers()}) {
                        VStack {
                            Text(prayerName)
                            Text(to12hourString(time: prayerTime))
                                .font(.footnote)
                        }
                    }
                    .foregroundColor(prayerModel.currPrayer == prayerName ? Color("Primary") : Color.primary)
                    .padding(7)
                    .background(prayerModel.selectedPrayer == prayerName ? Color(UIColor.tertiarySystemGroupedBackground) : nil)
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
                .onChange(of: userModel.users, perform: { _ in // move to userModel
                    getCompletedUsers()
                })
                .buttonStyle(BorderlessButtonStyle())
                VStack {
                    Text("Did you pray \(prayerModel.currPrayer)?")
                        .font(.largeTitle)
                    HStack {
                        Button(action: {() -> Void in logPrayer(response: false)}){
                            Text("No")
                                .frame(width: 100, height: 50)
                                .padding(10)
                                .background(Color("Primary"))
                                .cornerRadius(10)
                                .foregroundColor(Color.white)
                                .font(.largeTitle)
                        }
                        Button(action: {() -> Void in logPrayer(response: true)}){
                            Text("Yes")
                                .frame(width: 100, height: 50)
                                .padding(10)
                                .background(Color("Primary"))
                                .cornerRadius(10)
                                .foregroundColor(Color.white)
                                .font(.largeTitle)
                        }
                    }
                }.isEmpty(!isOverlayVisible)
            }
        }
        .onAppear {
            UITableView.appearance().backgroundColor = UIColor.tertiarySystemGroupedBackground
            isOverlayVisible = true
        }
        .onChange(of: UserModel.currUser, perform: { _ in isOverlayVisible = UserModel.currUser?.prayerData?[prayerModel.currPrayer] == false})
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
    @State var showAlert: Bool = false
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
                Button(action: {() -> Void in showAlert = true}){
                    HStack{
                        Text("Remind")
                        Image(systemName: "bell.fill")
                    }
                }
                .alert("Feature coming soon!", isPresented: $showAlert){}
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
