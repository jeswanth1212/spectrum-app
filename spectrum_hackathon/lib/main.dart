import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'models/team.dart';
import 'screens/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spectrum Hackathon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }

  // Create a dummy team for testing
  Team _createDummyTeam() {
    final leader = TeamMember(
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '1234567890',
      device: 'Laptop',
    );

    final members = [
      TeamMember(
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
        phone: '1234567891',
        device: 'Laptop',
      ),
      TeamMember(
        name: 'Bob Johnson',
        email: 'bob.johnson@example.com',
        phone: '1234567892',
        device: 'Mobile',
      ),
      TeamMember(
        name: 'Alice Williams',
        email: 'alice.williams@example.com',
        phone: '1234567893',
        device: 'Tablet',
      ),
    ];

    return Team(
      teamName: 'Spectrum Coders',
      teamId: 'team123',
      username: 'spectrum_coders',
      password: '12345678',
      leader: leader,
      members: members,
      isVerified: true,
    );
  }
}
