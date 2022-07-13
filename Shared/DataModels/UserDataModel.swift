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
    @Published var currUser: User?
    @Published var completedUsers: [User] = []
    @Published var notCompletedUsers: [User] = []

    private let db = Firestore.firestore()

    func getUsers() {
        db.collection("users").getDocuments() { (querySnapshot, err) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }

            self.users = documents.compactMap { documentSnapshot -> User in
                return try! documentSnapshot.data(as: User.self)
            }
            self.currUser = self.users.first(where: {$0.id == Auth.auth().currentUser?.uid})!
            self.getPrayerData(userIds: self.users.map{ user in
                user.id ?? ""
            })
        }
    }
    func getPrayerData(userIds: [String], date: String = getCurrentDate()) -> Void {
        let currDate = getCurrentDate()
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
                        print("Document data was empty.")
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
                    self.currUser = self.users.first(where: {$0.id == Auth.auth().currentUser?.uid})!
                }
        }
    }
}
