import 'package:flutter/material.dart';
import 'package:focus_n_flow/screens/sign_in_screen.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme_extensions.dart';

class SignUpForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPassController;
  final VoidCallback registerUser;

  const SignUpForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPassController,
    required this.registerUser,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppSpacing.gapXl,

        TextField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: "Full Name",
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),

        AppSpacing.gapLg,

        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: "Email",
            hintText: 'you@student.gsu.edu',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),

        AppSpacing.gapLg,

        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Password",
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),

        AppSpacing.gapLg,

        TextField(
          controller: confirmPassController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Confirm Password",
            prefixIcon: Icon(Icons.lock_reset_outlined),
          ),
        ),

        AppSpacing.gapXl,

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: registerUser,
            child: const Text("Sign Up"),
          ),
        ),

        AppSpacing.gapLg,

        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
            );
          },
          child: Text(
            "Already have an account? Sign In",
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.appColors.brand,
            ),
          ),
        ),
      ],
    );
  }
}
