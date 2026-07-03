# BabyShopHub — Flutter E-Commerce App

A university-level final project: a full-featured baby products e-commerce app built with Flutter + Firebase.

## Stack

- **Frontend**: Flutter (Dart), Material 3
- **Backend**: Firebase (Auth, Firestore, Storage)
- **State Management**: Provider
- **Architecture**: MVC (Models / Controllers / Screens)

## Running the App

This is a Flutter mobile app targeting Android and iOS. It **cannot be run directly on Replit** (no emulator available). Development is done in Android Studio or VS Code with a connected device/emulator.

To get started locally:
```bash
flutter pub get
flutter run
```

## Firebase Setup

Firebase is already configured (`firebase_options.dart`, `google-services.json`). The project uses:
- `users` — user profiles and roles (user/admin)
- `products` — product catalog
- `carts` — per-user cart (keyed by uid)
- `orders` — placed orders (full snapshots)
- `reviews` — product reviews (Phase 4)

## Project Structure

```
lib/
├── Models/           # Data models (product, cart, order, admin)
├── Controllers/      # Provider controllers (auth, product, cart, order, admin, password)
├── Screens/
│   ├── Authentication/   # Splash, Login, Signup
│   ├── Home/             # MainNavigationScreen, UserHomeScreen
│   ├── Products/         # ProductDetailsScreen
│   ├── Cart/             # CartScreen
│   ├── Checkout/         # AddressScreen → PaymentScreen → OrderConfirmationScreen
│   └── Admin/            # Dashboard, Products, Orders, Users
├── Utils/            # AppTheme, AppNavigator
└── main.dart
```

## Build Progress

| Phase | Feature | Status |
|-------|---------|--------|
| 1 | Firebase Auth, Splash, Role-based routing | ✅ Done |
| 2 | Home, Product grid, Search, Product Details | ✅ Done |
| 3 | Cart | ✅ Done |
| 3 | Checkout (Address → Payment → Confirmation) | ✅ Done |
| 4 | Orders screen, Order tracking | 🔜 Next |
| 4 | Reviews & Ratings | 🔜 Next |
| 5 | Admin Panel | ✅ Done |
| — | Profile screen | 🔜 Next |
| — | Support / FAQ | 🔜 Next |

## Known Issues / TODOs

- Duplicate HomeScreen files (`home_screen.dart` vs `Home_Screen.dart`) — cleanup needed
- SignupScreen instantiates a local `AuthController` instead of reading from Provider
- Orders and Profile tabs in bottom nav are still placeholder screens
- Search is client-side only (no Firestore query)

## User Preferences

- Keep existing project structure and naming conventions (MVC, PascalCase files)
- Use Provider for all state management
- Firebase Firestore for all persistence
- Material 3 design throughout
