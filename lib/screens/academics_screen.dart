import 'package:flutter/material.dart';

// Import each screen from the academics folder
import 'academics/exam_card.dart';
import 'academics/my_class_chat.dart';
import 'academics/dashboard.dart';
import 'academics/my_timetable.dart';
import 'academics/my_assignments.dart';
import 'academics/my_attachments.dart';
import 'academics/unit_registrations.dart';
import 'academics/transcripts_results.dart';
import 'academics/answer_question.dart';

class AcademicsScreen extends StatelessWidget {
  const AcademicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of features with their corresponding screens
    final List<Map<String, dynamic>> features = [
      {"title": "Exam Card", "page": const ExamCardScreen()},
      {"title": "My Class Chat", "page": const MyClassChatScreen()},
      {"title": "Dashboard", "page": const AcademicsDashboardScreen()},
      {"title": "My Timetable", "page": const TimetableScreen()},
      {"title": "My Assignments", "page": const AssignmentsScreen()},
      {"title": "My Attachments", "page": const AttachmentsScreen()},
      {"title": "Unit Registrations", "page": const UnitRegistrationScreen()},
      {"title": "Transcripts / Results", "page": const TranscriptsScreen()},
      {
        "title": "Answer Question Feature",
        "page": const AnswerQuestionScreen()
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Academics"),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: ListTile(
              title: Text(feature["title"]),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => feature["page"]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
