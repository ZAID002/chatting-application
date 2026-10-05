# 💬 ZeeChat — Real-Time Chat Application

**ZeeChat** is a modern real-time messaging application built with **Flutter and Dart**, designed with a focus on smooth interactions, clean UI, and maintainable software architecture.

The project explores how a mobile application can handle **real-time communication, authentication, message states, user interactions, and responsive UI** while keeping the codebase scalable and organized.

---



---

## ✨ Key Features

* 💬 Real-time one-to-one messaging
* 🔐 User authentication
* 🔵 Message read receipts
* 🟢 Online / offline user status
* ⚡ Real-time message updates
* 🖼️ Profile image support
* 📱 Mobile-first responsive interface
* 🎨 Clean and modern chat UI
* 🔄 Loading and interaction states
* 📡 Firebase/API-based data communication

---

## 🏗️ Architecture

ZeeChat follows a **layered architecture** to keep UI, business logic, and data operations separated.

```text
Presentation Layer
        ↓
State Management
        ↓
Repository / Business Logic
        ↓
Services / APIs
        ↓
Firebase / Database
```

### Application Flow

```text
User Interaction
       ↓
UI / Controller
       ↓
State Management
       ↓
Repository / Service
       ↓
Database / API
       ↓
State Update
       ↓
UI Refresh
```

This structure makes it easier to maintain the application and add new features without tightly coupling the UI with backend operations.

---

## 🗄️ Data Model

### 👤 Users

| Field      | Type   | Description             |
| ---------- | ------ | ----------------------- |
| `uid`      | String | Unique user identifier  |
| `username` | String | User display name       |
| `email`    | String | User email              |
| `status`   | String | Online / Offline status |

### 💬 Messages

| Field         | Type     | Description               |
| ------------- | -------- | ------------------------- |
| `msg_id`      | String   | Unique message identifier |
| `sender_id`   | String   | ID of the sender          |
| `receiver_id` | String   | ID of the receiver        |
| `content`     | String   | Message content           |
| `timestamp`   | DateTime | Message creation time     |
| `is_read`     | Boolean  | Message read status       |

---

## 🛠️ Tech Stack

| Technology                  | Purpose                           |
| --------------------------- | --------------------------------- |
| **Flutter**                 | Cross-platform mobile development |
| **Dart**                    | Application programming           |
| **Firebase Authentication** | User authentication               |
| **Cloud Firestore**         | Real-time data and messaging      |
| **REST/API Services**       | Application communication         |
| **Git & GitHub**            | Version control                   |

---

## 🎯 Interaction & UX

The project focuses not only on making the features work, but also on **how the application responds to user actions**.

Examples include:

* Immediate visual feedback after user actions
* Clear message delivery and read states
* Loading states during asynchronous operations
* Empty states when no conversations are available
* Responsive layouts for different mobile screen sizes
* Simple navigation between conversations and user profiles
* Consistent spacing, typography, icons, and components

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/ZAID002/chatting-application.git

cd chatting-application
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

Add the required Firebase configuration files:

**Android**

```text
android/app/google-services.json
```

**iOS**

```text
ios/Runner/GoogleService-Info.plist
```

Then configure the Firebase project according to your environment.

### 4. Run the Application

```bash
flutter run
```

---

## 📂 Project Structure

```text
lib/
├── screens/
├── widgets/
├── models/
├── services/
├── repositories/
├── providers/
└── main.dart
```

The structure may evolve as new features are introduced.

---

## 🔮 Future Improvements

* 🔒 End-to-end message encryption
* 🎤 Voice messages
* 📎 File and media sharing
* 👥 Group conversations
* 🔔 Improved push notification handling
* 🌙 Enhanced theme support
* 📱 Further performance optimization for low-end devices

---

## 👨‍💻 Developer

### Zaid Chaudhary

**Software Engineering Student | Flutter & Dart Developer**

I enjoy building mobile applications with a focus on **clean architecture, reusable components, intuitive interactions, and practical user experiences.**

GitHub:
https://github.com/ZAID002

---

## ⭐ Project

ZeeChat is a portfolio and learning project created to explore **real-time communication, mobile UI/UX, state management, backend integration, and scalable application architecture**.
