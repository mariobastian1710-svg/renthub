# rental_marketplace

Flutter app + simple local backend for assignment.

## Getting Started

### Run backend (local)

```bash
cd backend
npm install
npm run dev
```

Backend runs on `http://localhost:3000`

Demo account:
- username: `demo`
- password: `demo123`

### Run Flutter (web / chrome)

From project root:

```bash
flutter pub get
flutter run -d chrome --dart-define=BASE_URL=http://localhost:3000
```

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
