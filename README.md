<div align="center">

# 🎓 VTour

**A virtual campus guide for university students and visitors**

Explore campus locations on an interactive map, follow turn-by-turn walking directions, and step inside hostel rooms with 360° panoramas.

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE.md)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=flat&logo=supabase&logoColor=white)](https://supabase.com/)
[![Google Maps](https://img.shields.io/badge/Google%20Maps-4285F4?style=flat&logo=googlemaps&logoColor=white)](https://developers.google.com/maps)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20Android-lightgrey?style=flat)](#-platform-support)

[Features](#-features) • [Tech Stack](#-tech-stack) • [Architecture](#-architecture) • [Project Structure](#-project-structure) • [Getting Started](#-getting-started) • [Install the iOS Build](#-install-the-ios-build)

</div>

---

## 📱 Install the iOS Build

The latest signed iOS build is available through Apps on Air:

**[→ Install on iPhone](https://app.appsonair.com/install/b8Fip9ir)**

Prefer sideloading, or need the `.ipa`? See [Sideloading via AltStore](#-sideloading-via-altstore).

---

## 🎯 About

VTour turns campus orientation into something you can do from your phone. Locations, hostels, and room data are served from Supabase, rendered over Google Maps, and paired with live GPS navigation so a prospective student can find a building — or picture a hostel room — before ever setting foot on campus.

The app is organised around five tabs: **Home**, **Tour**, **Explore**, **Hostels**, and **About**.

## ✨ Features

| Feature | What it does |
|---|---|
| 🗺️ **Interactive campus map** | Every location plotted with Google Maps, tappable markers, and a normal/satellite toggle |
| 🧭 **Live navigation** | Turn-by-turn walking directions from your GPS position via the Google Directions API, with a tilted follow-camera and an audio cue on arrival |
| 🏠 **Hostel explorer** | Browse hostels filtered by gender type, drill into room types, and view photo galleries |
| 🔄 **360° room walkthrough** | Gyroscope-driven panoramic view of hostel rooms — move your phone to look around |
| 🔍 **Search & filter** | Filter locations by category and search across names and descriptions, in both map and list views |
| 🖼️ **Photo galleries** | Full-screen, pinch-to-zoom photo viewer with network image caching |
| 🔐 **Authentication** | Email/password sign-up and sign-in, plus Google Sign-In, backed by Supabase Auth |
| 🎵 **Audio guides** | Voiceover text stored per location for narrated descriptions |

## 📸 Screenshots

<div align="center">

### Authentication & Onboarding
<p>
<img src="/assets/images/IMG_0395.png" alt="Welcome screen" width="180">
<img src="/assets/images/IMG_0396.png" alt="Login screen" width="180">
<img src="/assets/images/IMG_0397.png" alt="Sign up screen" width="180">
<img src="/assets/images/IMG_0398.png" alt="Profile setup" width="180">
</p>

### Dashboard & Campus Navigation
<p>
<img src="/assets/images/IMG_0399.png" alt="Home dashboard" width="180">
<img src="/assets/images/IMG_0400.png" alt="Turn-by-turn navigation" width="180">
<img src="/assets/images/IMG_0401.png" alt="Campus map" width="180">
<img src="/assets/images/IMG_0402.png" alt="Location details" width="180">
</p>

### Hostel Explorer
<p>
<img src="/assets/images/IMG_0403.png" alt="Hostel explorer" width="180">
<img src="/assets/images/IMG_0405.png" alt="Hostel room details" width="180">
</p>

</div>

## 🧰 Tech Stack

### By layer

| Layer | Technology |
|---|---|
| **UI** | Flutter (Material Design, centralised theming in `AppTheme`) |
| **Language** | Dart 3 |
| **State management** | `provider` — `ChangeNotifier` + `Consumer` |
| **Backend** | Supabase (PostgreSQL, Auth, Storage) |
| **Auth** | Supabase email/password and Google Sign-In via OAuth ID token |
| **Maps & geo** | Google Maps SDK, Directions API, Geocoding API |
| **Location** | `geolocator` for live position and heading |
| **360° media** | `panorama` with device-orientation sensor control |
| **Config** | `flutter_dotenv` — secrets loaded from `.env` at startup |

### Key packages

| Package | Version | Used for |
|---|---|---|
| `supabase_flutter` | ^2.5.0 | Database queries, auth, session streams |
| `provider` | ^6.0.5 | App-wide state (`LocationProvider`) and DI |
| `google_maps_flutter` | ^2.6.0 | Map rendering, markers, polylines, camera control |
| `geolocator` | ^12.0.0 | Live GPS position and heading |
| `geocoding` | ^2.1.1 | Address ↔ coordinate conversion |
| `http` | ^1.2.0 | Direct REST calls to Directions and Geocoding APIs |
| `panorama` | ^0.4.1 | 360° hostel room walkthroughs |
| `google_sign_in` | ^6.1.4 | Google OAuth flow |
| `flutter_dotenv` | ^5.1.0 | Environment variables |
| `cached_network_image` | ^3.3.0 | Image caching for location and room photos |
| `audioplayers` | ^6.0.0 | Arrival chime during navigation |
| `google_fonts` | ^6.1.0 | Typography |
| `flutter_staggered_animations` | ^1.1.1 | List and grid entry animations |
| `shared_preferences` | ^2.0.15 | Lightweight local persistence |
| `url_launcher` | ^6.3.0 | Opening external links |

> **Note:** `pubspec.yaml` also declares `image_picker`, `permission_handler`, `location`, `app_links`, `uni_links`, `flutter_polyline_points`, `flutter_svg`, and `path`, which are not currently referenced from `lib/`. They are safe to prune. `path_provider` is used in `lib/utils/isolate_helper.dart` but resolves transitively rather than being declared — add it explicitly if that helper gets wired up.

## 🧱 Architecture

A straightforward layered flow, with `provider` as the seam between data and UI:

```text
┌──────────────────────────────────────────┐
│  Screens & Widgets                       │  Consumer<LocationProvider>
└──────────────────┬───────────────────────┘
                   │  notifyListeners()
┌──────────────────▼───────────────────────┐
│  Providers        LocationProvider       │  filtering, search, selection, loading state
└──────────────────┬───────────────────────┘
                   │
┌──────────────────▼───────────────────────┐
│  Services   LocationService  AuthService │  Supabase queries, auth, REST calls
│             HostelService  Geocoding…    │
└──────────────────┬───────────────────────┘
                   │
┌──────────────────▼───────────────────────┐
│  Models     Location    HostelRoom       │  fromJson / toJson
└──────────────────┬───────────────────────┘
                   │
┌──────────────────▼───────────────────────┐
│  Supabase (PostgreSQL)  ·  Google APIs   │
└──────────────────────────────────────────┘
```

**Startup sequence** (`lib/main.dart`): load `.env` → read the Google Maps key → initialise Supabase → register `AuthService` and `LocationProvider` → run the app. An `onAuthStateChange` listener drives navigation, pushing to `MainNavigation` on sign-in and back to `WelcomeScreen` on sign-out.

### Database schema

Two Supabase tables back the app:

**`locations`**

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key |
| `name` | text | Location name |
| `category` | text | Academic Block, Hostel, Cafeteria, Library, Laboratory, Sports Ground, Other |
| `description` | text | Long-form description |
| `image_path` | text | Cover image URL |
| `video_path` | text | Video URL |
| `latitude` / `longitude` | float8 | Map position |
| `features` | text[] | Feature chips |
| `voiceover_text` | text | Narration script |
| `is_available` | bool | Defaults to true |
| `user_id` | uuid | Owner, for write policies |
| `gender_type` | text | `Mens Hostel` / `Ladies Hostel`, hostels only |

**`hostel_rooms`**

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | Primary key |
| `location_id` | uuid | References `locations.id` |
| `room_type` | text | e.g. Single, Double, Triple |
| `photo_urls` | text[] | Gallery images |
| `features` | text[] | Room amenities |
| `pano_url` | text | Equirectangular image for the 360° walkthrough |

## 📁 Project Structure

```text
VTOUR/
├── lib/
│   ├── main.dart                          # Entry point: .env, Supabase init, routes, providers
│   │
│   ├── models/
│   │   ├── location_model.dart            # Location + LocationCategory enum & extensions
│   │   └── hostel_room_model.dart         # HostelRoom (photos, features, pano URL)
│   │
│   ├── providers/
│   │   └── location_provider.dart         # ChangeNotifier: fetch, filter, search, CRUD
│   │
│   ├── services/
│   │   ├── auth_service.dart              # Supabase auth + Google Sign-In
│   │   ├── location_service.dart          # locations & hostel_rooms queries
│   │   ├── hostel_service.dart            # Rooms lookup by location ID
│   │   └── geocoding_service.dart         # Google Geocoding REST wrapper
│   │
│   ├── screens/
│   │   ├── splash_screen.dart             # Launch screen
│   │   ├── WelcomeScreen.dart             # Unauthenticated landing
│   │   ├── login_screen.dart              # Email/password + Google sign-in
│   │   ├── signup_screen.dart             # Registration
│   │   ├── main_navigation.dart           # 5-tab shell (bottom nav + TabBarView)
│   │   ├── home_screen.dart               # Dashboard, quick actions, highlights
│   │   ├── tour_screen.dart               # Category-filtered virtual tour list
│   │   ├── explore_screen.dart            # Map view / list view tabs with search
│   │   ├── location_detail_screen.dart    # Details, features, voiceover, navigate
│   │   ├── navigation_screen.dart         # Live turn-by-turn navigation
│   │   ├── hostel_explore_screen.dart     # Hostel list with gender & search filters
│   │   ├── hostel_room_type_screen.dart   # Room types, photos, amenities
│   │   ├── hostel_room_walkthrough_screen.dart  # 360° panorama viewer
│   │   ├── photo_view_screen.dart         # Full-screen photo viewer
│   │   ├── custom_search_delegate.dart    # Search UI delegate
│   │   └── about_screen.dart              # App info and feature list
│   │
│   ├── widgets/
│   │   ├── campus_map_widget.dart         # Campus map with location markers
│   │   ├── enhanced_campus_map_widget.dart# Extended map variant (currently unreferenced)
│   │   ├── navigation_map_widget.dart     # Route polylines and directions
│   │   ├── location_card.dart             # List-style location card
│   │   ├── location_grid_item.dart        # Grid-style location tile
│   │   ├── featured_location_card.dart    # Highlighted location card
│   │   ├── home_screen_widgets.dart       # Composed home sections
│   │   ├── quick_action_card.dart         # Dashboard action tile
│   │   ├── search_bar_widget.dart         # Reusable search field
│   │   └── feature_chip.dart              # Amenity/feature chip
│   │
│   ├── config/
│   │   └── home_screen_config.dart        # Quick actions, highlights, events data
│   ├── data/
│   │   └── mock_data.dart                 # Sample data (currently unreferenced)
│   └── utils/
│       ├── app_theme.dart                 # Colours, typography, theme
│       └── isolate_helper.dart            # Background asset loading (currently unreferenced)
│
├── assets/
│   ├── audio/arrived.mp3                  # Navigation arrival cue
│   ├── icons/                             # App logo
│   └── images/                            # Screenshots and image assets
│
├── android/  ios/  macos/  linux/  windows/
├── pubspec.yaml
├── analysis_options.yaml
├── LICENSE.md
└── README.md
```

## 📲 Platform Support

| Platform | Status |
|---|---|
| **iOS** | Supported — deployment target 16.0, Google Maps configured in `AppDelegate.swift` |
| **Android** | Builds, but needs the Maps API key and location permissions added (see below) |
| macOS / Linux / Windows | Scaffolded by `flutter create`, not targeted |

## 🚀 Getting Started

### Prerequisites

- **Flutter** 3.10 or newer, with **Dart** 3.x
- **Xcode** 15+ for iOS builds (target iOS 16.0)
- **Android Studio** with an SDK matching the Flutter toolchain (Gradle 8.12)
- A **Supabase** project with the `locations` and `hostel_rooms` tables above
- A **Google Cloud** API key with these APIs enabled:
  - Maps SDK for Android and Maps SDK for iOS
  - Directions API
  - Geocoding API
- A **Google OAuth client ID** for Google Sign-In

### 1. Clone and install

```bash
git clone https://github.com/ritik-roushan-rana/VTOUR.git
cd VTOUR
flutter pub get
```

### 2. Configure environment variables

Create a `.env` file in the project root. It is gitignored and read at startup by `flutter_dotenv`.

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
GOOGLE_SIGN_IN_CLIENT_ID=your-oauth-client-id
```

All four are required — `main.dart` and `AuthService` read them with `!`, so a missing value throws at launch.

### 3. Platform configuration

**iOS** — the native Maps SDK reads its key from `GMSServicesAPIKey` in `ios/Runner/Info.plist`, which `AppDelegate.swift` passes to `GMSServices.provideAPIKey()`. Set your own key there.

> ⚠️ A key is currently committed in `Info.plist`. Rotate it and apply platform + API restrictions in Google Cloud Console before shipping.

**Android** — the manifest does not yet declare the Maps key or location permissions, so maps render blank and navigation cannot get a fix. Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET"/>

<application ...>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_ANDROID_MAPS_API_KEY"/>
    ...
</application>
```

### 4. Run

```bash
flutter run                  # first connected device
flutter run -d <device-id>   # pick a device
flutter devices              # list available devices
```

### 5. Build a release

```bash
flutter build apk --release       # Android APK
flutter build appbundle --release # Play Store bundle
flutter build ios --release       # iOS (signing required)
```

### Development commands

```bash
flutter analyze     # static analysis
flutter test        # run tests
dart format lib/    # format source
```

## 🎮 How to Use

1. **Sign in** — create an account with email and password, or continue with Google
2. **Home** — jump into a tour, open the map, or browse campus highlights
3. **Tour** — filter locations by category and open any one for details, features, and voiceover
4. **Explore** — search locations and switch between map and list views
5. **Hostels** — filter by gender type, pick a room type, and open the 360° walkthrough
6. **Navigate** — from any location, start live turn-by-turn directions to it

## 📥 Sideloading via AltStore

Publishing to the App Store needs a paid Apple Developer account, so the `.ipa` can be sideloaded instead.

<details>
<summary><b>Step-by-step instructions</b></summary>

### 1. Install AltStore

1. Download **AltServer** for Mac or Windows from [altstore.io](https://altstore.io)
2. Install and launch AltServer on your computer
3. Connect your iPhone over USB and confirm it appears in Finder (Mac) or iTunes (Windows)
4. In AltServer, choose **Install AltStore → [Your Device]**
5. Sign in with your Apple ID (a free account works)
6. On your iPhone, open `Settings → General → VPN & Device Management` and trust your Apple ID

### 2. Get the `.ipa`

Download the latest build from [Releases](https://github.com/ritik-roushan-rana/VTOUR/releases), then save it to your iPhone via AirDrop, iCloud Drive, or email.

### 3. Install

1. Open **AltStore** on your iPhone
2. Go to **My Apps → +** (top-left)
3. Select `Runner.ipa` and wait for signing to finish

### Notes

- Apps signed with a free Apple ID **expire after 7 days**. Refresh in AltStore with AltServer running to renew.
- A paid Apple Developer account removes the 7-day limit.

**Helpful links:** [AltStore](https://altstore.io) · [Setup FAQ](https://altstore.io/faq/) · [Sideloadly](https://sideloadly.io)

</details>

## 🗺️ Roadmap

- [ ] Wire up the Android Maps key and location permissions
- [ ] Real audio playback for location voiceovers (currently a simulated 3-second state toggle)
- [ ] Implement the placeholder quick actions: Search, Favorites, Events
- [ ] Replace the "Start Virtual Tour" dialog with an actual guided tour flow
- [ ] Prune unused dependencies from `pubspec.yaml`
- [ ] Resolve dead code: `mock_data.dart`, `isolate_helper.dart`, and `enhanced_campus_map_widget.dart` are unreferenced
- [ ] Widget and integration test coverage

## 🤝 Contributing

Contributions are welcome.

1. Fork the repository
2. Create a branch: `git checkout -b feature/your-feature`
3. Run `flutter analyze` and confirm it is clean
4. Commit and push, then open a pull request

## 📄 License

Released under the MIT License. See [LICENSE.md](./LICENSE.md).

---

<div align="center">

Built with Flutter by [Ritik Roushan Rana](https://github.com/ritik-roushan-rana)

</div>
