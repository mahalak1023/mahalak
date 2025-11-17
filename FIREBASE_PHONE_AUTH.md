# Firebase Phone Authentication Setup Guide

## ✅ What's Configured

### 1. **Package Installed**
- `firebase_auth: ^4.6.0` ✅

### 2. **Egyptian Phone Number Support**
- Format: `01xxxxxxxxx` (10-11 digits)
- Validation: Must start with `01`
- Converts to E.164 format: `+20xxxxxxxxx`

### 3. **Auth Flow Implemented**

#### **AuthEntryPage** (`lib/features/auth/presentation/pages/auth_entry_page.dart`)
- ✅ Egyptian phone number validation
- ✅ Firebase phone authentication
- ✅ Auto-format to +20 country code
- ✅ OTP code sent via SMS
- ✅ Error handling for invalid numbers
- ✅ Rate limiting protection

#### **OtpPage** (`lib/features/auth/presentation/pages/otp_page.dart`)
- ✅ 6-digit OTP verification
- ✅ Firebase credential verification
- ✅ Auto-sign in on success
- ✅ Resend OTP functionality
- ✅ Error handling (invalid code, expired session)
- ✅ 60-second resend timer

## 🔧 Firebase Console Setup Required

### Step 1: Enable Phone Authentication
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `rami-fcdeb`
3. Navigate to **Authentication** → **Sign-in method**
4. Click **Phone** provider
5. Click **Enable**
6. Save changes

### Step 2: Configure Test Phone Numbers (Optional - for development)
To test without sending real SMS:

1. In Firebase Console → **Authentication** → **Sign-in method**
2. Scroll to **Phone numbers for testing**
3. Add test numbers:
   ```
   Phone: +201234567890
   Code: 123456
   ```

### Step 3: Configure App Verification (Important for Production)

#### For Web:
1. Go to **Authentication** → **Settings** → **Authorized domains**
2. Add your domains:
   - `localhost` (already added for development)
   - Your production domain

#### For Android:
1. Register app SHA-1 fingerprint in Firebase project settings
2. Download updated `google-services.json`
3. Place in `android/app/`

#### For iOS:
1. Enable push notifications in Xcode
2. Configure APNs authentication key in Firebase

### Step 4: Set Daily SMS Quota
Firebase free tier includes:
- **10 SMS/day for testing**
- **5,000 verifications/month**

For production, enable Blaze plan for more quota.

## 📱 How It Works

### User Flow:
1. **User enters Egyptian phone**: `01012345678`
2. **App formats to E.164**: `+201012345678`
3. **Firebase sends OTP via SMS**: User receives 6-digit code
4. **User enters OTP**: `123456`
5. **Firebase verifies code**: Creates authenticated user
6. **App navigates to home**: User is signed in

### Code Flow:

```dart
// 1. Send OTP
await FirebaseAuth.instance.verifyPhoneNumber(
  phoneNumber: '+201012345678',
  codeSent: (verificationId, resendToken) {
    // Navigate to OTP page with verificationId
  },
);

// 2. Verify OTP
PhoneAuthCredential credential = PhoneAuthProvider.credential(
  verificationId: verificationId,
  smsCode: '123456',
);

await FirebaseAuth.instance.signInWithCredential(credential);
// User is now signed in!
```

## 🎯 Testing

### Test with Real Egyptian Number:
```powershell
flutter run -d chrome
```

1. Enter Egyptian phone: `01012345678`
2. Click "متابعة"
3. Check your phone for SMS with OTP code
4. Enter 6-digit code
5. Auto-navigate to home on success

### Test with Firebase Test Number:
1. Add test number in Firebase Console: `+201234567890` → Code: `123456`
2. Run app and enter: `01234567890`
3. Enter test code: `123456`
4. Verify without sending real SMS

## ⚠️ Common Issues & Solutions

### Issue 1: SMS Not Received
**Solutions:**
- Verify phone number format is correct (`01xxxxxxxxx`)
- Check Firebase Console that Phone Auth is enabled
- Verify you haven't exceeded daily SMS quota
- Check phone has good signal
- Wait 1-2 minutes (SMS can be delayed)

### Issue 2: "Invalid Phone Number"
**Solutions:**
- Phone must start with `01`
- Phone must be 10-11 digits
- App automatically adds `+20` prefix
- Example: `01012345678` → `+201012345678`

### Issue 3: "Too Many Requests"
**Solutions:**
- Firebase has rate limiting (10 SMS/day on free tier)
- Wait a few hours or use test phone numbers
- Upgrade to Blaze plan for production

### Issue 4: "Invalid Verification Code"
**Solutions:**
- Ensure code is exactly 6 digits
- Code expires after 60 seconds
- Use "Resend Code" button to get new code
- Check for typos in entered code

### Issue 5: Web reCAPTCHA Issues
**Solutions:**
- Add this to `web/index.html` before `</body>`:
```html
<div id="recaptcha-container"></div>
```
- Ensure domain is authorized in Firebase Console
- Test in incognito mode to clear cache

## 🔐 Security Best Practices

1. **Rate Limiting**: Implemented automatically by Firebase
2. **App Verification**: 
   - Web: reCAPTCHA (automatic)
   - Android: SafetyNet (requires SHA-1)
   - iOS: Silent APNs notification
3. **Test Numbers**: Only use in development, remove in production
4. **Quota Monitoring**: Check Firebase Console for usage stats
5. **Error Handling**: All errors are caught and displayed to user

## 📊 Firebase Console Monitoring

### View Authentication Logs:
1. Firebase Console → **Authentication** → **Users**
2. See all authenticated phone numbers
3. Track sign-in activity

### Monitor Usage:
1. Firebase Console → **Authentication** → **Usage**
2. See verification attempts
3. Track SMS quota consumption

## 🚀 Next Steps

### Optional Enhancements:
1. **Store user data**: After auth, save to Firestore
   ```dart
   User? user = FirebaseAuth.instance.currentUser;
   await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
     'phone': user.phoneNumber,
     'createdAt': FieldValue.serverTimestamp(),
   });
   ```

2. **Check auth state**: Persist login
   ```dart
   FirebaseAuth.instance.authStateChanges().listen((User? user) {
     if (user != null) {
       // User is signed in
       Navigator.pushReplacementNamed(context, '/home');
     } else {
       // User is signed out
       Navigator.pushReplacementNamed(context, '/');
     }
   });
   ```

3. **Add profile page**: Display user info
4. **Sign out functionality**: 
   ```dart
   await FirebaseAuth.instance.signOut();
   ```

## 📖 Egyptian Phone Number Format

### Valid Formats:
- `01012345678` (11 digits) ✅
- `0101234567` (10 digits) ✅
- Starting with `01` ✅

### Invalid Formats:
- `1012345678` (no leading 0) ❌
- `0201234567` (starts with 02) ❌
- `010123456` (too short) ❌
- `010123456789` (too long) ❌

### Network Codes (Egypt):
- `010` - Vodafone
- `011` - Etisalat
- `012` - Orange
- `015` - WE (We)

## 🎨 UI Features

- ✅ RTL Arabic interface
- ✅ Animated transitions
- ✅ Loading states
- ✅ Error messages in Arabic
- ✅ Responsive design (mobile + desktop)
- ✅ Input validation with visual feedback
- ✅ Resend timer with countdown
- ✅ Auto-focus on OTP input

## 🔄 Authentication State

After successful OTP verification:
```dart
User? user = FirebaseAuth.instance.currentUser;
String? phoneNumber = user?.phoneNumber; // "+201012345678"
String? uid = user?.uid; // Unique user ID
```

Use `uid` to store/retrieve user data in Firestore!
