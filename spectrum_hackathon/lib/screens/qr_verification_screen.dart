import 'package:flutter/material.dart';
import '../models/team.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../services/qr_scanner_service.dart';
import 'main_app_screen.dart';

class QRVerificationScreen extends StatefulWidget {
  final Team team;

  const QRVerificationScreen({
    Key? key,
    required this.team,
  }) : super(key: key);

  @override
  _QRVerificationScreenState createState() => _QRVerificationScreenState();
}

class _QRVerificationScreenState extends State<QRVerificationScreen> {
  final QRScannerService _qrScannerService = QRScannerService();
  bool _isLoading = false;
  String? _errorMessage;

  void _startQRScan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRScannerWidget(
            onQRViewCreated: _processQRCode,
            onCancel: () {
              setState(() {
                _isLoading = false;
              });
            },
          ),
        ),
      );

      if (result != null && result is Map<String, dynamic> && result['success']) {
        // Navigate to main app screen if verification successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainAppScreen(team: widget.team),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred during QR scanning: $e';
      });
    }
  }

  Future<Map<String, dynamic>> _processQRCode(String qrData) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Process QR code
      final result = await _qrScannerService.processQRCode(qrData);

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        // Return to navigate to main app
        Navigator.pop(context, result);
      } else {
        setState(() {
          _errorMessage = result['message'];
        });
      }

      return result;
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred during QR processing: $e';
      });
      return {
        'success': false,
        'message': 'An error occurred during QR processing: $e',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'QR Verification'),
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Icon(
                  Icons.qr_code_scanner,
                  color: AppTheme.primaryColor,
                  size: 80,
                ),
                const SizedBox(height: 24),
                Text(
                  'Team Verification Required',
                  style: TextStyle(
                    color: AppTheme.textPrimaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Please scan the QR code provided by the organizers to verify your team and access the hackathon app.',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Instructions Card
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.accentColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Instructions',
                            style: TextStyle(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1. Find an organizing committee member\n'
                        '2. Ask them to show you the verification QR code\n'
                        '3. Scan the QR code with your camera\n'
                        '4. Once verified, you\'ll get access to the hackathon app',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
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
                  const SizedBox(height: 20),
                ],
                
                // Scan QR Button
                GlassButton(
                  text: 'Scan QR Code',
                  onPressed: _startQRScan,
                  isLoading: _isLoading,
                  icon: Icons.qr_code_scanner,
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