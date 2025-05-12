import 'package:flutter/material.dart';
import 'package:xavlog_core/features/dash_board/home_page_dashboard.dart';
import 'package:xavlog_core/features/dash_board/profile.dart';
import 'package:xavlog_core/features/event_finder/eventfinderpage.dart';
import 'package:xavlog_core/features/grades_tracker/initial_page.dart';
import 'package:xavlog_core/route/general_navigation.dart';

import 'package:xavlog_core/features/market_place/screens/dashboard/dashboard_page.dart';

class HomeWrapper extends StatelessWidget {
  final int initialTab;
  const HomeWrapper({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, 
      child: MainScaffold(
        initialIndex: initialTab,
        screens: const [
          Homepage(),
          InitialPage(),
          EventFinderPage(),
          HomeWidget(),
          ProfilePage(),
        ],
      ),
    );
  }
}
