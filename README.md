StockLite is a modern, user-friendly inventory management system built with Flutter. It allows small businesses and individuals to track products, manage stock levels, and monitor sales and purchases efficiently.

## 📱 Application Overview

StockLite provides a centralized platform for real-time inventory tracking. It simplifies the complexity of warehouse management by providing instant visibility into stock levels, automated status updates (In Stock, Low Stock, Out of Stock), and detailed transaction histories.

### 🎯 Target Users
- **Small Business Owners**: Who need a simple way to track stock without expensive ERP systems.
- **Warehouse Managers**: Looking for a mobile-first tool to update inventory on the go.
- **Individual Sellers**: Managing inventory for e-commerce platforms like Etsy, eBay, or local markets.

## ✨ Features

- **Authentication**: Secure login and registration with email/password.
- **Product Management**: Add, edit, and delete products with details like name, category, price, and stock quantity.
- **Stock Tracking**: Real-time stock level monitoring with automatic updates on sales and purchases.
- **Sales & Purchases**: Record sales and purchases to maintain a complete transaction history.
- **Dashboard**: Visual overview of total stock value, low stock items, and recent activities.
- **User Profile**: Manage user profile and account settings.

## 🏗️ Application Architecture

The application follows a clean, service-oriented architecture:

- **UI Layer (Flutter)**: Handles user interaction and state management.
- **Service Layer**: Decouples business logic from data sources.
    - `AuthService`: Manages user identity via Firebase Auth.
    - `DatabaseService`: Handles real-time synchronization with Cloud Firestore.
    - `LocalStorageService`: Manages persistent local preferences (SharedPreferences).
- **Data Layer (Firebase)**: Cloud-native backend providing authentication and NoSQL database capabilities.

## 🗺️ Page Navigation

The app is organized into a primary tabbed interface for seamless navigation:

- **Login/Sign Up**: Entry point for authentication.
- **Main Navigation (Bottom Tabs)**:
    - **Dashboard**: High-level KPIs and stock alerts.
    - **Products**: Searchable list of all inventory items.
    - **Transactions**: History of stock movements.
    - **Profile**: Account management and settings.
- **Action Screens**:
    - **Add Product**: Dedicated form for new inventory entry.
    - **Product Detail**: View and update specific item stock levels.

## 💾 Data Design

The system uses a hybrid storage approach combining cloud-native persistence with local caching for preferences.

### Firebase Collections
- **`products`**:
    - `name` (String): Product display name.
    - `sku` (String): Unique stock keeping unit identifier.
    - `category` (String): Item classification.
    - `stock` (Number): Current inventory count.
    - `status` (String): Auto-computed (`In Stock`, `Low Stock`, `Out of Stock`).
    - `ownerId` (String): Foreign key to the `users` collection for data isolation.
- **`users`**:
    - `name`, `email` (String): Identity metadata.
    - `role` (String): User permission level.
    - `stats` (Map): Aggregated dashboard data.

### Local Storage (SharedPreferences)
- **`last_email`**: Remembers the most recent successful login for UX speed.
- **`notifications_enabled`**: Persistent user toggle for stock alerts.

## 🔒 Security Considerations

StockLite prioritizes data integrity and privacy through several layers of security:

- **Authentication**: All users must be authenticated via Firebase Auth (Email/Password) before accessing any inventory data.
- **Data Isolation**: Each product document contains an `ownerId`. The service layer strictly filters queries by the current user's UID to prevent cross-tenant data leaks.
- **Real-time Rules**: Firestore Security Rules enforce that users can only read/write documents where the `ownerId` matches their `request.auth.uid`.
- **Validation**: Server-side checks ensure that stock levels cannot be negative and that mandatory fields (name, SKU) are present.

## 🧪 Testing Strategy

The project adheres to a rigorous testing methodology based on the **Test Pyramid Strategy**:

### 1. Testing Levels
- **Unit Testing**: Validates business logic in services (`AuthService`, `DatabaseService`) using `Mocktail` for dependency isolation.
- **Widget Testing**: Ensures UI components (Login, Add Product, etc.) render correctly and handle user input.
- **Integration Testing**: Verified E2E flows (Login -> Add Product -> Logout) on real devices and browsers (Chrome/Android).

### 2. Design Techniques
- **Boundary Value Analysis (BVA)**: Applied to password lengths (8-16 chars) and stock thresholds (0, 10).
- **Equivalence Partitioning (EP)**: Used for email validation and password complexity.
- **State Transition Testing**: Validates stock status changes (In Stock -> Low Stock -> Out of Stock).
- **Decision Table Testing**: Ensures complex filtering logic in the product catalog works across all condition combinations.

