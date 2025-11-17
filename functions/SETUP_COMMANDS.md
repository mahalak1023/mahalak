# Quick Setup Commands for Kashier Cloud Function

## 1. Install Dependencies
cd functions
npm install

## 2. Set Environment Variables (Secrets)

### Production (use real values from Kashier dashboard)
firebase functions:secrets:set KASHIER_MERCHANT_ID
# Enter your merchant ID when prompted

firebase functions:secrets:set KASHIER_API_KEY
# Enter your API key when prompted

firebase functions:secrets:set KASHIER_SECRET_KEY
# Enter your secret key when prompted

firebase functions:secrets:set KASHIER_CURRENCY
# Enter: EGP (or your preferred currency)

firebase functions:secrets:set KASHIER_TEST_MODE
# Enter: true (for testing) or false (for production)

## 3. Build and Deploy
npm run build
firebase deploy --only functions

## 4. Get Your Function URL
After deployment, your function will be available at:
https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/createKashierPayment

## 5. Test the Function (using curl or Postman)

curl -X POST https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/createKashierPayment \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 100.00,
    "orderId": "TEST-ORDER-123",
    "customerEmail": "test@example.com",
    "customerName": "Test User"
  }'

## 6. View Logs
firebase functions:log

## Alternative: Local Testing
npm run serve
# Function will run at: http://localhost:5001/YOUR_PROJECT_ID/us-central1/createKashierPayment

---

## Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| KASHIER_MERCHANT_ID | Your Kashier merchant ID | `MID-12345-67` |
| KASHIER_API_KEY | Your Kashier API key | `api_key_xxxxxxxxxx` |
| KASHIER_SECRET_KEY | Your Kashier secret key (for signatures) | `secret_xxxxxxxxxx` |
| KASHIER_CURRENCY | Default currency code | `EGP`, `USD`, `SAR` |
| KASHIER_TEST_MODE | Use test environment | `true` or `false` |

---

## Important Notes

⚠️ **NEVER** commit your actual secret keys to Git!
✅ Use Firebase secrets for production
✅ Use .env file (already in .gitignore) for local testing only
✅ Verify all credentials in Kashier dashboard before deploying
