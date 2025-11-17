/**
 * Type definitions for Kashier Payment Integration
 */

declare global {
  namespace NodeJS {
    interface ProcessEnv {
      KASHIER_MERCHANT_ID: string;
      KASHIER_API_KEY: string;
      KASHIER_SECRET_KEY: string;
      KASHIER_CURRENCY: string;
      KASHIER_TEST_MODE?: string;
    }
  }
}

export {};
