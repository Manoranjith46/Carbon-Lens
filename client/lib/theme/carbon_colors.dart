import 'package:flutter/material.dart';

/// All color tokens for the CarbonLens Adaptive Colour System.
/// Derived from the "CarbonLens Adaptive Colour System" design document.
class CarbonColors {
  CarbonColors._();

  // ═══════════════════════════════════════════════════════
  // GREEN — Within Limit (safe / nearLimit)
  // ═══════════════════════════════════════════════════════
  // Light
  static const Color greenPrimary = Color(0xFF2E7D32);
  static const Color greenHover = Color(0xFF256628);
  static const Color greenPressed = Color(0xFF1B5E20);
  static const Color greenContainer = Color(0xFFE8F5E9);
  static const Color greenContainerText = Color(0xFF17451B);
  static const Color greenFocus = Color(0xFF66BB6A);
  static const Color onGreenLight = Color(0xFFFFFFFF);

  // Dark
  static const Color greenPrimaryDark = Color(0xFF66BB6A);
  static const Color greenHoverDark = Color(0xFF7BCB7F);
  static const Color greenPressedDark = Color(0xFF4CAF50);
  static const Color greenContainerDark = Color(0xFF173D1B);
  static const Color greenContainerTextDark = Color(0xFFB9EDBC);
  static const Color greenFocusDark = Color(0xFF81C784);
  static const Color onGreenDark = Color(0xFF0B1B0D);

  // ═══════════════════════════════════════════════════════
  // RED — Over Limit
  // ═══════════════════════════════════════════════════════
  // Light
  static const Color redPrimary = Color(0xFFC62828);
  static const Color redHover = Color(0xFFA61F1F);
  static const Color redPressed = Color(0xFF8E1818);
  static const Color redContainer = Color(0xFFFDECEC);
  static const Color redContainerText = Color(0xFF6E1313);
  static const Color redFocus = Color(0xFFEF5350);
  static const Color onRedLight = Color(0xFFFFFFFF);

  // Dark
  static const Color redPrimaryDark = Color(0xFFEF5350);
  static const Color redHoverDark = Color(0xFFF36A67);
  static const Color redPressedDark = Color(0xFFE53935);
  static const Color redContainerDark = Color(0xFF481516);
  static const Color redContainerTextDark = Color(0xFFFFC7C5);
  static const Color redFocusDark = Color(0xFFFF7B78);
  static const Color onRedDark = Color(0xFF250606);

  // ═══════════════════════════════════════════════════════
  // TEAL — Neutral (no baseline)
  // ═══════════════════════════════════════════════════════
  // Light
  static const Color tealPrimary = Color(0xFF0F766E);
  static const Color tealHover = Color(0xFF0B5F59);
  static const Color tealPressed = Color(0xFF084C48);
  static const Color tealContainer = Color(0xFFE4F4F2);
  static const Color tealContainerText = Color(0xFF0B4F4A);
  static const Color onTealLight = Color(0xFFFFFFFF);

  // Dark
  static const Color tealPrimaryDark = Color(0xFF5CC8BE);
  static const Color tealHoverDark = Color(0xFF73D6CD);
  static const Color tealPressedDark = Color(0xFF3DB2A8);
  static const Color tealContainerDark = Color(0xFF123D39);
  static const Color tealContainerTextDark = Color(0xFFB8F0EB);
  static const Color onTealDark = Color(0xFF06211F);

  // ═══════════════════════════════════════════════════════
  // AMBER — Warning (near limit)
  // ═══════════════════════════════════════════════════════
  // Light
  static const Color warningLight = Color(0xFFB26A00);
  static const Color warningHoverLight = Color(0xFF925700);
  static const Color warningContainerLight = Color(0xFFFFF4D6);
  static const Color warningTextLight = Color(0xFF5C3900);
  static const Color onWarningLight = Color(0xFFFFFFFF);

  // Dark
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color warningContainerDark = Color(0xFF493711);
  static const Color warningTextDark = Color(0xFFFFE7A0);
  static const Color onWarningDark = Color(0xFF271A00);

