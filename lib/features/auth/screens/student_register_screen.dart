import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final nationalIdController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final studentIdController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final courseController = TextEditingController();
  final yearController = TextEditingController();

  bool _loading = false;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      Fluttertoast.showToast(msg: 'Passwords do not match');
      return;
    }

    setState(() => _loading = true);

    try {
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = authResponse.user;

      if (user != null) {
        await Supabase.instance.client.from('profiles').insert({
          'id': user.id,
          'full_name': nameController.text.trim(),
          'national_id': nationalIdController.text.trim(),
          'student_id': studentIdController.text.trim().isEmpty
              ? null
              : studentIdController.text.trim(),
          'date_of_birth': dateOfBirthController.text.trim(),
          'course': courseController.text.trim(),
          'course_year': yearController.text.trim(),
        });

        Fluttertoast.showToast(msg: "Account created! Check your email.");
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget buildInput(TextEditingController controller, String label,
      {bool obscureText = false,
      bool required = true,
      TextInputType type = TextInputType.text,
      bool isDate = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: isDate,
        onTap: isDate
            ? () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  initialDate: DateTime(2000),
                );
                if (pickedDate != null) {
                  controller.text = pickedDate.toIso8601String().split("T")[0];
                }
              }
            : null,
        keyboardType: type,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    nationalIdController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    studentIdController.dispose();
    dateOfBirthController.dispose();
    courseController.dispose();
    yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildInput(nameController, 'Full Name'),
              buildInput(nationalIdController, 'National ID'),
              buildInput(emailController, 'Email',
                  type: TextInputType.emailAddress),
              buildInput(passwordController, 'Password', obscureText: true),
              buildInput(confirmPasswordController, 'Confirm Password',
                  obscureText: true),
              buildInput(studentIdController, 'Student ID (optional)',
                  required: false),
              buildInput(dateOfBirthController, 'Date of Birth', isDate: true),
              buildInput(courseController, 'Course'),
              buildInput(yearController, 'Year of Course',
                  type: TextInputType.number),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Register'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
