# Social Authentication Setup Guide

This guide explains how to set up Google and Apple sign-in for your Flutter app.

## Google Sign-In Setup

### 1. Firebase Console Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `rami-fcdeb`
3. Navigate to **Authentication** → **Sign-in method**
4. Click on **Google** provider
5. Enable the toggle
6. Add support email
7. Click **Save**

### 2. Get Web Client ID

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll down to **Your apps** section
3. Find your Web app (`1:809087761882:web:df10c3c2febb7ba792d4e3`)
4. Copy the **Web Client ID** (looks like: `809087761882-xxxxxx.apps.googleusercontent.com`)

### 3. Update Web Configuration

1. Open `web/index.html`
2. Find the line with `google-signin-client_id`
3. Replace `YOUR_WEB_CLIENT_ID` with your actual Web Client ID:
   ```html
   <meta name="google-signin-client_id" content="809087761882-YOUR_ACTUAL_ID.apps.googleusercontent.com">
   ```

### 4. Android Setup (Optional for Mobile)

1. In Firebase Console, download `google-services.json`
2. Place it in `android/app/`
3. Add SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
4. Add the SHA-1 to Firebase Console → Project Settings → Your apps → Android app

### 5. iOS Setup (Optional for Mobile)

1. Download `GoogleService-Info.plist` from Firebase Console
2. Add to `ios/Runner/`
3. Update `Info.plist` with URL scheme

## Apple Sign-In Setup

### 1. Firebase Console Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `rami-fcdeb`
3. Navigate to **Authentication** → **Sign-in method**
4. Click on **Apple** provider
5. Enable the toggle
6. Click **Save**

### 2. Apple Developer Account (Required)

Apple Sign-In requires:
- Active Apple Developer Account ($99/year)
- App ID with Sign in with Apple capability enabled
- Service ID configured

**Note:** Apple Sign-In on web requires additional configuration through Apple Developer Portal.

### For Web:
1. Go to [Apple Developer](https://developer.apple.com/account)
2. Create a **Services ID**
3. Enable **Sign in with Apple**
4. Add your domain and redirect URLs
5. Download the key file
6. Add configuration to Firebase

### For iOS:
1. Enable "Sign in with Apple" capability in Xcode
2. No additional configuration needed

### For Android:
Apple Sign-In on Android requires web-based flow (already implemented in the code).

## Testing

### Test Google Sign-In:
1. Run the app: `flutter run -d chrome`
2. Click "تسجيل الدخول بواسطة Google"
3. Select a Google account
4. You should be redirected to the home page

### Test Apple Sign-In:
1. Apple Sign-In works best on Safari (iOS/macOS)
2. Click "تسجيل الدخول بواسطة Apple"
3. Authenticate with your Apple ID
4. You should be redirected to the home page

## Troubleshooting

### Google Sign-In Issues:
- **"idpiframe_initialization_failed"**: Check that your Web Client ID is correct
- **"popup_closed_by_user"**: User canceled - this is normal behavior
- **Cross-origin errors**: Make sure you're testing on `localhost` or an authorized domain

### Apple Sign-In Issues:
- **"invalid_client"**: Service ID not configured correctly
- **Web only works on Safari**: This is expected; Apple Sign-In has best support on Safari
- **Requires HTTPS**: In production, Apple Sign-In requires HTTPS

## Current Status

✅ **Implemented:**
- Google Sign-In (Web & Mobile ready)
- Apple Sign-In (Web & Mobile ready)
- Phone OTP (Requires Firebase Blaze plan)
- Firebase & Supabase integration
- Firestore stores service
- Supabase image storage

⚠️ **Required:**
- Enable Google provider in Firebase Console
- Add Web Client ID to `web/index.html`
- (Optional) Enable Apple provider in Firebase Console
- (Optional) Configure Apple Developer account for production

## Code Structure

- **AuthService** (`lib/Services/auth_service.dart`): Handles all authentication methods
- **AuthEntryPage** (`lib/features/auth/presentation/pages/auth_entry_page.dart`): UI with phone/Google/Apple options
- **OtpPage**: Handles phone OTP verification

## Environment Variables

Your `.env` file already contains:
```
API_KEY=...
PROJECT_ID=rami-fcdeb
...
```

No additional environment variables needed for social auth - it uses Firebase config.
