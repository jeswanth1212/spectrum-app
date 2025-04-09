import 'package:flutter/material.dart';
import '../models/team.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../services/auth_service.dart';
import 'team_credentials_screen.dart';

class TeamMemberDetailsScreen extends StatefulWidget {
  final String teamName;

  const TeamMemberDetailsScreen({
    Key? key,
    required this.teamName,
  }) : super(key: key);

  @override
  _TeamMemberDetailsScreenState createState() => _TeamMemberDetailsScreenState();
}

class _TeamMemberDetailsScreenState extends State<TeamMemberDetailsScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  
  // Leader details controllers
  final TextEditingController _leaderNameController = TextEditingController();
  final TextEditingController _leaderEmailController = TextEditingController();
  final TextEditingController _leaderPhoneController = TextEditingController();
  final TextEditingController _leaderDeviceController = TextEditingController();
  
  // List of members
  final List<MemberForm> _memberForms = [];
  final int _minMembers = 3; // For a total of 4 with the leader
  final int _maxMembers = 5; // For a total of 6 with the leader
  
  @override
  void initState() {
    super.initState();
    // Add initial empty member forms
    for (int i = 0; i < _minMembers; i++) {
      _memberForms.add(MemberForm(
        index: i,
        onRemove: _removeMemberForm,
      ));
    }
  }
  
  @override
  void dispose() {
    _leaderNameController.dispose();
    _leaderEmailController.dispose();
    _leaderPhoneController.dispose();
    _leaderDeviceController.dispose();
    for (var form in _memberForms) {
      form.dispose();
    }
    super.dispose();
  }

  void _addMemberForm() {
    if (_memberForms.length < _maxMembers) {
      setState(() {
        _memberForms.add(MemberForm(
          index: _memberForms.length,
          onRemove: _removeMemberForm,
        ));
      });
    }
  }

  void _removeMemberForm(int index) {
    if (_memberForms.length > _minMembers) {
      setState(() {
        _memberForms.removeAt(index);
        // Update indices for remaining forms
        for (int i = 0; i < _memberForms.length; i++) {
          _memberForms[i].updateIndex(i);
        }
      });
    }
  }

  Future<void> _registerTeam() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Create team leader
        final leader = TeamMember(
          name: _leaderNameController.text.trim(),
          email: _leaderEmailController.text.trim(),
          phone: _leaderPhoneController.text.trim(),
          device: _leaderDeviceController.text.trim(),
        );

        // Create team members
        final members = _memberForms.map((form) => form.getMember()).toList();

        // Register team with Firebase
        final result = await _authService.registerTeam(
          teamName: widget.teamName,
          leader: leader,
          members: members,
        );

        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          // Navigate to credentials screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TeamCredentialsScreen(team: result['team']),
            ),
          );
        } else {
          setState(() {
            _errorMessage = result['message'];
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An error occurred: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Team Details'),
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
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                Text(
                  'Team "${widget.teamName}"',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter details for all team members',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Team Leader Section
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppTheme.accentColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Team Leader',
                            style: TextStyle(
                              color: AppTheme.accentColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Leader Name
                      CustomTextField(
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        controller: _leaderNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Leader Email
                      CustomTextField(
                        label: 'Email',
                        hint: 'Enter your email address',
                        controller: _leaderEmailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Leader Phone
                      CustomTextField(
                        label: 'Phone Number',
                        hint: 'Enter your phone number',
                        controller: _leaderPhoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Leader Device
                      CustomTextField(
                        label: 'Device',
                        hint: 'Enter your device (e.g., Laptop, Mobile)',
                        controller: _leaderDeviceController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your device';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Team Members Section
                Text(
                  'Team Members (${_memberForms.length})',
                  style: TextStyle(
                    color: AppTheme.textPrimaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Member Forms
                ...List.generate(_memberForms.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _memberForms[index],
                  );
                }),
                
                // Add Member Button (if less than max members)
                if (_memberForms.length < _maxMembers)
                  TextButton.icon(
                    onPressed: _addMemberForm,
                    icon: Icon(
                      Icons.add_circle,
                      color: AppTheme.accentColor,
                    ),
                    label: Text(
                      'Add Team Member',
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Error Message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.errorColor.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Register Button
                GlassButton(
                  text: 'Register Team',
                  onPressed: _registerTeam,
                  isLoading: _isLoading,
                  icon: Icons.how_to_reg,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MemberForm extends StatefulWidget {
  int index;
  final Function(int) onRemove;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _deviceController = TextEditingController();

  MemberForm({
    Key? key,
    required this.index,
    required this.onRemove,
  }) : super(key: key);

  void updateIndex(int newIndex) {
    index = newIndex;
  }

  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _deviceController.dispose();
  }

  TeamMember getMember() {
    return TeamMember(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      device: _deviceController.text.trim(),
    );
  }

  @override
  _MemberFormState createState() => _MemberFormState();
}

class _MemberFormState extends State<MemberForm> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expand/collapse functionality
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Member ${widget.index + 1}',
                  style: TextStyle(
                    color: AppTheme.textPrimaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppTheme.textSecondaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.remove_circle,
                    color: AppTheme.errorColor.withOpacity(0.7),
                  ),
                  onPressed: () => widget.onRemove(widget.index),
                ),
              ],
            ),
          ),
          
          // Form fields (shown when expanded)
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            
            // Member Name
            CustomTextField(
              label: 'Full Name',
              hint: 'Enter member\'s full name',
              controller: widget._nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter member\'s name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Member Email
            CustomTextField(
              label: 'Email',
              hint: 'Enter member\'s email address',
              controller: widget._emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter member\'s email';
                } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Member Phone
            CustomTextField(
              label: 'Phone Number',
              hint: 'Enter member\'s phone number',
              controller: widget._phoneController,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter member\'s phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Member Device
            CustomTextField(
              label: 'Device',
              hint: 'Enter member\'s device (e.g., Laptop, Mobile)',
              controller: widget._deviceController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter member\'s device';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }
} 