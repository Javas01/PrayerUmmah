//
//  ContentView.swift
//  Shared
//
//  Created by Jawwaad Sabree on 7/5/22.
//

import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseFirestoreSwift


struct ContentView: View {
    @State var firstName = ""
    @State var lastName = ""
    @State var email = ""
    @State var password = ""
    @State var isLoggedIn = false
    @State var currSigninType = "Login"
    
    let signInTypes = ["Login", "Signup"]
    let db = Firestore.firestore()
    
    func addUserToFirestore(userId: String) -> Void {
        db.collection("users").document(userId).setData([
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "profilePic": ""
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added successfully")
            }
        }
    }
    
    func logIn() -> Void {
        print(email, password)
        Auth.auth().signIn(withEmail: email, password: password) {authResult,error in
            if((error) != nil) {
                print(error as Any)
            }
            else {
                print(authResult?.user ?? "")
                isLoggedIn = true
            }
        }
    }
    
    func signUp() -> Void {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if((error) != nil) {
                print(error as Any)
            }
            else {
                addUserToFirestore(userId: (authResult?.user.uid)!)
                isLoggedIn = true
            }
          }
    }

    var body: some View {
            VStack() {
                Spacer()
                NavigationLink(destination: HomeView(), isActive: $isLoggedIn) { EmptyView() }
                if(currSigninType == "Login") {
                    TextField("Email", text: $email)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)

                    SecureField("Password", text: $password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                    Button("Log In") {
                        logIn()
                    }
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color("Primary"))
                        .cornerRadius(10)
                        .foregroundColor(Color.white)
                        .font(.headline)
                } else {
                    HStack{
                        TextField("First Name", text: $firstName)
                            .padding()
                            .frame(height: 50)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(10)
                            .disableAutocorrection(true)
                        TextField("Last Name", text: $lastName)
                            .padding()
                            .frame(height: 50)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(10)
                            .disableAutocorrection(true)
                    }.frame(width: 300)
                    TextField("Email", text: $email)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)

                    SecureField("Password", text: $password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                    Button("Sign Up") {
                        signUp()
                    }
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color("Primary"))
                        .cornerRadius(10)
                        .foregroundColor(Color.white)
                        .font(.headline)
                }

                Spacer()
                Picker("", selection: $currSigninType) {
                    ForEach(signInTypes, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                Auth.auth().addStateDidChangeListener { auth, user in
                    if((user) != nil) {
                        isLoggedIn = true
                    }
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
