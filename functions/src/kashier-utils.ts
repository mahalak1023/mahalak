import * as crypto from "crypto";

/**
 * Kashier API configuration interface
 */
export interface KashierConfig {
  merchantId: string;
  apiKey: string;
  secretKey: string;
  currency: string;
  testMode?: boolean;
}

/**
 * Payment request from Flutter client
 */
export interface PaymentRequest {
  amount: number | string;
  orderId: string;
  customerEmail?: string;
  customerName?: string;
  customerPhone?: string;
  description?: string;
}

/**
 * Kashier API payment payload
 */
export interface KashierPaymentPayload {
  merchantId: string;
  amount: string;
  currency: string;
  orderId: string;
  merchantRedirect?: string;
  webhookUrl?: string;
  hash: string;
  displayCurrencyIso?: string;
  failureRedirect?: string;
  allowedMethods?: string;
  customFields?: Record<string, string>;
}

/**
 * Kashier API response
 */
export interface KashierApiResponse {
  status: string;
  response: {
    transactionId?: string;
    paymentUrl?: string;
    orderId: string;
    message?: string;
  };
  messages?: {
    message?: string;
    code?: string;
  };
}

/**
 * Generate HMAC SHA-256 signature for Kashier API
 * According to Kashier docs, the signature is generated from:
 * merchantId + orderId + amount + currency + secretKey
 *
 * @param merchantId - Kashier merchant ID
 * @param orderId - Order ID
 * @param amount - Payment amount
 * @param currency - Currency code (e.g., "EGP")
 * @param secretKey - Kashier secret key
 * @returns HMAC SHA-256 hash
 */
export function generateKashierSignature(
  merchantId: string,
  orderId: string,
  amount: string,
  currency: string,
  secretKey: string
): string {
  // Concatenate fields as per Kashier's specification
  const dataString = `${merchantId}${orderId}${amount}${currency}${secretKey}`;

  // Generate HMAC SHA-256 hash
  const hash = crypto
    .createHmac("sha256", secretKey)
    .update(dataString)
    .digest("hex");

  return hash;
}

/**
 * Validate payment request from client
 *
 * @param request - Payment request object
 * @throws Error if validation fails
 */
export function validatePaymentRequest(request: PaymentRequest): void {
  if (!request) {
    throw new Error("Payment request is required");
  }

  // Normalize and validate amount (accepts string or number)
  const amountNum = typeof request.amount === "string" ? parseFloat(request.amount) : request.amount;
  if (typeof amountNum !== "number" || isNaN(amountNum) || amountNum <= 0) {
    throw new Error("Amount must be a positive number");
  }

  if (!request.orderId || typeof request.orderId !== "string" || request.orderId.trim() === "") {
    throw new Error("Valid orderId is required");
  }

  // Validate email format if provided
  if (request.customerEmail) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(request.customerEmail)) {
      throw new Error("Invalid email format");
    }
  }
}

/**
 * Validate Kashier configuration
 *
 * @param config - Kashier configuration object
 * @throws Error if validation fails
 */
export function validateKashierConfig(config: KashierConfig): void {
  if (!config.merchantId) {
    throw new Error("KASHIER_MERCHANT_ID environment variable is not set");
  }

  if (!config.apiKey) {
    throw new Error("KASHIER_API_KEY environment variable is not set");
  }

  if (!config.secretKey) {
    throw new Error("KASHIER_SECRET_KEY environment variable is not set");
  }

  if (!config.currency) {
    throw new Error("KASHIER_CURRENCY environment variable is not set");
  }
}

/**
 * Format amount to ensure it's a valid decimal string
 *
 * @param amount - Amount as number or string
 * @returns Formatted amount string
 */
export function formatAmount(amount: number | string): string {
  const numAmount = typeof amount === "string" ? parseFloat(amount) : amount;

  if (isNaN(numAmount)) {
    throw new Error("Invalid amount format");
  }

  return numAmount.toFixed(2);
}
