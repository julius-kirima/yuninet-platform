import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 🔹 Import all actual screens
import 'academics_screen.dart';
import 'finance_screen.dart';
import 'administration_screen.dart';
import 'support_screen.dart';
import 'academics_upgrade_screen.dart';
import 'finance_opportunities_screen.dart';
import 'communication_screen.dart';
import 'convenience_screen.dart';
import 'voting_screen.dart';

class SmartHubScreen extends StatefulWidget {
  const SmartHubScreen({super.key});

  @override
  State<SmartHubScreen> createState() => _SmartHubScreenState();
}

class _SmartHubScreenState extends State<SmartHubScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<_HubItem> hubItems = [
    _HubItem(
      title: "Academics",
      subtitle: "Exam Card, Timetable, Results, Assignments",
      icon: Icons.school,
      gradient: [Colors.deepPurple, Colors.deepPurpleAccent],
      page: const AcademicsScreen(),
    ),
    _HubItem(
      title: "Finance",
      subtitle: "Fees, eCitizen, Loans, Wallet",
      icon: Icons.account_balance_wallet,
      gradient: [Colors.green, Colors.teal],
      page: const FinanceScreen(),
    ),
    _HubItem(
      title: "Administration",
      subtitle: "Clearance, Cases, Reporting, Hostel",
      icon: Icons.admin_panel_settings,
      gradient: [Colors.blue, Colors.blueAccent],
      page: const AdministrationScreen(),
    ),
    _HubItem(
      title: "Support & Welfare",
      subtitle: "Counseling, Clubs, Lost & Found",
      icon: Icons.favorite,
      gradient: [Colors.pink, Colors.redAccent],
      page: const SupportScreen(),
    ),
    _HubItem(
      title: "Academics Upgrade",
      subtitle: "Materials, Projects, Library",
      icon: Icons.menu_book,
      gradient: [Colors.orange, Colors.deepOrange],
      page: const AcademicsUpgradeScreen(),
    ),
    _HubItem(
      title: "Finance & Opportunities",
      subtitle: "Scholarships, Jobs, Tracker",
      icon: Icons.work,
      gradient: [Colors.teal, Colors.greenAccent],
      page: const FinanceOpportunitiesScreen(),
    ),
    _HubItem(
      title: "Communication",
      subtitle: "Announcements, Polls, Tutoring",
      icon: Icons.campaign,
      gradient: [Colors.indigo, Colors.indigoAccent],
      page: const CommunicationScreen(),
    ),
    _HubItem(
      title: "Convenience & Tech",
      subtitle: "Smart ID, Notifications, Calendar",
      icon: Icons.smartphone,
      gradient: [Colors.cyan, Colors.blueGrey],
      page: const ConvenienceScreen(),
    ),
    _HubItem(
      title: "Voting System",
      subtitle: "Student Elections & Referendums",
      icon: Icons.how_to_vote,
      gradient: [Colors.redAccent, Colors.deepOrange],
      page: const VotingScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedCard(BuildContext context, int index) {
    final item = hubItems[index];

    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutBack),
    );

    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: _HubCard(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // 🔹 Adjust grid aspect ratio responsively
    double aspectRatio = size.width < 600 ? 0.85 : 1.1;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Hub"),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.blue.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                size.width < 600 ? 2 : 3, // 2 on phone, 3 on tablets
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          ),
          itemCount: hubItems.length,
          itemBuilder: _buildAnimatedCard,
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
  final List<Color> gradient;
  final Widget page;

  _HubItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.page,
  });
}

// 🔹 Hub Card Widget
class _HubCard extends StatelessWidget {
  final _HubItem item;

  const _HubCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => item.page),
      ),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: item.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: item.gradient.last.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              // ignore: deprecated_member_use
              backgroundColor: Colors.white.withOpacity(0.25),
              radius: 24, // 🔹 smaller
              child: Icon(item.icon, size: 26, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14, // 🔹 smaller font
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              item.subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
