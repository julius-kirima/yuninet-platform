import 'package:flutter/material.dart';

// 🔹 Import all actual screens that exist
import 'academics_screen.dart';
import 'finance_screen.dart';
import 'administration_screen.dart';
import 'support_screen.dart';
import 'academics_upgrade_screen.dart';
import 'finance_opportunities_screen.dart';
import 'communication_screen.dart';
import 'convenience_screen.dart';
import 'voting_screen.dart';

class SmartHubScreen extends StatelessWidget {
  const SmartHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_HubItem> hubItems = [
      _HubItem(
        title: "Academics",
        subtitle: "Exam Card, Timetable, Results, Assignments",
        icon: Icons.school,
        color: Colors.deepPurple,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AcademicsScreen()),
          );
        },
      ),
      _HubItem(
        title: "Finance",
        subtitle: "Fees, eCitizen, Loans, Wallet",
        icon: Icons.account_balance_wallet,
        color: Colors.green,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FinanceScreen()),
          );
        },
      ),
      _HubItem(
        title: "Administration",
        subtitle: "Clearance, Cases, Reporting, Hostel",
        icon: Icons.admin_panel_settings,
        color: Colors.blue,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AdministrationScreen()),
          );
        },
      ),
      _HubItem(
        title: "Support & Welfare",
        subtitle: "Counseling, Clubs, Lost & Found",
        icon: Icons.favorite,
        color: Colors.pink,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SupportScreen()),
          );
        },
      ),
      _HubItem(
        title: "Academics Upgrade",
        subtitle: "Materials, Projects, Library",
        icon: Icons.menu_book,
        color: Colors.orange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AcademicsUpgradeScreen()),
          );
        },
      ),
      _HubItem(
        title: "Finance & Opportunities",
        subtitle: "Scholarships, Jobs, Tracker",
        icon: Icons.work,
        color: Colors.teal,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const FinanceOpportunitiesScreen()),
          );
        },
      ),
      _HubItem(
        title: "Communication",
        subtitle: "Announcements, Polls, Tutoring",
        icon: Icons.campaign,
        color: Colors.indigo,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CommunicationScreen()),
          );
        },
      ),
      _HubItem(
        title: "Convenience & Tech",
        subtitle: "Smart ID, Notifications, Calendar",
        icon: Icons.smartphone,
        color: Colors.cyan,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ConvenienceScreen()),
          );
        },
      ),
      _HubItem(
        title: "Voting System",
        subtitle: "Student Elections & Referendums",
        icon: Icons.how_to_vote,
        color: Colors.redAccent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VotingScreen()),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Hub"),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 cards per row
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: hubItems.length,
          itemBuilder: (context, index) {
            final item = hubItems[index];
            return _HubCard(item: item);
          },
        ),
      ),
    );
  }
}

// 🔹 Model for Hub items
class _HubItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _HubItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

// 🔹 Hub Card Widget
class _HubCard extends StatelessWidget {
  final _HubItem item;

  const _HubCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: item.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: item.color,
              radius: 28,
              child: Icon(item.icon, size: 28, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              item.subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
