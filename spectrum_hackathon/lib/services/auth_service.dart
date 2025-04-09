import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Generate a unique username and password for the team
  Map<String, String> _generateTeamCredentials(String teamName) {
    final random = Random();
    final username = '${teamName.toLowerCase().replaceAll(' ', '')}_${random.nextInt(1000)}';
    final password = List.generate(8, (_) => random.nextInt(9)).join();
    
    return {
      'username': username,
      'password': password,
    };
  }
  
  // Register a new team with team leader
  Future<Map<String, dynamic>> registerTeam({
    required String teamName,
    required TeamMember leader,
    required List<TeamMember> members,
  }) async {
    try {
      // Generate credentials
      final credentials = _generateTeamCredentials(teamName);
      final username = credentials['username']!;
      final password = credentials['password']!;
      
      // Create email from username for Firebase Auth
      final email = '$username@hackathon.app';
      
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create team in Firestore
      final team = Team(
        teamName: teamName,
        teamId: userCredential.user!.uid,
        username: username,
        password: password,
        leader: leader,
        members: members,
      );
      
      // Save team to Firestore
      await _firestore.collection('teams').doc(userCredential.user!.uid).set(team.toJson());
      
      return {
        'success': true,
        'team': team,
        'message': 'Team registered successfully',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': e.message ?? 'An error occurred during registration',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }
  
  // Login as team leader or member
  Future<Map<String, dynamic>> loginTeam({
    required String username,
    required String password,
  }) async {
    try {
      // Create email from username for Firebase Auth
      final email = '$username@hackathon.app';
      
      // Login with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Get team from Firestore
      final teamSnapshot = await _firestore.collection('teams').doc(userCredential.user!.uid).get();
      
      if (teamSnapshot.exists) {
        final team = Team.fromJson(teamSnapshot.data() as Map<String, dynamic>);
        return {
          'success': true,
          'team': team,
          'message': 'Login successful',
        };
      } else {
        await _auth.signOut();
        return {
          'success': false,
          'message': 'Team not found',
        };
      }
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': e.message ?? 'Invalid username or password',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }
  
  // Verify team using QR code
  Future<Map<String, dynamic>> verifyTeam(String teamId) async {
    try {
      // Update team verification status
      await _firestore.collection('teams').doc(teamId).update({
        'isVerified': true,
      });
      
      return {
        'success': true,
        'message': 'Team verified successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred during verification: $e',
      };
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Get current team
  Future<Team?> getCurrentTeam() async {
    final user = _auth.currentUser;
    
    if (user != null) {
      final teamSnapshot = await _firestore.collection('teams').doc(user.uid).get();
      
      if (teamSnapshot.exists) {
        return Team.fromJson(teamSnapshot.data() as Map<String, dynamic>);
      }
    }
    
    return null;
  }
}