import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../home/home_page.dart';
import 'register_page.dart';
import '../InsuranceCompany/InsuraceComanyDashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  Future<void> _signIn() async {
    try {
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        final userData = await _authService.getUserData();
        print('User Data: $userData');

        if (userData?['isCompany'] == true) {
          print('Is Company Account - Getting company data');
          final companyData = await _authService
              .getInsuranceCompanyData(userData?['insuranceCompanyId']);
          print('Company Data: $companyData');

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => InsuranceCompanyDashboard(
                  companyName: userData?['name'] ?? 'Company',
                  companyData: companyData,
                ),
              ),
            );
          }
        } else {
          print('Regular User Account');
          if (userData?['insuranceCompanyId'] != null) {
            await _authService.updateInsuranceCompanyCustomers(
                userData?['insuranceCompanyId'], userData?['uid']);
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                title: 'Welcome ${userData?['name'] ?? 'User'}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        final userData = await _authService.getUserData();
        if (userData?['isCompany'] == true) {
          final companyData =
              await _authService.getInsuranceCompanyData(userData?['uid']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => InsuranceCompanyDashboard(
                companyName: userData?['name'] ?? 'Company',
                companyData: companyData,
              ),
            ),
          );
        } else {
          if (userData?['insuranceCompanyId'] != null) {
            await _authService.updateInsuranceCompanyCustomers(
                userData?['insuranceCompanyId'], userData?['uid']);
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                title: 'Welcome ${userData?['name'] ?? 'User'}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AuthTextField(
              controller: _emailController,
              labelText: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _passwordController,
              labelText: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _signIn,
              child: const Text('Login'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: const Text('Don\'t have an account? Register'),
            ),
            const SizedBox(height: 24),
            const Text('OR'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _signInWithGoogle,
              icon: const Icon(Icons.g_mobiledata, size: 24),
              label: const Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
