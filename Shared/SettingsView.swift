//
//  SettingsView.swift
//  PrayerUmmah
//
//  Created by Jawwaad Sabree on 7/7/22.
//

import SwiftUI
import FirebaseAuth


struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

    }
}

struct SettingsView: View {
    @State private var image = UIImage()
    @State private var showSheet = false
    @State var isLoggedOut = false
    @State private var isPresented = false

    var body: some View {
        VStack{
            Text("Settings")
            Image(uiImage: self.image)
                    .resizable()
                    .cornerRadius(50)
                    .frame(width: 200, height: 200)
                    .background(Color.black.opacity(0.2))
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .padding(8)
                    .onTapGesture {
                        showSheet = true
                    }
            HStack{
                Text(UserModel.currUser?.firstName ?? "FirstName")
                    .font(.headline)
                Text(UserModel.currUser?.lastName ?? "LastName")
                    .font(.headline)
            }
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
        .sheet(isPresented: $showSheet) {
            ImagePicker(selectedImage: $image)
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
