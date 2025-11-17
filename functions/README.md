# Firebase Cloud Functions - Kashier Payment Integration

This Cloud Function integrates **Kashier** payment gateway for secure payment processing using their Hosted Payment Page (HPP).

## 📋 Overview

The `createKashierPayment` function creates a secure payment link that your Flutter app can use to redirect users to Kashier's payment page.

## 🚀 Setup Instructions

### 1. Install Dependencies

Navigate to the `functions` directory and install the required packages:

```bash
cd functions
npm install
```

### 2. Configure Environment Variables

You need to set the following environment variables (secrets) for the Cloud Function:

#### Using Firebase CLI (Recommended for Production)

```bash
# Set the Kashier Merchant ID
firebase functions:secrets:set KASHIER_MERCHANT_ID

# Set the Kashier API Key
firebase functions:secrets:set KASHIER_API_KEY

# Set the Kashier Secret Key (used for signature generation)
firebase functions:secrets:set KASHIER_SECRET_KEY

# Set the currency (e.g., EGP, USD, SAR)
firebase functions:secrets:set KASHIER_CURRENCY

# Optional: Set test mode (default is true)
firebase functions:secrets:set KASHIER_TEST_MODE
```

When prompted, enter your actual values from your Kashier merchant dashboard.

#### For Local Development/Testing

Create a `.env` file in the `functions` directory (this file is already in .gitignore):

```env
KASHIER_MERCHANT_ID=your_merchant_id_here
KASHIER_API_KEY=your_api_key_here
KASHIER_SECRET_KEY=your_secret_key_here
KASHIER_CURRENCY=EGP
KASHIER_TEST_MODE=true
```

**⚠️ Important:** Never commit the `.env` file or expose your secret keys!

### 3. Build the Functions

```bash
npm run build
```

### 4. Test Locally (Optional)

```bash
npm run serve
```

This will start the Firebase emulator. Your function will be available at:
```
http://localhost:5001/YOUR_PROJECT_ID/us-central1/createKashierPayment
```

### 5. Deploy to Firebase

```bash
npm run deploy
```

Or deploy only functions:
```bash
firebase deploy --only functions
```

After deployment, your function URL will be:
```
https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/createKashierPayment
```

## 📡 API Reference

### Endpoint

**POST** `/createKashierPayment`

### Request Body

```json
{
  "amount": 100.00,
  "orderId": "ORDER-12345",
  "customerEmail": "customer@example.com",
  "customerName": "John Doe",
  "customerPhone": "+201234567890",
  "description": "Payment for order #12345"
}
```

#### Required Fields:
- `amount` (number | string): Payment amount (must be positive)
- `orderId` (string): Unique order identifier

#### Optional Fields:
- `customerEmail` (string): Customer's email address
- `customerName` (string): Customer's full name
- `customerPhone` (string): Customer's phone number
- `description` (string): Payment description

### Success Response

**Status Code:** `200 OK`

```json
{
  "success": true,
  "paymentUrl": "https://kashier-payment-url.com/...",
  "orderId": "ORDER-12345",
  "transactionId": "KASHIER-TXN-67890"
}
```

### Error Response

**Status Code:** `400 Bad Request` or `500 Internal Server Error`

```json
{
  "error": "Failed to create Kashier payment",
  "details": "Amount must be a positive number"
}
```

## 🔐 Security Features

- ✅ **No hardcoded secrets** - All sensitive data stored in environment variables
- ✅ **HMAC SHA-256 signature** - Secure hash generation for API requests
- ✅ **Input validation** - Validates all incoming data before processing
- ✅ **CORS enabled** - Configured for Flutter app requests
- ✅ **Error handling** - Comprehensive error logging without exposing sensitive info
- ✅ **Timeout protection** - 30-second timeout on API calls

## 🧪 Testing with Flutter

Example Flutter code to call this function:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> createKashierPayment({
  required double amount,
  required String orderId,
  String? customerEmail,
  String? customerName,
}) async {
  final url = Uri.parse(
    'https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/createKashierPayment'
  );

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'amount': amount,
      'orderId': orderId,
      'customerEmail': customerEmail,
      'customerName': customerName,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to create payment: ${response.body}');
  }
}

// Usage:
final result = await createKashierPayment(
  amount: 100.00,
  orderId: 'ORDER-${DateTime.now().millisecondsSinceEpoch}',
  customerEmail: 'customer@example.com',
  customerName: 'John Doe',
);

// Open the payment URL in a webview or browser
final paymentUrl = result['paymentUrl'];
```

## 📝 Kashier Configuration

### Getting Your Credentials

1. Sign up at [Kashier](https://kashier.io/)
2. Complete merchant verification
3. Go to your merchant dashboard
4. Navigate to **Settings** > **API Keys**
5. Copy your:
   - Merchant ID
   - API Key
   - Secret Key

### Test vs Production Mode

- **Test Mode**: Use test credentials and the test API endpoint
- **Production Mode**: Set `KASHIER_TEST_MODE=false` and use production credentials

## 🔍 Monitoring & Logs

View function logs:

```bash
firebase functions:log
```

Or view in Firebase Console:
1. Go to Firebase Console
2. Navigate to **Functions**
3. Click on `createKashierPayment`
4. View **Logs** tab

## 📦 Dependencies

- `firebase-functions`: Firebase Cloud Functions SDK
- `firebase-admin`: Firebase Admin SDK
- `axios`: HTTP client for API requests
- `crypto` (built-in): For HMAC signature generation

## 🛠️ Troubleshooting

### Common Issues:

1. **"Environment variable not set" error**
   - Make sure all required secrets are configured
   - Run: `firebase functions:secrets:access KASHIER_MERCHANT_ID` to verify

2. **"Payment URL not received" error**
   - Check Kashier API credentials
   - Verify merchant account is active
   - Check function logs for detailed error

3. **CORS errors from Flutter**
   - CORS is already configured in the function
   - Ensure you're making POST requests with proper headers

4. **Invalid signature error**
   - Verify KASHIER_SECRET_KEY is correct
   - Check that amount, currency, and orderId match exactly

## 📚 Additional Resources

- [Kashier API Documentation](https://developers.kashier.io/)
- [Firebase Cloud Functions Docs](https://firebase.google.com/docs/functions)
- [Firebase Environment Configuration](https://firebase.google.com/docs/functions/config-env)

## 🤝 Support

For issues related to:
- **Kashier API**: Contact Kashier support or check their documentation
- **Firebase Functions**: Check Firebase documentation or console logs
- **This implementation**: Review the code in `functions/src/index.ts`
