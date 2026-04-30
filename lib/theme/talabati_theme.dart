import 'package:flutter/material.dart';

// ─────────────────────────────────────────
//  Talabati CRM — Design System
// ─────────────────────────────────────────

class TalabatiColors {
  TalabatiColors._();

  // Primary
  static const Color primary = Color(0xFF3D5BF3);
  static const Color primaryLight = Color(0xFFEEF1FE);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF4F6F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A2744); // Revenue card only

  // Text
  static const Color textPrimary = Color(0xFF0D1117);
  static const Color textSecondary = Color(0xFF6B7280);

  // Status / Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color teal = Color(0xFF14B8A6);
  static const Color tealLight = Color(0xFFCCFBF1);

  // Neutral badge (New / Inactive)
  static const Color badgeNeutralBg = Color(0xFFE5E7EB);
  static const Color badgeNeutralText = Color(0xFF374151);

  // Divider / Border
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFE5E7EB);
}

// ─────────────────────────────────────────
//  Order Status Badge Helpers
// ─────────────────────────────────────────

enum OrderStatus {
  newOrder,
  called,
  confirmed,
  handedToCourier,
  delivered,
  collected,
  returned,
  cancelled,
}

extension OrderStatusStyle on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.newOrder: return 'New';
      case OrderStatus.called: return 'Called';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.handedToCourier: return 'Handed to Courier';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.collected: return 'Collected';
      case OrderStatus.returned: return 'Returned';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case OrderStatus.newOrder: return TalabatiColors.badgeNeutralBg;
      case OrderStatus.called: return TalabatiColors.warningLight;
      case OrderStatus.confirmed: return const Color(0xFFFED7AA); // amber-200
      case OrderStatus.handedToCourier: return TalabatiColors.infoLight;
      case OrderStatus.delivered: return TalabatiColors.tealLight;
      case OrderStatus.collected: return TalabatiColors.successLight;
      case OrderStatus.returned: return TalabatiColors.dangerLight;
      case OrderStatus.cancelled: return TalabatiColors.badgeNeutralBg;
    }
  }

  Color get textColor {
    switch (this) {
      case OrderStatus.newOrder: return TalabatiColors.badgeNeutralText;
      case OrderStatus.called: return TalabatiColors.warning;
      case OrderStatus.confirmed: return const Color(0xFFD97706); // amber-600
      case OrderStatus.handedToCourier: return TalabatiColors.info;
      case OrderStatus.delivered: return TalabatiColors.teal;
      case OrderStatus.collected: return TalabatiColors.success;
      case OrderStatus.returned: return TalabatiColors.danger;
      case OrderStatus.cancelled: return TalabatiColors.badgeNeutralText;
    }
  }
}

// ─────────────────────────────────────────
//  Client Status Badge Helpers
// ─────────────────────────────────────────

enum ClientStatus { vip, active, pending, inactive }

extension ClientStatusStyle on ClientStatus {
  String get label {
    switch (this) {
      case ClientStatus.vip: return 'VIP';
      case ClientStatus.active: return 'Active';
      case ClientStatus.pending: return 'Pending';
      case ClientStatus.inactive: return 'Inactive';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case ClientStatus.vip: return TalabatiColors.textPrimary;
      case ClientStatus.active: return TalabatiColors.successLight;
      case ClientStatus.pending: return TalabatiColors.warningLight;
      case ClientStatus.inactive: return TalabatiColors.badgeNeutralBg;
    }
  }

  Color get textColor {
    switch (this) {
      case ClientStatus.vip: return TalabatiColors.surface;
      case ClientStatus.active: return TalabatiColors.success;
      case ClientStatus.pending: return TalabatiColors.warning;
      case ClientStatus.inactive: return TalabatiColors.textSecondary;
    }
  }
}

// ─────────────────────────────────────────
//  Stock Status Badge Helpers
// ─────────────────────────────────────────

