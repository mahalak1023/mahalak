import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios, {isAxiosError, AxiosError} from "axios";
import {
  KashierConfig,
  PaymentRequest,
  KashierApiResponse,
  validatePaymentRequest,
  validateKashierConfig,
  generateKashierSignature,
  formatAmount,
} from "./kashier-utils";

// Initialize Firebase Admin
admin.initializeApp();

/**
 * Kashier API endpoints
 */
const KASHIER_API_URLS = {
  test: "https://test-api.kashier.io/payment/link",
  production: "https://api.kashier.io/payment/link",
};

/**
 * Get Kashier configuration from environment variables
 */
function getKashierConfig(): KashierConfig {
  const config: KashierConfig = {
    merchantId: process.env.KASHIER_MERCHANT_ID || "",
    apiKey: process.env.KASHIER_API_KEY || "",
    secretKey: process.env.KASHIER_SECRET_KEY || "",
    currency: process.env.KASHIER_CURRENCY || "EGP",
    testMode: process.env.KASHIER_TEST_MODE !== "false", // Default to test mode
  };

  validateKashierConfig(config);
  return config;
}

/**
 * Create Kashier Payment - HTTPS Cloud Function
 *
 * This function creates a payment link using Kashier's Hosted Payment Page (HPP).
 * It accepts payment details from the Flutter app and returns a payment URL.
 *
 * Request body:
 * {
 *   "amount": number | string,
 *   "orderId": string,
 *   "customerEmail"?: string,
 *   "customerName"?: string,
 *   "customerPhone"?: string,
 *   "description"?: string
 * }
 *
 * Response (success):
 * {
 *   "success": true,
 *   "paymentUrl": string,
 *   "orderId": string,
 *   "transactionId"?: string
 * }
 *
 * Response (error):
 * {
 *   "error": string,
 *   "details": string
 * }
 */
export const createKashierPayment = functions.https.onRequest(async (req, res) => {
  // Set CORS headers to allow requests from Flutter app
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  // Handle preflight request
  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }

  // Only allow POST requests
  if (req.method !== "POST") {
    res.status(405).json({
      error: "Method not allowed",
      details: "Only POST requests are accepted",
    });
    return;
  }

  try {
    // Get payment request from body
    const paymentRequest: PaymentRequest = req.body;

    // Validate request
    validatePaymentRequest(paymentRequest);

    // Get Kashier configuration
    const config = getKashierConfig();

    // Format amount
    const formattedAmount = formatAmount(paymentRequest.amount);

    // Generate signature/hash
    const hash = generateKashierSignature(
      config.merchantId,
      paymentRequest.orderId,
      formattedAmount,
      config.currency,
      config.secretKey
    );

    // Build Kashier API payload
    const kashierPayload: Record<string, string> = {
      merchantId: config.merchantId,
      amount: formattedAmount,
      currency: config.currency,
      orderId: paymentRequest.orderId,
      hash: hash,
      mode: "live", // Change to 'test' if needed
    };

    // Add optional fields
    if (paymentRequest.customerEmail) {
      kashierPayload.shopper_email = paymentRequest.customerEmail;
    }

    if (paymentRequest.customerName) {
      kashierPayload.shopper_name = paymentRequest.customerName;
    }

    if (paymentRequest.customerPhone) {
      kashierPayload.shopper_phone = paymentRequest.customerPhone;
    }

    if (paymentRequest.description) {
      kashierPayload.description = paymentRequest.description;
    }

    // Select API endpoint based on mode
    const apiUrl = config.testMode ? KASHIER_API_URLS.test : KASHIER_API_URLS.production;

    functions.logger.info("Creating Kashier payment", {
      orderId: paymentRequest.orderId,
      amount: formattedAmount,
      currency: config.currency,
      testMode: config.testMode,
    });

    // Call Kashier API
    const response = await axios.post<KashierApiResponse>(
      apiUrl,
      kashierPayload,
      {
        headers: {
          "Content-Type": "application/json",
          "Authorization": config.apiKey,
        },
        timeout: 30000, // 30 seconds timeout
      }
    );

    // Check response status
    if (response.data.status === "success" || response.data.status === "SUCCESS") {
      const paymentUrl = response.data.response.paymentUrl;
      const transactionId = response.data.response.transactionId;

      if (!paymentUrl) {
        throw new Error("Payment URL not received from Kashier");
      }

      functions.logger.info("Kashier payment created successfully", {
        orderId: paymentRequest.orderId,
        transactionId: transactionId,
      });

      // Return success response
      res.status(200).json({
        success: true,
        paymentUrl: paymentUrl,
        orderId: paymentRequest.orderId,
        transactionId: transactionId,
      });
    } else {
      // Kashier returned an error
      const errorMessage = response.data.messages?.message || response.data.response.message || "Unknown error";

      functions.logger.error("Kashier API error", {
        orderId: paymentRequest.orderId,
        status: response.data.status,
        message: errorMessage,
      });

      res.status(400).json({
        error: "Failed to create Kashier payment",
        details: errorMessage,
      });
    }
  } catch (error) {
    // Handle errors
    functions.logger.error("Error creating Kashier payment", {error});

    if (isAxiosError(error)) {
      const axiosError = error as AxiosError;

      if (axiosError.response) {
        // Kashier API returned an error response
        functions.logger.error("Kashier API error response", {
          status: axiosError.response.status,
          data: axiosError.response.data,
        });

        res.status(500).json({
          error: "Failed to create Kashier payment",
          details: "Kashier API error. Please try again later.",
        });
      } else if (axiosError.request) {
        // Request was made but no response received
        functions.logger.error("No response from Kashier API", {
          message: axiosError.message,
        });

        res.status(500).json({
          error: "Failed to create Kashier payment",
          details: "Unable to reach Kashier payment gateway. Please try again.",
        });
      } else {
        // Error setting up the request
        res.status(500).json({
          error: "Failed to create Kashier payment",
          details: "Request configuration error.",
        });
      }
    } else if (error instanceof Error) {
      // Validation or other errors
      res.status(400).json({
        error: "Failed to create Kashier payment",
        details: error.message,
      });
    } else {
      // Unknown error
      res.status(500).json({
        error: "Failed to create Kashier payment",
        details: "An unexpected error occurred.",
      });
    }
  }
});
