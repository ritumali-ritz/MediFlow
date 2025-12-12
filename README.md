# 🏥 MediFlow - Smart Health Queue System

> **Revolutionizing Hospital Queue Management with Real-time Updates & Smart Analytics**

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Core-orange.svg)](https://firebase.google.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-green.svg)]()

**MediFlow** is a next-generation healthcare management solution designed to eliminate chaotic waiting rooms. It seamlessly connects **Patients**, **Doctors**, and **Administrators** through a real-time, cloud-synchronized ecosystem.

---

## 🌟 Key Features

### 🩺 For Doctors (The Command Center)
- **Live Dashboard**: See real-time waiting list, patient details, and estimated wait times.
- **Smart Queue Control**: "Call Next", "Complete", or "Skip" patients with a single tap.
- **Analytics**: View daily statistics (Total Patients, KPIs) instantly.
- **Profile Management**: Update practice details and availability.

### 📱 For Patients (The Experience)
- **Virtual Queuing**: Join the queue from anywhere. No more standing in line!
- **Live Status Tracking**: "You are #5. ETA: 25 mins". Know exactly when to arrive.
- **Real-time Badge**: App icon badge updates live as the queue moves.
- **Multi-Queue Support**: Manage appointments for different doctors simultaneously.

### 🖥️ Admin Portal (The Backbone)
- **Comprehensive Location Data**: Pre-loaded with **all 36 Districts & Tehsils of Maharashtra**.
- **Doctor Management**: Create accounts, securely manage 8-digit auto-generated passwords.
- **Security**: Robust authentication layout prevent accidental lockouts.
- **Web-Based**: Accessible from any browser for hospital staff.

### 📺 TV Display Mode
- **Waiting Room Screen**: A dedicated "Airport-style" display for the hospital waiting area.
- **Live Updates**: Shows "Now Serving" and "Up Next" tokens in real-time.

---

## 🚀 Tech Stack

- **Frontend**: Flutter (Mobile & Web)
- **Backend**: Firebase (Firestore, Auth, Hosting)
- **State Management**: Riverpod
- **Architecture**: MVVM-inspired Service-Repository pattern

---

## 📸 Screenshots

| Patient Home | Doctor Dashboard | Admin Portal |
|:---:|:---:|:---:|
| *Real-time tokens & ETA* | *Queue controls & Stats* | *Hospital Management* |
| ![Patient](https://via.placeholder.com/200x400?text=Patient+App) | ![Doctor](https://via.placeholder.com/200x400?text=Doctor+App) | ![Admin](https://via.placeholder.com/400x200?text=Admin+Web) |

---

## 🛠️ Installation & Setup

### Prerequisites
- Flutter SDK installed
- Firebase CLI installed
- Android Studio / VS Code

### 1. Clone the Repo
```bash
git clone https://github.com/ritumali-ritz/MediFlow.git
cd MediFlow
```

### 2. Dependencies
```bash
flutter pub get
```

### 3. Run the App
**Mobile (Patient/Doctor):**
```bash
flutter run
```

**Web (Admin/TV Display):**
```bash
flutter run -d chrome --web-renderer html
```

---

## ☁️ Deployment

### Android APK
```bash
flutter build apk --release
```
*Output: `build/app/outputs/flutter-apk/app-release.apk`*

### Admin Web Portal
Host easily with Firebase:
```bash
firebase deploy --only hosting
```

---

## 🔐 Security & Privacy
- **Role-Based Access**: Strict separation between Admin, Doctor, and Patient data.
- **Data Encryption**: All traffic secured via HTTPS/SSL.
- **Private Profiles**: Patient data is visible only to the assigned doctor.

---

<div align="center">
  <sub>Built with ❤️ by the MediFlow Team</sub>
</div>
