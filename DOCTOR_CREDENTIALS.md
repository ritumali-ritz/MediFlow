// Demo Doctor Credentials for Testing
// Use these to login as a doctor

/**
 * DEMO DOCTOR ACCOUNT
 * 
 * Email: doctor@hospital.com
 * Password: doctor123
 * 
 * This account is pre-created for testing.
 * Use the admin portal to create more doctor accounts.
 */

// To create this doctor in Firebase:
// 1. Go to Firebase Console > Authentication
// 2. Add user:
//    - Email: doctor@hospital.com
//    - Password: doctor123
// 3. Copy the UID
// 4. Go to Firestore > users collection
// 5. Create document with that UID:
//    {
//      "email": "doctor@hospital.com",
//      "displayName": "Dr. Demo",
//      "role": "doctor",
//      "createdAt": <current timestamp>
//    }

// OR use the admin portal (admin.html) to create doctors automatically!
