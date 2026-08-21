# 🛒 NearoMart - Hyperlocal All-Rounder Marketplace

NearoMart is a production-ready, full-stack hyperlocal marketplace application that connects local
buyers, merchants (dukaandars), and delivery agents in real-time. Built with scalability and user
experience in mind, it features a robust role-based architecture, real-time communication, and
geospatial search capabilities.

---

## 🚀 Tech Stack

| Layer             | Technology                                           |
|:------------------|:-----------------------------------------------------|
| **Frontend**      | Flutter (Dart), GetX (State Management & Navigation) |
| **Backend**       | Node.js (Express), JavaScript                        |
| **Database**      | MongoDB Atlas with Geospatial (`2dsphere`) Indexing  |
| **Real-time**     | Socket.IO (Chat, Live Order Updates, Rider Tracking) |
| **Storage**       | AWS S3 (Media, Audio Notes, Banners)                 |
| **Notifications** | Firebase FCM (Push Notifications)                    |
| **Mapping**       | Google Maps SDK / Flutter Map                        |

---

## 👥 User Roles

1. **Buyer (Consumer):**
    * Geospatial store discovery (Nearest First).
    * Cross-shop price comparison matrix.
    * Real-time chat with bargaining/counter-offer engine.
    * Live order tracking with GPS navigation.
2. **Shopkeeper (Merchant):**
    * Catalog management (CRUD, Stock Toggles).
    * Delivery Toggle (Switch between Home Delivery and Pickup Only).
    * Daily Specials & 24-hour Stories.
    * Printable shop QR codes for in-store scanning.
3. **Delivery Agent (Rider):**
    * In-app navigation to store and customer.
    * OTP-verified delivery completion.
    * Earnings dashboard and availability toggle.
4. **Super Admin:**
    * Merchant KYC approval queue.
    * Platform fee and city-wide campaign management.

---

## 🏗️ Architecture & Recent Refactor

The project recently underwent a major **Production-Ready Refactor** to ensure modularity and
scalability:

### Frontend (Flutter)

- **Centralized Design System:** Introduced `AppSizes` and `AppColors` semantic aliases to eliminate
  hardcoded UI values.
- **Clean Architecture:** Reorganized into `core`, `data`, `presentation`, and `routes` layers.
- **Typed Navigation:** Every route now uses structured argument classes (`ProductArguments`,
  `OrderArguments`, etc.) for type-safe data passing.
- **GetX Integration:** Unified state management and dependency injection across all modules.

### Backend (Node.js)

- **Service Layer Pattern:** Extracted complex business logic (stock reservation, fee calculation,
  atomic rollbacks) from controllers into dedicated Services (`OrderService`, `ShopService`,
  `AuthService`).
- **Thin Controllers:** Controllers now handle only HTTP request/response parsing and socket
  broadcasting.
- **Geospatial Integrity:** Atomic stock management to prevent race conditions during
  high-concurrency order placement.

---

## 📂 Project Structure

```
NearoMart/
├── Backend/                 # Node.js Express API
│   ├── src/
│   │   ├── controllers/    # Thin HTTP handlers
│   │   ├── services/       # Core business logic (Refactored)
│   │   ├── models/         # Mongoose Schemas
│   │   ├── routes/         # API Route definitions
│   │   └── middleware/     # Auth & Error handlers
│   └── .env                # Environment variables
├── Frontend/                # Flutter Mobile App
│   ├── lib/app/
│   │   ├── core/           # Theme, Values (AppSizes, Colors), Utils
│   │   ├── data/           # Repositories, Services, Models
│   │   ├── modules/        # Feature-based screens (GetX Modules)
│   │   ├── routes/         # Navigation & Typed Arguments
│   │   └── widgets/        # Reusable Design System components
│   └── pubspec.yaml
└── App Specification.md     # Master product workflow
```

---

## 🛠️ Setup & Installation

### Prerequisites

- Flutter SDK (`^3.12.2`)
- Node.js (`^18.x`)
- MongoDB Atlas Account
- Firebase Project for FCM

### Backend Setup

1. Navigate to `Backend/`.
2. Install dependencies: `npm install`.
3. Create a `.env` file based on `.env.example`.
4. Start the server: `npm start`.

### Frontend Setup

1. Navigate to `Frontend/`.
2. Fetch dependencies: `flutter pub get`.
3. Configure `firebase_options.dart` if necessary.
4. Run the app: `flutter run`.

---

## 📄 License

Internal Project - All Rights Reserved.
