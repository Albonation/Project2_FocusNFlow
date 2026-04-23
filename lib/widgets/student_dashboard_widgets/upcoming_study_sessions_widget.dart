import 'package:flutter/material.dart';

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

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Upcoming Study Sessions",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // Scrollable area
          SizedBox(
            height: 250, 
            child: ListView.separated(
              itemCount: sessions.length,
              separatorBuilder: (context, index) =>
                  const Divider(thickness: 1),
              itemBuilder: (context, index) {
                final session = sessions[index];

                return ListTile(
                  title: Text(session["title"] as String),

                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(session["title"] as String),
                        content: Text(
                          "People Joined: ${session["people"]}\n\n"
                          "Description: ${session["description"]}",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close"),
                          ),
                        ],
                      ),
                    );
                  },

                  trailing: ElevatedButton(
                    onPressed: () {
                      debugPrint("Join ${session["title"]}");
                    },
                    child: const Text("Join"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}