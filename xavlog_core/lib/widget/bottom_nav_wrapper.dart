import 'package:flutter/material.dart';
import 'package:xavlog_core/features/dash_board/home_page_dashboard.dart';
import 'package:xavlog_core/features/dash_board/profile.dart';
import 'package:xavlog_core/features/event_finder/eventfinderpage.dart';
import 'package:xavlog_core/features/grades_tracker/initial_page.dart';
import 'package:xavlog_core/features/market_place/screens/dashboard/dashboardpage.dart';
import 'package:xavlog_core/route/general_navigation.dart'; // Import your MainScaffold

class HomeWrapper extends StatelessWidget {
  const HomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      screens: const [
        Homepage(),
        InitialPage(),
        EventFinderPage(),
        HomeWidget(),
        ProfilePage(),
      ],
    );
  }
}
