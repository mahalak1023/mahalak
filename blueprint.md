# Project Blueprint

## Overview

This document outlines the architecture, features, and design of the Mahallak e-commerce Flutter application. The goal is to create a modern, responsive, and intuitive mobile shopping experience.

## Implemented Features & Design

### Core Setup
- **Framework:** Flutter
- **Styling:** `flutter_screenutil` for responsive design.
- **Theme:** A centralized `AppTheme` is defined in `core/theme/app_theme.dart`.
- **Routing:** A declarative routing system is set up in `lib/main.dart` with named routes for all pages.
- **Firebase:** The project is linked to the Firebase project "rami-fcdeb" and initialized in `lib/main.dart`.
- **Authentication:** Firebase Auth is set up for email/password authentication, including forgot password and session management.
- **Database:** Cloud Firestore is set up to store and manage the application's data. A `FirestoreService` is implemented to handle all database interactions.

### Feature Pages
- **Authentication:**
    - `AuthEntryPage`: A screen for users to sign up or log in using their email and password. Includes a "Forgot Password?" link.
    - `ForgotPasswordPage`: A screen for users to request a password reset email.
    - `OtpPage`: (Currently unused) For phone number verification.
- **Home & Navigation:**
    - `HomePage`: The main landing page of the app. Displays stores and products from Firestore. Includes a logout button.
    - `StoreListPage`: To browse different stores.
    - `ProductListPage`: To view products within a store or category.
- **Product:**
    - `ProductDetailsPage`: Shows detailed information about a single product.
- **Shopping Cart:**
    - `CartPage`: Displays items added to the cart. Includes an empty state and a button to proceed to checkout.
- **Address Management:**
    - `AddressPickerPage`: Allows users to select a shipping address.
    - `AddAddressPage`: A form to add a new address.
- **Checkout:**
    - `CheckoutPage`: The final step to review and place an order.
    - `OrderStatusPage`: To track the status of a placed order.
- **Order History:**
    - `OrdersHistoryPage`: Lists all past orders.
    - `OrderDetailsPage`: Shows details for a specific past order.
- **Support:**
    - `HelpCenterPage`: Provides help and support options to the user.

## Current Plan

This section outlines the steps for the current development task.

### Task: Integrate Firestore

- **[x]** Add the `cloud_firestore` dependency to the project.
- **[x]** Create data models for products and stores.
- **[x]** Implement a `FirestoreService` to handle all database interactions.
- **[x]** Replace the mock data in `HomePage` with real data from Firestore.
- **[x]** Add a function to populate Firestore with sample data if it's empty.
- **[x]** Update the `blueprint.md` to reflect the changes.

