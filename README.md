# RoomSync 🏠✨

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Riverpod](https://img.shields.io/badge/State-Riverpod-00599C)](https://riverpod.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**RoomSync** is a modern, swipe/match mobile flatmate finder built with **Flutter**, **Riverpod**, and **Supabase**. It matches prospective flatmates based on real lifestyle compatibility — sleep hours, cleanliness expectations, budgets, and dealbreaker habits — rather than just superficial profile photos.

---

## 📱 Key Features

1. **Native 60fps Profile Swiper Deck**:
   - Built using `flutter_card_swiper` with depth styling.
   - Programmatic floating action buttons (Undo, Pass, Superlike, Like).
   - Dynamic habit comparison tags: *"Clean Freak"*, *"Early Riser"*, *"Pet Friendly"*, *"Smoke-Free"*.
   - Tap-to-inspect full profile sheet (`FlatmateDetailScreen`).

2. **Weighted Compatibility Score Algorithm (0–100%)**:
   - **Budget & Location Match (30%)**: Overlap range ratio + neighborhood cross-matching.
   - **Sleep Schedule Match Window (25%)**: Circular 24-hour clock difference with chronotype alignment bonuses.
   - **Cleanliness Rating Variance (25%)**: Evaluated on a 1 (Relaxed) to 5 (Spotless) scale.
   - **Smoking & Pet Dealbreakers (20%)**: Dealbreaker conflicts (e.g. strict non-smoker with indoor smoker, or pet allergy with pet owner) automatically cap the overall score at **$\le 25\%$**.

3. **Celebratory Mutual Match Overlay**:
   - Triggers immediately when a like results in a mutual match.
   - Overlapping circular avatars, match percentage badge, and immediate jump to chat.

4. **Real-time Messaging & Embedded "Coffee Meetup" Safety Protocol**:
   - 1-on-1 chat interface with simulated flatmate instant dispatch.
   - **Embedded "Coffee Meetup" Safety Action**: Encourages meeting in a busy daylight public cafe before visiting any private apartment. Injects interactive meetup cards directly into the conversation feed.

5. **Apartment & Room Discovery Feed**:
   - Segmented toggle between **Flatmates** and **Apartments** on the Discover screen.
   - Interactive neighborhood filters (Williamsburg, Greenpoint, Bushwick, Cobble Hill, FiDi), furnished badges, and utility inclusions.
   - Host compatibility card embedded inside apartment details with direct "Message Host" and "Propose Public Meetup" safety CTAs.

6. **Multi-step Onboarding & Setup Wizard**:
   - 4-step comprehensive onboarding wizard (`ProfileSetupScreen`) and quick preferences editor (`EditProfileScreen`).
   - Step 1: Personal Info, Bio & Photo
   - Step 2: Interactive Monthly Budget RangeSlider ($500 - $3,500/mo) & Neighborhoods
   - Step 3: Sleep Rhythm, Bedtime/Wake-up Pickers & Cleanliness Scale (1 to 5)
   - Step 4: Smoking, Drinking & Pet Dealbreaker Toggles

7. **Identity Verification & Safety Badges**:
   - Mock Government ID & live selfie verification flow (`VerificationScreen`).
   - "Verified Flatmate" status badge prominently displayed across swipe cards, apartment listings, and chat headers.

8. **Offline-First Persistence**:
   - Key-value preference storage via `shared_preferences`.
   - Local database caching of matches and messages via `sqflite`.

7. **Production Supabase Cloud Integration**:
   - PostgreSQL schema with Row-Level Security (RLS) in `supabase/schema.sql`.
   - Realtime channel PubSub on messages.
   - Seamless toggle between offline demo mode (`useMockData = true`) and production cloud (`useMockData = false`).

---

## 📐 Compatibility Score Mathematical Model

$$\text{Total Score} = (0.30 \times S_{\text{budget\_loc}}) + (0.25 \times S_{\text{sleep}}) + (0.25 \times S_{\text{clean}}) + (0.20 \times S_{\text{smoke\_pet}})$$

If a dealbreaker condition is triggered (severe allergy conflict or indoor smoking conflict):

$$\text{Final Score} = \min(\text{Raw Score} \times 0.35, 25.0)$$

---

## 🛠️ Tech Stack

* **Framework**: Flutter (Dart 3.x)
* **State Management**: Flutter Riverpod (`flutter_riverpod: ^2.5.1`)
* **Swiper Engine**: `flutter_card_swiper: ^7.0.0`
* **Icons & Fonts**: `lucide_icons: ^0.257.0`, `google_fonts: ^6.2.1`
* **Local Storage**: `shared_preferences: ^2.2.3`, `sqflite: ^2.3.3+1`
* **Backend**: Supabase (Auth, Postgres, Realtime, RLS)

---

## 🚀 Getting Started

### 1. Supabase Backend Setup
1. Create a project on [Supabase.com](https://supabase.com).
2. Open the **SQL Editor** in your Supabase dashboard and run the entire script in [`supabase/schema.sql`](file:///c:/Users/lenovo/OneDrive/Desktop/RoomSync/supabase/schema.sql).
3. Copy your project **URL** and **Anon Key** from Project Settings > API.

### 2. Run the App
```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run unit & widget tests
flutter test

# 3. Launch RoomSync with your Supabase credentials
flutter run --dart-define=SUPABASE_URL=https://your-id.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key

# Or run in offline demo guest mode:
flutter run --dart-define=USE_MOCK_DATA=true
```

