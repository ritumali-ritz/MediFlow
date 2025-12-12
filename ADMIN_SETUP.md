// Quick script to create super admin account
// Run this in Firebase Console > Firestore > Run query

// 1. Go to Firebase Console: https://console.firebase.google.com
// 2. Select your project: smart-health-queue
// 3. Go to Firestore Database
// 4. Click "Start collection"
// 5. Collection ID: users
// 6. Document ID: admin_1
// 7. Add these fields:

{
  "email": "admin@hospital.com",
  "displayName": "Super Admin",
  "role": "admin",
  "createdAt": new Date()
}

// Then login with:
// Email: admin@hospital.com
// Password: (You'll need to create this in Firebase Authentication first)

// OR use the app to register as patient first, then manually change the role to "admin" in Firestore
