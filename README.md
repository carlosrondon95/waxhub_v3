# 🎧 WaxHub — Elevate Your Vinyl Collection

**WaxHub** is a cross-platform application built with **Flutter** that helps vinyl collectors, DJs, and music enthusiasts manage their record collections in a clean, elegant, and intuitive way.

The app blends a minimalist UI with advanced features such as automatic metadata import, smart list creation, and an interactive map of nearby record stores.

---

## 🚀 Key Features

### 🔍 Automatic Cataloging
- Add records to your collection through search.
- WaxHub automatically retrieves artwork, year, label, tracklist, genres, and more using the **Discogs API**.

### 🎛️ Custom Lists
- Create thematic lists: favorites, ambient, techno, jazz, to-buy list, etc.
- Easily filter, reorder, and tag your records.

### 🏪 Interactive Record Store Map
- Discover nearby record stores with the **Google Maps API**.
- Check location, details, distance, and navigation.

### ☁️ Cloud Synchronization
- Real-time syncing using **Firebase Firestore**.
- Secure authentication with **Firebase Auth**.

### 🎨 Clean & Accessible UI
- Professional, minimalist, and accessible design.
- Light color palette with turquoise as the primary color.
- **Poppins** as the main typography.
- Consistent and polished UI across all platforms.

---

## 🏗️ Tech Stack

| Area | Technology |
|------|------------|
| Frontend | Flutter (Dart) |
| Backend | Firebase Firestore |
| Authentication | Firebase Auth |
| External APIs | Discogs API, Google Maps API |
| State Management | Riverpod / Provider |
| Design System | Material 3 + custom theme |
| Maps | Google Maps for Flutter |

---

## 📁 Project Structure
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

---

## 🎯 Purpose of the Project

WaxHub is part of the final project for a **Higher National Diploma in Cross-Platform Application Development (CFGS DAM)**, but it is also a personal project created with passion for vinyl culture.

The goal is to deliver a professional, well-structured, scalable, and polished application by **June 2025**.

---

## 📌 Current Development Status

- [x] Project architecture & folder structure  
- [x] Firebase setup  
- [x] Base screens & navigation  
- [ ] Discogs API integration  
- [ ] Google Maps implementation  
- [ ] Lists, favorites & filters  
- [ ] Final UI adjustments  
- [ ] Testing & polishing  

---

## 🤝 Contributing

This is a personal project, but suggestions and improvements are welcome.  
Feel free to open an issue or reach out.

---

## 📄 License

MIT License.
