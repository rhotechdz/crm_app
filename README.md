# Talabati CRM

**Talabati CRM** is a local-first mobile CRM designed for Algerian e-commerce sellers. It helps manage clients, products, and orders without requiring internet access, authentication, or a backend.

## Tech stack
- **Flutter** (Android & iOS)
- **Riverpod** (state management)
- **sqflite** (local database)
- **image_picker** + **path_provider** (local image storage)
- **url_launcher** (phone, WhatsApp, and Instagram links)
- **flutter_svg** (custom SVG icons)

## Current status
All four main screens are fully working:

- **Dashboard**: Live stats from SQLite, including today's orders, pending confirmation, courier status, monthly revenue/profit, returns, top returning clients, and recent orders.
- **Orders**: Add, edit, delete, search, filter, product picker, status pipeline, delivery tracking, collection amounts, returns, cancellation, phone calls, and WhatsApp shortcuts.
- **Clients**: Add, edit, delete, search, duplicate phone detection, frequent returner flagging, wilaya selection, order history, phone calls, WhatsApp shortcuts, and Instagram DM shortcuts.
- **Catalog**: Add, edit, delete, search, variants management, profit margin calculation, stock tracking, and local image support.
- **Navigation**: Bottom navigation with Dashboard, Orders, Clients, and Catalog tabs.
- **Offline-first**: Full offline operation, no login or internet required for core CRM data.

## Todo / Planned features
- **Confirmation tracking**: Log confirmation call attempts per order.
- **Exporting**: Export orders/clients to Excel or PDF.
- **Stock alerts**: Low stock notifications.
- **Advanced analytics**: Charts and deeper business insights.

## Future plans (post-MVP)
- **Cloud sync**: Supabase integration for multi-device support.
- **Web support**: Expanding to desktop browsers.
- **Multi-user**: Staff access roles and permissions.
- **Deeper Instagram integration**: Inbox/DM integration if Meta business access is approved.

## Project structure

```text
lib/
├── core
│   ├── constants         # App-wide constants, such as Algerian wilayas
│   └── database          # sqflite database initialization and helpers
└── features
    ├── catalog           # Product and variant management
    ├── clients           # Client profiles and history
    ├── dashboard         # Summary statistics and overview
    ├── home              # Main application shell and navigation
    └── orders            # Order processing and tracking
```

- **core**: Contains foundational code like database setup and constants used across multiple features.
- **features/catalog**: Handles the product database, variant logic, and product-specific UI.
- **features/clients**: Manages customer data, including unique phone identification and return history.
- **features/dashboard**: Provides the high-level business overview and statistical visualization.
- **features/home**: Orchestrates the main navigation and entry points of the application.
- **features/orders**: Manages the lifecycle of customer orders and delivery tracking.