### 3. Requirements Traceability Matrix (RTM)

This matrix maps the core application requirements to the specific test scripts that validate them, ensuring 100% feature coverage.

| Req ID | Feature / Requirement | Test Script | Test Level | Status |
|--------|-----------------------|-------------|------------|--------|
| **R1** | **User Authentication** | `login_screen_test.dart` | Widget | ✅ PASS |
| **R1.1**| User Registration | `sign_up_screen_test.dart` | Widget | ✅ PASS |
| **R1.2**| Auth Service Logic | `auth_service_test.dart` | Unit | ✅ PASS |
| **R2** | **App Navigation Flow** | `demo_test.dart` | Integration | ✅ PASS |
| **R3** | **Cross-Platform Stability**| `app_test.dart` | Integration | ✅ PASS |
| **R4** | **Inventory Management** | `add_product_screen_test.dart` | Widget | ✅ PASS |
| **R4.1**| Product Detail Updates | `product_detail_screen_test.dart`| Widget | ✅ PASS |
| **R4.2**| Catalog Search & Filter | `home_screen_test.dart` | Widget | ✅ PASS |
| **R4.3**| Data Persistence Logic | `database_service_test.dart` | Unit | ✅ PASS |

> [!TIP]
> Each test script employs academic black-box techniques (BVA, EP, etc.) as detailed in the Testing Strategy section above.

## Getting Started

### Prerequisites

- Flutter SDK (2.8.0 or higher)
- Firebase CLI (for deployment)

### Installation

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd stock_lite
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Create a Firebase project at [https://console.firebase.google.com/](https://console.firebase.google.com/)
   - Add an iOS app and an Android app to your Firebase project
   - Download the configuration files:
     - iOS: `GoogleService-Info.plist`
     - Android: `google-services.json`
   - Place these files in the `ios/Runner/` and `android/app/` directories respectively
   - Run `flutterfire configure` to link your project

### Running the App

To run the application in development mode:

```bash
flutter run
```

### Running Tests

To verify that the installation was successful and all features are working correctly, run the automated test suite:

**1. Unit & Widget Tests:**

```bash
flutter test
```

**2. Integration Tests (Web/Chrome):**

We provide a helper script to automate the ChromeDriver management and test execution:

```bash
chmod +x run_web_test.sh
./run_web_test.sh
```

Alternatively, you can run the steps manually:

- **Step 0:** Kill all running Chrome and ChromeDriver processes:
  ```bash
  killall chromedriver
  killall "Google Chrome"
  ```
- **Step 1:** Start ChromeDriver in a separate terminal:
  ```bash
  chromedriver --port=4444
  ```
- **Step 2:** Run the integration test:
  ```bash
  flutter drive --driver=test_driver/integration_test.dart --target=integration_test/demo_test.dart -d chrome
  ```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── services/              # Business logic and API services
│   ├── auth_service.dart  # Authentication service
│   ├── database_service.dart # Database operations
│   └── notification_service.dart # Push notifications
├── screens/               # UI screens
│   ├── login_screen.dart
│   ├── sign_up_screen.dart
│   ├── home_screen.dart
│   ├── product_detail_screen.dart
│   ├── add_product_screen.dart
│   ├── profile_screen.dart
│   └── ...
├── models/                # Data models
│   ├── product.dart
│   ├── user_profile.dart
│   └── ...
├── theme/                 # App theme and styles
│   └── app_theme.dart
└── utils/                 # Utility functions
    └── validators.dart
```

## Development

### Adding New Features

1. Create a new screen in `lib/screens/`
2. Add a corresponding route in `lib/main.dart`
3. Update `lib/services/` with any necessary business logic
4. Add models to `lib/models/` if needed
5. Test thoroughly

### Running Tests

Run all tests:

```bash
flutter test
```

Run with coverage:

```bash
flutter test --coverage
```

### Integration Tests

Integration tests run a full end-to-end flow.

**Run on Chrome:**

```bash
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/demo_test.dart -d chrome
```

**Run on Android/iOS Emulator:**

```bash
flutter test integration_test/app_test.dart
```

```bash
flutter test integration_test/widget_tree_dump.dart
```

```bash
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/demo_test.dart -d emulator
```

> [!NOTE]
> Make sure an emulator is running before starting the integration tests.

## Deployment

### Build for Android

```bash
flutter build appbundle --release
```

### Build for iOS

```bash
flutter build ipa --release
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Contact

For questions or support, please contact [Your Name/Team] at [Your Email Address].
