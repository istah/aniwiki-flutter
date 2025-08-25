# AniWiki

AniWiki is a simple app that lets you search and browse information about anime, manga, and characters.  
It’s built with **Flutter (frontend)** and a **Python (Flask) backend** that wraps the [Jikan API](https://docs.api.jikan.moe/).

The app supports:

- Anime/Manga/Character search with pagination
- Detail pages for anime
- Light/Dark theme toggle with persistence
- Loading skeletons and error handling
- Responsive UI that adapts to smaller screens
- Deployable both as a Flutter web app and as mobile apps (Android/iOS)

---

## ✨ Project overview

- **Frontend**: Flutter web app, deployed on Firebase Hosting
- **Backend**: Python (Flask), deployed on PythonAnywhere
- **Data Source**: [Jikan API](https://docs.api.jikan.moe/)
- **Routing**: `go_router` for sharable links
- **State/UX**: skeleton loaders, retry UI, adaptive grid layout
- **Persistence**: SharedPreferences for theme toggle

---

## 🚀 Installation & Running locally

### Backend

`````bash
git clone https://github.com/<your-username>/aniwiki-flutter.git
cd aniwiki-flutter/backend

# (optional) create venv
python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt

# Run locally
python main.py
# API now available at http://127.0.0.1:8000

Test endpoints:
	•	GET /health
	•	GET /api/anime/search?q=naruto&page=1&limit=5
	•	GET /api/manga/search?q=one piece&page=1&limit=5
	•	GET /api/characters/search?q=naruto&page=1&limit=5
	•	GET /api/anime/<id>

### Frontend
````bash
cd ../app

# Run in dev mode with backend url
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
`````