enum StockStatus { inStock, lowStock, outOfStock }

extension StockStatusStyle on StockStatus {
  String get label {
    switch (this) {
      case StockStatus.inStock: return 'In Stock';
      case StockStatus.lowStock: return 'Low Stock';
      case StockStatus.outOfStock: return 'Out of Stock';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case StockStatus.inStock: return TalabatiColors.successLight;
      case StockStatus.lowStock: return TalabatiColors.dangerLight;
      case StockStatus.outOfStock: return TalabatiColors.badgeNeutralBg;
    }
  }

  Color get textColor {
    switch (this) {
      case StockStatus.inStock: return TalabatiColors.success;
      case StockStatus.lowStock: return TalabatiColors.danger;
      case StockStatus.outOfStock: return TalabatiColors.textSecondary;
    }
  }

  IconData get icon {
    switch (this) {
      case StockStatus.inStock: return Icons.check_circle_outline_rounded;
      case StockStatus.lowStock: return Icons.warning_amber_rounded;
      case StockStatus.outOfStock: return Icons.remove_circle_outline_rounded;
    }
  }
}

// ─────────────────────────────────────────
//  Main Theme
// ─────────────────────────────────────────

class TalabatiTheme {
  TalabatiTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: TalabatiColors.primary,
        brightness: Brightness.light,
        primary: TalabatiColors.primary,
        onPrimary: Colors.white,
        secondary: TalabatiColors.primary,
        onSecondary: Colors.white,
        surface: TalabatiColors.surface,
        onSurface: TalabatiColors.textPrimary,
        error: TalabatiColors.danger,
      ),
      scaffoldBackgroundColor: TalabatiColors.background,

      // ── AppBar ──
      appBarTheme: const AppBarTheme(
        backgroundColor: TalabatiColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: TalabatiColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: TalabatiColors.textPrimary),
      ),

      // ── Bottom Navigation ──
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: TalabatiColors.surface,
        selectedItemColor: TalabatiColors.primary,
        unselectedItemColor: TalabatiColors.textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ── Cards ──
      cardTheme: CardThemeData(
        color: TalabatiColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Input / Search ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TalabatiColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TalabatiColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TalabatiColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TalabatiColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(
          color: TalabatiColors.textSecondary,
          fontSize: 14,
        ),
        prefixIconColor: TalabatiColors.textSecondary,
      ),

      // ── FAB ──
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: TalabatiColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ── Chips (filter pills) ──
      chipTheme: ChipThemeData(
        backgroundColor: TalabatiColors.surface,
        selectedColor: TalabatiColors.primary,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: TalabatiColors.textPrimary,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        side: const BorderSide(color: TalabatiColors.border),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Divider ──
      dividerTheme: const DividerThemeData(
        color: TalabatiColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ── Typography ──
      textTheme: const TextTheme(
        // Screen headings
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: TalabatiColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: TalabatiColors.textPrimary,
          letterSpacing: -0.3,
        ),
        // Card titles
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: TalabatiColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: TalabatiColors.textPrimary,
        ),
        // Body
        bodyLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: TalabatiColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: TalabatiColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: TalabatiColors.textSecondary,
          letterSpacing: 0.2,
        ),
        // Amounts / prices
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: TalabatiColors.primary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Spacing Constants
// ─────────────────────────────────────────

class TalabatiSpacing {
  TalabatiSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;

  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets cardPaddingH =
      EdgeInsets.symmetric(horizontal: 16, vertical: 12);
}

// ─────────────────────────────────────────
//  Radius Constants
// ─────────────────────────────────────────

class TalabatiRadius {
  TalabatiRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 999;

  static const BorderRadius cardRadius =
      BorderRadius.all(Radius.circular(lg));
  static const BorderRadius buttonRadius =
      BorderRadius.all(Radius.circular(md));
  static const BorderRadius badgeRadius =
      BorderRadius.all(Radius.circular(full));
}
