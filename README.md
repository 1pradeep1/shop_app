# Zenmart

A Flutter shopping app built for the WhiteMatrix Associate Flutter Engineer task.
Login screen, a home feed with search, categories, sorting and infinite scrolling,
plus a product details page.

## Features
- Login with email or 10-digit phone, password validation, inline errors, show/hide password, loading state
- Home feed with product image, name, brand, price and rating
- Infinite scrolling (20 products per page, next page loads 300px before the end)
- Debounced search (400 ms), category chips, sort by price or rating
- Skeleton loading, empty state, error state with retry, pull to refresh
- Favourite toggle with animation
- Shopping bag: add from the details page, change quantity, remove, live total, demo checkout
- Product details page with Hero image transition
- Responsive grid: column count adapts to screen width

## Tech
- Flutter, Dart
- provider (state management)
- http (API calls), cached_network_image, google_fonts
- Data from the public DummyJSON API, no backend needed

## Structure
```
lib/
  main.dart
  core/theme.dart
  models/product.dart
  services/product_service.dart
  providers/product_provider.dart
  screens/login_screen.dart, home_screen.dart, product_details_screen.dart, cart_screen.dart
  widgets/product_card.dart, skeleton_card.dart
```

## Run it
```
flutter pub get
flutter run
```
Build an APK: `flutter build apk --release`

Login is a demo: any valid email or phone with a 6+ character password works.
The app needs an internet connection to load products.

## Screenshots
See the `screenshots/` folder.

## Platforms
Tested on web (flutter run -d chrome); Android code is included. APK not included because no Android SDK was available on my machine.
