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
    // List of features with their corresponding screens + icons
    final List<Map<String, dynamic>> features = [
      {
        "title": "Exam Card",
        "icon": Icons.credit_card,
        "page": const ExamCardScreen()
      },
      {
        "title": "My Class Chat",
        "icon": Icons.chat_bubble,
        "page": const MyClassChatScreen()
      },
      {
        "title": "Dashboard",
        "icon": Icons.dashboard,
        "page": const AcademicsDashboardScreen()
      },
      {
        "title": "My Timetable",
        "icon": Icons.schedule,
        "page": const TimetableScreen()
      },
      {
        "title": "My Assignments",
        "icon": Icons.assignment,
        "page": const AssignmentsScreen()
      },
      {
        "title": "My Attachments",
        "icon": Icons.attach_file,
        "page": const AttachmentsScreen()
      },
      {
        "title": "Unit Registrations",
        "icon": Icons.app_registration,
        "page": const UnitRegistrationScreen()
      },
      {
        "title": "Transcripts / Results",
        "icon": Icons.school,
        "page": const TranscriptsScreen()
      },
      {
        "title": "Answer Question Feature",
        "icon": Icons.question_answer,
        "page": const AnswerQuestionScreen()
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Academics",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => feature["page"]),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueAccent.shade100,
                      Colors.blueAccent.shade400
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Icon(
                        feature["icon"],
                        color: Colors.blueAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        feature["title"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 18, color: Colors.white),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
