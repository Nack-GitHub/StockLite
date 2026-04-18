# StockLite - Inventory Management System

StockLite is a modern, user-friendly inventory management system built with Flutter. It allows small businesses and individuals to track products, manage stock levels, and monitor sales and purchases efficiently.

## Features

- **Authentication**: Secure login and registration with email/password.
- **Product Management**: Add, edit, and delete products with details like name, category, price, and stock quantity.
- **Stock Tracking**: Real-time stock level monitoring with automatic updates on sales and purchases.
- **Sales & Purchases**: Record sales and purchases to maintain a complete transaction history.
- **Dashboard**: Visual overview of total stock value, low stock items, and recent activities.
- **User Profile**: Manage user profile and account settings.

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

Start the development server:

```bash
flutter run
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
