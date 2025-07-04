import 'package:flutter/material.dart';
import 'package:xavlog_core/features/dash_board/home_page_dashboard.dart';
import 'package:xavlog_core/features/dash_board/profile.dart';import 'package:xavlog_core/features/market_place/services/login_authentication/authentication_gate.dart';
import 'package:xavlog_core/features/new_grade_tracker/subjects.dart';
import 'package:xavlog_core/route/general_navigation.dart';

import 'package:xavlog_core/features/market_place/screens/dashboard/dashboard_page.dart';

class HomeWrapper extends StatelessWidget {
  final int initialTab;
  const HomeWrapper({super.key, this.initialTab = 2}); // default to Homepage

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: MainScaffold(
        initialIndex: 2,
        screens: const [
          SubjectScreen(),
          AuthenticationGate(),
          Homepage(), // index 2 (default)
          HomeWidget(),
          ProfilePage(),
        ],
      ),
    );
  }
}
