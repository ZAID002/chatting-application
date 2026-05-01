💬 Zee Chat Application

A high-performance, real-time messaging application built with Flutter & Dart.
This project follows modern software engineering principles to ensure scalability, maintainability, and smooth user experience.

🏗 System Architecture

Project follows Layered / Clean Architecture approach:

1. High-Level Structure
Presentation Layer → Flutter UI Screens & Widgets
Business Logic Layer → State Management (Provider / Bloc)
Data Layer → Repositories & Firebase / API services
2. App Workflow
User Input ➝ Controller / Provider ➝ Service / API ➝ Database ➝ UI Update
📊 Database Schema
👤 Users Table
Field	Type	Description
uid	String	Unique user ID
username	String	Display name
email	String	User email
status	String	Online / Offline status
💬 Messages Table
Field	Type	Description
msg_id	String	Unique message ID
sender_id	String	Sender user ID
receiver_id	String	Receiver user ID
content	Text	Message text
timestamp	DateTime	Message sent time
is_read	Boolean	Read receipt (blue ticks)
🚀 How to Run Project
1. Clone Repository
git clone https://github.com/your-username/zee-chat.git
cd zee-chat
2. Install Dependencies
flutter pub get
3. Setup Firebase / Environment
Add google-services.json (Android)
Add GoogleService-Info.plist (iOS)
Configure Firebase project settings
4. Run App
flutter run
🛠 Features
⚡ Real-time Messaging (Streams / WebSockets)
🔵 Read Receipts (Blue Tick System)
🎨 Clean & Modern UI
🔐 Secure Authentication (Login / Signup)
📱 Responsive UI (Mobile optimized)

👨‍💻 Developer

Zaid Chaudhary
Software Engineer | Flutter & Dart Developer 🚀

⭐ Note

This project is built for learning + portfolio purposes and follows scalable software architecture principles.
