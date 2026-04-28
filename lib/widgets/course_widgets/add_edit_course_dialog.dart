import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focus_n_flow/models/course_model.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class AddEditCourseDialog extends StatefulWidget {
  final String userId;
  final Course? course;
  final Future<void> Function(Course course) onSave;

  const AddEditCourseDialog({
    super.key,
    required this.userId,
    required this.onSave,
    this.course,
  });

  bool get isEditMode => course != null;

  @override
  State<AddEditCourseDialog> createState() => _AddEditCourseDialogState();
}

class _AddEditCourseDialogState extends State<AddEditCourseDialog> {
  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _courseNameController = TextEditingController();

  double _selectedWeight = 3;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final course = widget.course;

    if (course != null) {
      _courseCodeController.text = course.courseCode;
      _courseNameController.text = course.courseName;
      _selectedWeight = course.courseWeight;
    }
  }

  @override
  void dispose() {
    _courseCodeController.dispose();
    _courseNameController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    if (_isSaving) return;

    final course = Course(
      id: widget.course?.id,
      userId: widget.userId,
      courseCode: _courseCodeController.text.trim(),
      courseName: _courseNameController.text.trim(),
      courseWeight: _selectedWeight,
      createdAt: widget.course?.createdAt,
      updatedAt: widget.course?.updatedAt,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(course);

      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isEditMode ? 'Edit Course' : 'Add Course',
        style: context.text.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _courseCodeController,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            onChanged: (value) {
              final upper = value.toUpperCase();

              _courseCodeController.value = TextEditingValue(
                text: upper,
                selection: TextSelection.collapsed(
                  offset: upper.length,
                ),
              );
            },
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              LengthLimitingTextInputFormatter(8),
            ],
            decoration: const InputDecoration(
              labelText: 'Course Code',
              hintText: 'CSC4360',
            ),
          ),

          AppSpacing.gapMd,

          TextField(
            controller: _courseNameController,
            decoration: const InputDecoration(
              labelText: 'Course Name',
              hintText: 'Mobile App Development',
            ),
          ),

          AppSpacing.gapMd,

          DropdownButtonFormField<double>(
            initialValue: _selectedWeight,
            decoration: const InputDecoration(
              labelText: 'Course Weight',
            ),
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 - Low')),
              DropdownMenuItem(value: 2, child: Text('2')),
              DropdownMenuItem(value: 3, child: Text('3 - Normal')),
              DropdownMenuItem(value: 4, child: Text('4')),
              DropdownMenuItem(value: 5, child: Text('5 - High')),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedWeight = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isSaving ? null : _saveCourse,
          child: Text(
            _isSaving
                ? 'Saving...'
                : widget.isEditMode
                ? 'Save'
                : 'Add',
            style: TextStyle(
              color: context.appColors.brand,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}