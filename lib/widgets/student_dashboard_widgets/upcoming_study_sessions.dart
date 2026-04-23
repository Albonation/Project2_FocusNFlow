import 'package:flutter/material.dart';

class UpcomingStudySessions extends StatelessWidget {
  const UpcomingStudySessions({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 15),

            const Text(
              "Upcoming Study Sessions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.separated(
                itemCount: 5,
                separatorBuilder: (context, index) =>
                    const Divider(thickness: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      "Study Session ${index + 1}",
                    ),

                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            "Study Session ${index + 1}",
                          ),
                          content: const Text(
                            "People Joined: 4\n\nDescription: Quick Review",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Close"),
                            ),
                          ],
                        ),
                      );
                    },

                    trailing: ElevatedButton(
                      onPressed: () {
                        debugPrint(
                          "Redirect to Study Session ${index + 1}",
                        );
                      },
                      child: const Text("Join"),
                    ),
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