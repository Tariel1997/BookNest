import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var isImagePickerPresented = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
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
                        .foregroundColor(isDarkMode ? .gray.opacity(0.7) : .gray)
                        .clipShape(Circle())
                        .onTapGesture {
                            isImagePickerPresented.toggle()
                        }
                }
                
                if !viewModel.profile.email.isEmpty {
                    Text("Email: \(viewModel.profile.email)")
                        .font(.footnote)
                        .foregroundColor(isDarkMode ? .gray.opacity(0.7) : .gray)
                        .padding(.top, 4)
                }
                
                Text("Balance: $\(String(format: "%.2f", viewModel.profile.balance))")
                    .font(.footnote)
                    .foregroundColor(isDarkMode ? .white.opacity(0.8) : .gray)
                    .padding(.top, 4)
                
                VStack(spacing: 5) {
                    Text("Full Name")
                        .font(.subheadline)
                        .foregroundColor(isDarkMode ? .white : .gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    TextField("Enter your name", text: $viewModel.profile.name)
                        .padding(20)
                        .background(isDarkMode ? Color.gray.opacity(0.4) : Color.white)
                        .foregroundColor(isDarkMode ? .white : .black)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                }
                
                VStack(spacing: 5) {
                    Text("Username")
                        .font(.subheadline)
                        .foregroundColor(isDarkMode ? .white : .gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    TextField("Enter your username", text: $viewModel.profile.surname)
                        .padding(20)
                        .background(isDarkMode ? Color.gray.opacity(0.4) : Color.white)
                        .foregroundColor(isDarkMode ? .white : .black)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                }
                
                Spacer()
                
                Button(action: {
                    logOut()
                }) {
                    Text("Log Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 120)
                        .background(isDarkMode ? Color.red.opacity(0.8) : Color.red)
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Your Profile")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(isDarkMode ? .white : .black)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.saveProfile()
                        print("Profile saved")
                    }) {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(isDarkMode ? .cyan : .blue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isDarkMode.toggle()
                        NotificationCenter.default.post(name: .darkModeChanged, object: nil)
                    }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundColor(isDarkMode ? .yellow : .blue)
                    }
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .background(isDarkMode ? Color.black : Color(red: 250/255, green: 245/255, blue: 230/255))
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $viewModel.profileImage)
                    .onChange(of: viewModel.profileImage) { _ in
                        viewModel.uploadProfileImage()
                    }
            }
        }
    }
    
    private func logOut() {
        do {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {
                (window.rootViewController as? MainTabBarController)?.clearTabBarControllers()
                window.rootViewController = nil
            }
            
            try Auth.auth().signOut()
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {
                let loginVC = LoginViewController()
                let navigationController = UINavigationController(rootViewController: loginVC)
                window.rootViewController = navigationController
                window.makeKeyAndVisible()
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
