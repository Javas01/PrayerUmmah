//
//  UserDataModel.swift
//  PrayerUmmah
//
//  Created by Jawwaad Sabree on 7/10/22.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct User: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var email: String
    var profilePic: String
    var prayerData: UserPrayerData?
}
struct UserPrayerData: Codable, Equatable {
    @DocumentID var date: String?
    var Fajr: Bool
    var Dhuhr: Bool
    var Asr: Bool
    var Maghrib: Bool
    var Isha: Bool
    
    subscript(prayerName: String) -> Bool {
        get {
            switch prayerName {
            case "Fajr":
                return Fajr
            case "Dhuhr":
                return Dhuhr
            case "Asr":
                return Asr
            case "Maghrib":
                return Maghrib
            default:
                return Isha
            }
        }
        set(newValue) {
            switch prayerName {
            case "Fajr":
                Fajr = newValue
            case "Dhuhr":
                Dhuhr = newValue
            case "Asr":
                Asr = newValue
            case "Maghrib":
                Maghrib = newValue
            default:
                Isha = newValue
            }
        }
    }
}

class UserModel: ObservableObject {
    @Published var users: [User] = []
    //    @Published var usersPrayerHistory: [userPrayerData] = []
    static var currUser: User?
    @Published var completedUsers: [User] = []
    @Published var notCompletedUsers: [User] = []
    
    private let db = Firestore.firestore()
    
    @MainActor
    func getUsers() async {
        do {
            let querySnapshot = try await db.collection("users").getDocuments()
            let documents = querySnapshot.documents
            
            self.users = documents.compactMap { documentSnapshot -> User in
                return try! documentSnapshot.data(as: User.self)
            }
            UserModel.currUser = self.users.first(where: {$0.id == Auth.auth().currentUser?.uid})!
            self.getPrayerData(userIds: self.users.map{ user in
                user.id ?? ""
            })
        } catch {
            print("There was an issue getting Users: \(error)")
        }
    }
    func getPrayerData(userIds: [String], date: String = getCurrentDate()) -> Void {
        let fajrTime = PrayerModel.todayPrayers.first?.value ?? ""
        let currTime = getCurrentTime()
        print(fajrTime)
        let isNewDay = currTime > fajrTime
        let currDate = getCurrentDate(date: isNewDay ? Date() : Date().dayBefore)
        userIds.forEach { userId in
            var prayerData = UserPrayerData(date: currDate, Fajr: false, Dhuhr: false, Asr: false, Maghrib: false, Isha: false)
            
            db.collection("users").document(userId).collection("prayerHistory").document(currDate)
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    do {
                        prayerData = try document.data(as: UserPrayerData.self)
                    } catch {
                        print("No data for " + currDate)
                    }
                    self.users = self.users.map { user in
                        if user.id == userId {
                            var copy = user
                            copy.prayerData = prayerData
                            
                            return copy
                        } else {
                            return user
                        }
                    }
                    UserModel.currUser = self.users.first(where: {$0.id == Auth.auth().currentUser?.uid})!
                }
        }
    }
}
