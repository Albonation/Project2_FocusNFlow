import 'package:flutter/material.dart';
import '../../screens/sign_up_screen.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class SignInForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback login;

  const SignInForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.login,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppSpacing.gapXl,

        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: "Email",
            hintText: 'you@student.gsu.edu',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),

        AppSpacing.gapLg,

        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Password",
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),

        AppSpacing.gapXl,

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: login, child: const Text("Login")),
        ),

        AppSpacing.gapLg,

        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()),
            );
          },
          child: Text(
            "Don't have an account? Sign Up",
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
