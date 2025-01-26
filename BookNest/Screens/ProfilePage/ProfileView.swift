import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var isImagePickerPresented = false
    //@Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .frame(width: 120, height: 120)
                } else if let profileImage = viewModel.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .onTapGesture {
                            isImagePickerPresented.toggle()
                        }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray)
                        .clipShape(Circle())
                        .onTapGesture {
                            isImagePickerPresented.toggle()
                        }
                }
                
                if !viewModel.profile.email.isEmpty {
                    Text("Email: \(viewModel.profile.email)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
                
                Text("Balance: $\(String(format: "%.2f", viewModel.profile.balance))")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
                
                VStack(spacing: 5) {
                    Text("Full Name")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    TextField("Enter your name", text: $viewModel.profile.name)
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                }
                
                VStack(spacing: 5) {
                    Text("Username")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    TextField("Enter your username", text: $viewModel.profile.surname)
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {
                        logOut()
                    }) {
                        Text("Log Out")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 120)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        viewModel.saveProfile()
                        print("Profile saved")
                    }) {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 120)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom, 20)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Your Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
            }
            .background(Color(red: 250/255, green: 245/255, blue: 230/255))
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $viewModel.profileImage)
                    .onChange(of: viewModel.profileImage) { _ in
                        viewModel.uploadProfileImage()
                    }
            }
        }
    }
    
    //    private func logOut() {
    //        do {
    //            try Auth.auth().signOut()
    //            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
    //               let window = windowScene.windows.first {
    //                window.rootViewController = LoginViewController()
    //                window.makeKeyAndVisible()
    //            }
    //        } catch {
    //            print("Error signing out: \(error.localizedDescription)")
    //        }
    //    }
    
    private func logOut() {
        do {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let tabBarController = scene.windows.first?.rootViewController as? MainTabBarController {
                tabBarController.clearTabBarControllers()
            }
            
            try Auth.auth().signOut()
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {
                window.rootViewController = LoginViewController()
                window.makeKeyAndVisible()
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
