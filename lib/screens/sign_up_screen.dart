import 'package:flutter/material.dart';
import 'package:focus_n_flow/screens/student_dashboard_screen.dart';
import 'package:focus_n_flow/services/registration_login_service.dart';
import '../widgets/login_signup_widgets/sign_up_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  void registerUser() async {
    final service = RegistrationLoginService();

    final error = await service.registerUser(
      fullname: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      confirmPassword: confirmPassController.text.trim(),
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registration Successful")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const StudentDashboardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: SignUpForm(
                nameController: nameController,
                emailController: emailController,
                passwordController: passwordController,
                confirmPassController: confirmPassController,
                registerUser: registerUser,
              ),
            ),
          ),
        ),
      ),
    );
  }
}