  // ═══════════════════════════════════════════════════════
  // INFORMATION — Semantic (stable across status)
  // ═══════════════════════════════════════════════════════
  static const Color infoPrimaryLight = Color(0xFF1B6CA8);
  static const Color infoContainerLight = Color(0xFFE7F2FA);
  static const Color infoTextLight = Color(0xFF124B74);

  static const Color infoPrimaryDark = Color(0xFF64B5F6);
  static const Color infoContainerDark = Color(0xFF14354D);
  static const Color infoTextDark = Color(0xFFC5E6FF);

  // ═══════════════════════════════════════════════════════
  // LIGHT MODE NEUTRAL PALETTE
  // ═══════════════════════════════════════════════════════
  static const Color backgroundLight = Color(0xFFF7FAF7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFF1F5F2);
  static const Color surfaceSubtleLight = Color(0xFFEAF0EC);

  static const Color textPrimaryLight = Color(0xFF152019);
  static const Color textSecondaryLight = Color(0xFF5C685F);
  static const Color textMutedLight = Color(0xFF768179);
  static const Color textDisabledLight = Color(0xFF929C95);

  static const Color borderLight = Color(0xFFD8E1DA);
  static const Color dividerLight = Color(0xFFE8EEEA);
  static const Color disabledBgLight = Color(0xFFE5EAE6);

  // ═══════════════════════════════════════════════════════
  // DARK MODE NEUTRAL PALETTE
  // ═══════════════════════════════════════════════════════
  static const Color backgroundDark = Color(0xFF0B120D);
  static const Color surfaceDark = Color(0xFF121B14);
  static const Color surfaceElevatedDark = Color(0xFF1A251C);
  static const Color surfaceSubtleDark = Color(0xFF202C23);

  static const Color textPrimaryDark = Color(0xFFF2F7F3);
  static const Color textSecondaryDark = Color(0xFFA8B5AB);
  static const Color textMutedDark = Color(0xFF88968B);
  static const Color textDisabledDark = Color(0xFF667269);

  static const Color borderDark = Color(0xFF2A382D);
  static const Color dividerDark = Color(0xFF202C23);
  static const Color disabledBgDark = Color(0xFF29322B);

  // ═══════════════════════════════════════════════════════
  // CATEGORY CHART COLOURS
  // ═══════════════════════════════════════════════════════
  // Light mode charts
  static const Color chartTransportLight = Color(0xFF2563EB);
  static const Color chartFoodLight = Color(0xFFD97706);
  static const Color chartHomeLight = Color(0xFF7C3AED);
  static const Color chartPurchasesLight = Color(0xFFDB2777);
  static const Color chartWasteLight = Color(0xFF0F766E);

  // Dark mode charts
  static const Color chartTransportDark = Color(0xFF60A5FA);
  static const Color chartFoodDark = Color(0xFFFBBF24);
  static const Color chartHomeDark = Color(0xFFA78BFA);
  static const Color chartPurchasesDark = Color(0xFFF472B6);
  static const Color chartWasteDark = Color(0xFF2DD4BF);

  // ═══════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════
  static const LinearGradient withinLimitGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
  );

  static const LinearGradient overLimitGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8E1818), Color(0xFFE53935)],
  );

  static const LinearGradient neutralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF084C48), Color(0xFF0F766E)],
  );

  // Dark mode soft gradients
  static const LinearGradient withinLimitGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF173D1B), Color(0xFF1B5E20)],
  );

  static const LinearGradient overLimitGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF481516), Color(0xFF8E1818)],
  );

  static const LinearGradient neutralGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF123D39), Color(0xFF084C48)],
  );

  // ═══════════════════════════════════════════════════════
  // CONVENIENCE ALIASES
  // ═══════════════════════════════════════════════════════
  static const Color greenDark = greenPrimaryDark;
  static const Color redDark = redPrimaryDark;
  static const Color tealDark = tealPrimaryDark;
}
