# 🎧 WaxHub — Elevate Your Vinyl Collection

**Cross-platform application** designed for the complete management of vinyl
collections, helping DJs and music enthusiasts organize their records in a
clean, elegant, and intuitive way.

The app blends a minimalist UI with advanced features such as automatic metadata
import, smart list creation, and an interactive map of nearby record stores.

---

## 🚀 Key Features

### 🔍 Automatic Cataloging

- **Smart Import:** Automatically retrieves artwork, year, label, tracklist, and
  genres using the **Discogs API**.
- **Effortless Organization:** Add records to your collection through a seamless
  search experience.

### 🎛️ Custom Lists & Management

- **Thematic Lists:** Create favorites, ambient, techno, jazz, or "to-buy"
  lists.
- **Advanced Filtering:** Easily filter, reorder, and tag your records.

### 🏪 Interactive Record Store Map

- **Discovery:** Find nearby record stores using the **Google Maps API**.
- **Details:** View location, store details, distance, and get navigation
  directions.

### ☁️ Cloud & Security

- **Real-time Sync:** Powered by **Firebase Firestore**.
- **Secure Access:** robust authentication via **Firebase Auth**.

### 🎨 Premium UI

- **Design:** Professional, minimalist interface with a turquoise-accented light
  palette.
- **Typography:** Uses **Poppins** for a modern, clean look.

---

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart) – Material 3 Design.
- **Backend:** Firebase Firestore (NoSQL Database).
- **Authentication:** Firebase Auth.
- **External APIs:** Discogs API (Metadata), Google Maps SDK (Location).
- **State Management:** Provider.
- **Maps:** Google Maps for Flutter.

---

## 🎥 Demo Video

▶️
**[Watch Demo](https://drive.google.com/file/d/17KulAnAmPQrUlADC_V2btoYp8bflnsLh/view?usp=sharing)**

---

## 📁 Project Structure

```text
lib/
├── core/
│   ├── themes/              # Global theme: colors, typography, styles
│   └── utils/               # Generic helpers and utilities
│
├── models/                  # Data models (Vinyl, User, List…)
│
├── services/                # Discogs, Maps, Firebase integrations
│
├── providers/               # Global state & business logic
│
├── routes/                  # App navigation
│
├── screens/                 # Main screens (Home, Collection, Map…)
│
├── widgets/                 # Reusable UI components (cards, buttons…)
│
├── firebase_options.dart    # Auto-generated Firebase config
└── main.dart                # App entry point
```

---

## 🎯 Purpose

WaxHub is developed as the final project for a **Higher National Diploma in
Cross-Platform Application Development (CFGS DAM)**, combining academic rigor
with a genuine passion for vinyl culture.

The goal is to deliver a professional, scalable, and polished application that
solves real problems for collectors.

---

## 📄 License

MIT License.
