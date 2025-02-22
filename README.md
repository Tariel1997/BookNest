# BookNest

BookNest is an iOS application designed to enhance your reading experience by offering a platform to browse, purchase, and manage your favorite books. Built using Swift, it leverages the power of SwiftUI and UIKit for a seamless user interface, and Firebase for backend functionalities.

---

## Features:

- **Browse Books**: Explore a variety of books categorized by genres.
- **Cart Management**: Add books to your cart and seamlessly proceed to checkout.
- **User Profile**: Update your profile picture and personal details.
- **Book Details**: View detailed information about each book.
- **PDF Reader**: Read purchased books directly in the app using **PDFKit**.
- **File Manager Integration**: Save downloaded PDFs to your device and access them using the iOS Files app.
- **Dark Mode Support**: Enjoy the app in light or dark mode.
- **Google Sign-In Integration**: Sign in with Google for quick access.
- **Firebase Integration**: Real-time data updates with Firestore and image uploads to Firebase Storage.
- **Cached Images**: Fast image loading using local caching.
- **Progressive Downloads**: Monitor the download progress for books with a smooth progress bar.


---

## Requirements:

- iOS 16.0 or later

---

## Technologies Used:

- **Swift**
- **SwiftUI & UIKit**: Combined for modern and dynamic UI.
- **Firebase**:
  - Firestore Database
  - Firebase Authentication
  - Firebase Storage
- **GoogleSignIn**
- **Combine Framework**
- **PDFKit**: For rendering and managing PDF files.
- **FileManager**: Save and export files locally on the device.

---

## Custom Components:

- **ImagePicker**: A reusable component for selecting profile pictures.
- **PDFKitView**: Displays PDFs for purchased books directly within the app.
- **DownloadDelegate**: A custom implementation to handle progressive downloads and file management.

---

## Architecture:

The project follows the **MVVM (Model-View-ViewModel)** architecture pattern for better separation of concerns and testability.

---

## Installation:

1. Clone the repository:

      ```bash
   git clone https://github.com/Tariel1997/BookNest.git
