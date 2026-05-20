# rental_marketplace (renthub)

Flutter app + backend for a group project

## Getting Started

### Run backend (local)

```bash
cd backend
npm install
npm run dev
```

Backend runs on `http://localhost:3000`

Demo account (idk if this is buyer or seller):
- username: `demo`
- password: `demo123`

### Run Flutter (web / chrome)

From project root:

```bash
flutter pub get
flutter run -d chrome --dart-define=BASE_URL=http://localhost:3000
```
