
# Mahalak App Blueprint

## Overview

"محلك" is a B2C marketplace application for Flutter (mobile and web) with a focus on an Arabic, RTL-first user experience. The application will facilitate a complete shopping workflow, from user authentication to order fulfillment and support.

## Implemented Features

This document outlines the initial setup of the application, including the core page structure and basic navigation.

### Style and Design
- **Language:** Arabic (RTL)
- **Initial UI:** Basic placeholders with Arabic titles.

### Features
- **Core Pages:**
  - Authentication (Auth Entry, OTP, Forgot Password)
  - Home (Home, Store List, Product List)
  - Product (Product Details)
  - Cart (Cart)
  - Address (Address Picker, Add Address)
  - Checkout (Checkout, Order Status)
  - Orders (Orders History, Order Details)
  - Support (Help Center)
- **Navigation:**
  - Named routes are set up for all core pages.
  - Basic navigation buttons are implemented to demonstrate connectivity between pages.

## Current Plan

The current development stage focuses on building the foundational UI skeleton and navigation of the "محلك" application.

### Steps
1.  **Create Folder and File Structure:** Establish the directory structure for all features and their corresponding pages.
2.  **Implement Basic UI Skeletons:** Create basic `StatelessWidget` or `StatefulWidget` for each page with a `Scaffold`, `AppBar`, and placeholder content.
3.  **Set Up Basic Navigation:** Configure named routes in `main.dart` and add `ElevatedButton`s for navigating between pages.
