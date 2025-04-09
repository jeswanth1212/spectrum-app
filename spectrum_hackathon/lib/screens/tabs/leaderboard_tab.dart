import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class LeaderboardTab extends StatelessWidget {
  const LeaderboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const CustomAppBar(
        title: 'Leaderboard',
      ),
      body: const Center(
        child: Text(
          'Leaderboard Tab',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
} 