import 'package:flutter/material.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class AddEditStudyGroupDialog extends StatefulWidget {
  final String title;
  final String confirmText;
  final String initialName;
  final String initialDescription;

  const AddEditStudyGroupDialog({
    super.key,
    required this.title,
    required this.confirmText,
    this.initialName = '',
    this.initialDescription = '',
  });

  @override
  State<AddEditStudyGroupDialog> createState() =>
      _AddEditStudyGroupDialogState();
}

class _AddEditStudyGroupDialogState extends State<AddEditStudyGroupDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  void _submit() {
    Navigator.pop(
      context,
      StudyGroupFormResult(
        name: _nameController.text,
        description: _descriptionController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Group name',
                hintText: 'Example: Sunday Study Crew',
              ),
            ),

            AppSpacing.gapMd,

            TextField(
              controller: _descriptionController,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What is this group for?',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmText)),
      ],
    );
  }
}

class StudyGroupFormResult {
  final String name;
  final String description;

  const StudyGroupFormResult({required this.name, required this.description});
}
