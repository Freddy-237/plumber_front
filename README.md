# Plumber (Flutter client)

Short description
A Flutter client app for the Plumber project (authentication + chat prototype).

Requirements
- Flutter SDK >= 3.x
- Dart
- Node.js backend reachable at `http://<host>:3000` (see Backend notes)
- For Android Emulator: use `10.0.2.2` as API host if backend runs on host machine

Quickstart
1. Install dependencies:
```
flutter pub get
```

2. Update API base URL (if needed):
- See `lib/services/api_client.dart` and `lib/services/auth_service.dart`
- For Android emulator: set `baseUrl` to `http://10.0.2.2:3000`
- For a real device: set to host IP `http://<your-machine-ip>:3000`

3. Run the app:
```
flutter run
```

Notes
- Backend routes are expected under `/api/auth` (e.g. `/api/auth/register`, `/api/auth/login`).
- Server should bind to `0.0.0.0` for device/emulator connectivity: `app.listen(3000, '0.0.0.0')`.
- If you want me to create and push a GitHub repo, tell me your preferred repo name and whether you want it public or private.
# plumber

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
