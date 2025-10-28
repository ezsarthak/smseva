import 'package:flutter/material.dart';

// ============================================
// SUVIDHA GOVERNMENT PORTAL COLOR SCHEME
// ============================================

// Primary Government Colors (Based on Indian Government portals)
const Color kGovPrimary = Color(0xFF1E3A8A);        // Deep Blue - Authority & Trust
const Color kGovSecondary = Color(0xFF047857);      // Forest Green - Progress & Growth
const Color kGovAccent = Color(0xFFFF9933);         // Saffron Orange - National Identity

// Status Colors (Professional & Accessible)
const Color kStatusNew = Color(0xFFDC2626);         // Red - Urgent/New
const Color kStatusInProgress = Color(0xFF2563EB);  // Blue - In Progress
const Color kStatusAwaiting = Color(0xFF7C3AED);    // Purple - Awaiting
const Color kStatusCompleted = Color(0xFF059669);   // Green - Completed
const Color kStatusCritical = Color(0xFFB91C1C);    // Dark Red - Critical

// Background Colors
const Color kBgPrimary = Color(0xFFF8FAFC);         // Light Gray-Blue
const Color kBgSecondary = Color(0xFFFFFFFF);       // White
const Color kBgCard = Color(0xFFFFFFFF);            // Card Background

// Text Colors
const Color kTextPrimary = Color(0xFF0F172A);       // Almost Black
const Color kTextSecondary = Color(0xFF475569);     // Gray
const Color kTextTertiary = Color(0xFF94A3B8);      // Light Gray
const Color kTextWhite = Color(0xFFFFFFFF);         // White

// Border & Divider Colors
const Color kBorderLight = Color(0xFFE2E8F0);       // Light Border
const Color kBorderMedium = Color(0xFFCBD5E1);      // Medium Border
const Color kDivider = Color(0xFFE2E8F0);           // Divider

// Shadow Colors
const Color kShadowLight = Color(0x0F000000);       // 6% Black
const Color kShadowMedium = Color(0x1A000000);      // 10% Black
const Color kShadowDark = Color(0x33000000);        // 20% Black

// Gradient Colors
const LinearGradient kGovGradient = LinearGradient(
  colors: [kGovPrimary, Color(0xFF2563EB)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kSuccessGradient = LinearGradient(
  colors: [Color(0xFF059669), Color(0xFF10B981)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Legacy Colors (for backward compatibility)
const Color kWorkerPrimaryColor = kGovSecondary;
const Color kBackgroundColor = kBgPrimary;
const Color kTextColor = kTextPrimary;
const Color kHintTextColor = kTextSecondary;