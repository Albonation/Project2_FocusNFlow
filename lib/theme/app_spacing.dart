//this file defines spacing values for our app
//it is essentially a place to store custom semantic spacing values
//and bring them together in one place for easy access and consistency across the app
import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  //base spacing values
  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  //semantic spacing values
  static const double screenPadding = lg;
  static const double cardPadding = lg;
  static const double tilePadding = md;
  static const double sectionSpacing = xl;

  //vertical gaps
  static const SizedBox gapXs = SizedBox(height: xs);
  static const SizedBox gapSm = SizedBox(height: sm);
  static const SizedBox gapMd = SizedBox(height: md);
  static const SizedBox gapLg = SizedBox(height: lg);
  static const SizedBox gapXl = SizedBox(height: xl);
  static const SizedBox gapXxl = SizedBox(height: xxl);

  //horizontal gaps
  static const SizedBox horizontalGapXs = SizedBox(width: xs);
  static const SizedBox horizontalGapSm = SizedBox(width: sm);
  static const SizedBox horizontalGapMd = SizedBox(width: md);
  static const SizedBox horizontalGapLg = SizedBox(width: lg);
  static const SizedBox horizontalGapXl = SizedBox(width: xl);

  //padding values
  static const EdgeInsets screen = EdgeInsets.all(screenPadding);
  static const EdgeInsets card = EdgeInsets.all(cardPadding);
  static const EdgeInsets tile = EdgeInsets.all(tilePadding);
  static const EdgeInsets section = EdgeInsets.all(sectionSpacing);

  //directional page or layout padding
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(
    horizontal: screenPadding,
  );

  static const EdgeInsets screenVertical = EdgeInsets.symmetric(
    vertical: screenPadding,
  );

  //row item or list padding
  static const EdgeInsets rowPadding = EdgeInsets.symmetric(vertical: sm);

  static const EdgeInsets listTilePadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  static const EdgeInsets compactTilePadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  static const EdgeInsets itemBottomPadding = EdgeInsets.only(bottom: sm);

  //vertical padding
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);

  //horizontal padding
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  //component specific padding
  static const EdgeInsets inputContent = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: lg,
  );

  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  static const EdgeInsets smallButton = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  static const EdgeInsets chip = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  static const EdgeInsets badge = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xs,
  );

  static const EdgeInsets dialog = EdgeInsets.all(xl);
  static const EdgeInsets bottomSheet = EdgeInsets.all(lg);

  static const EdgeInsets cardMargin = EdgeInsets.all(md);
}

