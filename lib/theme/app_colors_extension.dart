//this file defines colors for our app-specific concepts
//it is essentially a place to store custom semantic colors
import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color brand;
  final Color focus;
  final Color group;
  final Color task;
  final Color studyRoom;
  final Color planner;
  final Color success;
  final Color warning;
  final Color danger;

  final Color surfaceSoft;
  final Color surfaceMuted;
  final Color surfaceStrong;

  final Color cardBorder;
  final Color navBorder;


  const AppColors({
    required this.brand,
    required this.focus,
    required this.group,
    required this.task,
    required this.studyRoom,
    required this.planner,
    required this.success,
    required this.warning,
    required this.danger,
    required this.surfaceSoft,
    required this.surfaceMuted,
    required this.surfaceStrong,
    required this.cardBorder,
    required this.navBorder,
  });

  @override
  AppColors copyWith({
    Color? brand,
    Color? focus,
    Color? group,
    Color? task,
    Color? studyRoom,
    Color? planner,
    Color? success,
    Color? warning,
    Color? danger,
    Color? surfaceSoft,
    Color? surfaceMuted,
    Color? surfaceStrong,
    Color? cardBorder,
    Color? navBorder,

  }) {
    return AppColors(
      brand: brand ?? this.brand,
      focus: focus ?? this.focus,
      group: group ?? this.group,
      task: task ?? this.task,
      studyRoom: studyRoom ?? this.studyRoom,
      planner: planner ?? this.planner,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      cardBorder: cardBorder ?? this.cardBorder,
      navBorder: navBorder ?? this.navBorder,
    );
  }

  //nifty method that allows us to interpolate between two AppColors instances
  //like for switching theme
  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;

    Color lerpColor(Color a, Color b) => Color.lerp(a, b, t)!;

    return AppColors(
      brand: lerpColor(brand, other.brand),
      focus: lerpColor(focus, other.focus),
      group: lerpColor(group, other.group),
      task: lerpColor(task, other.task),
      studyRoom: lerpColor(studyRoom, other.studyRoom),
      planner: lerpColor(planner, other.planner),
      success: lerpColor(success, other.success),
      warning: lerpColor(warning, other.warning),
      danger: lerpColor(danger, other.danger),
      surfaceSoft: lerpColor(surfaceSoft, other.surfaceSoft),
      surfaceMuted: lerpColor(surfaceMuted, other.surfaceMuted),
      surfaceStrong: lerpColor(surfaceStrong, other.surfaceStrong),
      cardBorder: lerpColor(cardBorder, other.cardBorder),
      navBorder: lerpColor(navBorder, other.navBorder),
    );
  }
}
