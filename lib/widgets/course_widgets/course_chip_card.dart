import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/course_model.dart';
import 'package:focus_n_flow/theme/app_corners.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class CourseChipCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const CourseChipCard({super.key, required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppCorners.lg),
        onTap: onTap,
        child: Container(
          padding: AppSpacing.compactTilePadding,
          decoration: BoxDecoration(
            color: context.appColors.surfaceMuted,
            border: Border.all(color: context.appColors.cardBorder),
            borderRadius: BorderRadius.circular(AppCorners.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 20,
                    color: context.appColors.studyRoom,
                  ),

                  AppSpacing.horizontalGapSm,

                  Expanded(
                    child: Text(
                      course.courseCode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              AppSpacing.gapXs,

              Text(
                course.courseName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),

              AppSpacing.gapXs,

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.balance,
                    size: 13,
                    color: context.appColors.planner,
                  ),

                  AppSpacing.horizontalGapXs,

                  Text(
                    'Weight ${course.courseWeight.toStringAsFixed(0)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelSmall?.copyWith(
                      color: context.appColors.planner,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
