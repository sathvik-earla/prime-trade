# The Five Friends Series (Flutter & Dart Edition)

An illustrated storybooks, audio narrations, and exclusive bookstore application written in **Flutter 3 & Dart**.

## Features Included
1. **Compulsory Login Gate**:
   - Compulsory login screen on launch (`lib/screens/login_screen.dart`).
   - Reader sign-in (Name, Email) and quick 1-tap presets.
   - Owner access strictly locked with password `RTS590` (`lib/services/auth_service.dart`).
2. **Prominent Publishing Helpline Banner**:
   - `Call +91 9398638545 Or +91 85905 63007 for publishing a book`
   - Integrated with direct one-tap calling via `url_launcher`.
3. **Bookstore Catalog & Filter**:
   - Filter by format (Storybooks, Novels, Short Stories, Comics, Audiobooks, Poetry, Scripts).
   - Filter by genre (Adventure, Bedtime, Fantasy, Mythology, Sci-Fi).
   - Search by title, author, and description.
4. **Interactive Reader**:
   - Page-by-page reader with font size adjustments and themes (Dark, Sepia, Light).
   - Simulated voice audio narration.
   - Free sample restriction for unpaid stories with instant checkout prompt.
5. **Checkout & Cash on Delivery (COD)**:
   - UPI, Cards, and Cash on Delivery with full address input.
6. **Owner Publishing Portal**:
   - Profile badge for authorized owners (`earlasathvik.rs@gmail.com`, etc.).
   - "4. Custom Book Covers" image URL and asset support.
   - Publish, manage, and delete books in real time.

## Project Structure
```
flutter_project/
├── pubspec.yaml
├── README.md
└── lib/
    ├── main.dart                      # App entry point, MultiProvider & AuthGate
    ├── models/
    │   ├── story_item.dart            # StoryItem, Chapter, DocumentAttachment
    │   └── user_models.dart           # OwnerUser, ReaderUser, PurchaseRecord
    ├── services/
    │   ├── auth_service.dart          # RTS590 verification, sessions & hotline
    │   └── storage_service.dart       # SharedPreferences persistence
    ├── widgets/
    │   └── publishing_banner.dart     # Hotline banner widget
    └── screens/
        ├── login_screen.dart          # Compulsory Login & phone hotline
        ├── library_screen.dart        # Bookstore & format filters
        ├── reader_screen.dart         # Paginated reader with narration & audio
        ├── checkout_screen.dart       # UPI / Card / Cash on Delivery checkout
        └── owner_portal_screen.dart   # Publishing portal & Custom Book Covers
```

## How to Run

### Prerequisites
- Install [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.0.0 or later)
- Android Studio / Xcode / VS Code

### Steps to Run
```bash
# 1. Navigate to the flutter project directory
cd flutter_project

# 2. Get dependencies
flutter pub get

# 3. Run on connected Android / iOS device or Chrome
flutter run

# 4. Build release APK for Android
flutter build apk --release

# 5. Build for iOS
flutter build ios --release

# 6. Build for Web
flutter build web --release
```
