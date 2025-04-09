import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'team_member_details.dart';

class TeamLeaderSignupScreen extends StatefulWidget {
  const TeamLeaderSignupScreen({Key? key}) : super(key: key);

  @override
  _TeamLeaderSignupScreenState createState() => _TeamLeaderSignupScreenState();
}

class _TeamLeaderSignupScreenState extends State<TeamLeaderSignupScreen> {
  final _teamNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  void _proceedToMemberDetails() {
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      final teamName = _teamNameController.text.trim();
      
      // Navigate to team member details screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeamMemberDetailsScreen(teamName: teamName),
        ),
      );
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Create Team'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryDarkColor.withOpacity(0.8),
              AppTheme.backgroundColor,
              AppTheme.primaryDarkColor.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.group_add,
                      color: AppTheme.primaryColor,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Let\'s Start Your Hackathon Journey!',
                    style: TextStyle(
                      color: AppTheme.textPrimaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'First, give your team a cool name',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
                  // Team name field
                  CustomTextField(
                    label: 'Team Name',
                    hint: 'Enter your team name',
                    controller: _teamNameController,
                    prefixIcon: Icon(
                      Icons.groups,
                      color: AppTheme.textSecondaryColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a team name';
                      } else if (value.length < 3) {
                        return 'Team name must be at least 3 characters';
                      } else if (value.length > 20) {
                        return 'Team name must be less than 20 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  
                  // Next button
                  GlassButton(
                    text: 'Next',
                    onPressed: _proceedToMemberDetails,
                    isLoading: _isLoading,
                    icon: Icons.arrow_forward,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Info text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.glassBorderColor),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.accentColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Registration Process:',
                                style: TextStyle(
                                  color: AppTheme.accentColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '1. Enter your team name\n'
                          '2. Add your details as team leader\n'
                          '3. Add details of your team members (4-6 members)\n'
                          '4. Review and confirm\n'
                          '5. Get your team credentials',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 