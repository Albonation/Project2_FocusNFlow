import 'package:flutter/material.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class UpcomingStudySessions extends StatelessWidget {
  const UpcomingStudySessions({super.key});

  @override
  Widget build(BuildContext context) {
    final sessions = List.generate(
      10,
      (index) => {
        "title": "Study Session ${index + 1}",
        "people": 4,
        "description": "Quick Review",
      },
    );

    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Upcoming Study Sessions",
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            AppSpacing.gapMd,

            // Scrollable area
            SizedBox(
              height: 250,
              child: ListView.separated(
                itemCount: sessions.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final session = sessions[index];

                  return _StudySessionTile(
                    title: session["title"] as String,
                    people: session["people"] as int,
                    description: session["description"] as String,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudySessionTile extends StatelessWidget {
  final String title;
  final int people;
  final String description;

  const _StudySessionTile({
    required this.title,
    required this.people,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.groups_outlined, color: context.appColors.group),
      title: Text(
        title,
        style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        "${people} people joined • $description ",
        style: context.text.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
      onTap: () {
        _showSessionDetails(context);
      },
      trailing: FilledButton(
        onPressed: () {
          debugPrint("Join $title");
        },
        child: const Text("Join"),
      ),
    );
  }

  void _showSessionDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(
            'People Joined: $people\n\n'
            'Description: $description',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
