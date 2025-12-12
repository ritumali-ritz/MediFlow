# Smart Health Queue - Deployment Guide

## Prerequisites
- Flutter SDK installed
- Firebase project configured
- `google-services.json` added to `android/app/`
- `firebase_options.dart` generated

## Mobile App Deployment

### Android
```bash
# Build release APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
# Build release
flutter build ios --release

# Open Xcode for signing
open ios/Runner.xcworkspace
```

## Web App Deployment (Admin Portal)

### Build
```bash
flutter build web --release
```

### Deploy to Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize (if not done)
firebase init hosting

# Deploy
firebase deploy --only hosting
```

### Firebase Hosting Configuration
Update `firebase.json`:
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [{
      "source": "**",
      "destination": "/index.html"
    }]
  }
}
```

## Backend Deployment

### Firestore Rules
```bash
firebase deploy --only firestore:rules
```

### Cloud Functions
```bash
cd functions
npm install
firebase deploy --only functions
```

## Post-Deployment Setup

### 1. Create Super Admin Account
Manually add to Firestore:
```
Collection: users
Document ID: admin_1
Fields:
  - email: "admin@yourhospital.com"
  - displayName: "Super Admin"
  - role: "admin"
  - createdAt: <current timestamp>
```

### 2. Enable Firebase Authentication
- Email/Password provider
- (Optional) Google Sign-In

### 3. Test Deployment
1. **Web**: Visit your Firebase Hosting URL
2. **Mobile**: Install APK on test device
3. **Login as admin** → Create hospitals & doctors
4. **Login as patient** → Test full flow

## Environment-Specific Configs

### Production
- Update `applicationId` in `android/app/build.gradle.kts`
- Configure proper signing keys
- Update Firebase project ID

### Staging
- Use separate Firebase project
- Different `google-services.json`
- Test with staging data

## Monitoring

### Firebase Console
- Authentication: Monitor user signups
- Firestore: Check database usage
- Hosting: View traffic stats
- Functions: Monitor executions

### Crashlytics (Optional)
```bash
flutter pub add firebase_crashlytics
firebase crashlytics:symbols:upload --app=<APP_ID>
```

## Maintenance

### Update Dependencies
```bash
flutter pub upgrade
```

### Database Backup
```bash
gcloud firestore export gs://[BUCKET_NAME]
```

### Performance Monitoring
```bash
flutter pub add firebase_performance
```

## Troubleshooting

### Build Fails
- Run `flutter clean`
- Delete `build/` folder
- Run `flutter pub get`

### Firebase Connection Issues
- Verify `google-services.json` is correct
- Check Firebase project settings
- Ensure SHA-1 fingerprint is added (Android)

### Web Build Issues
- Clear browser cache
- Check CORS settings
- Verify Firebase config in `firebase_options.dart`

## Support
For issues, check:
- Flutter docs: https://flutter.dev
- Firebase docs: https://firebase.google.com/docs
- GitHub Issues: [Your repo URL]
