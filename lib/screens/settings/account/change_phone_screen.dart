import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePhoneScreen extends StatefulWidget {
  const ChangePhoneScreen({super.key});

  @override
  State<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends State<ChangePhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _loading = false;

  Future<void> _changePhone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final response = await Supabase.instance.client.auth.updateUser(
        UserAttributes(phone: _phoneController.text.trim()),
      );

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("📱 Phone number updated successfully!"),
          ),
        );
        Navigator.pop(context); // ✅ Back to Account Settings
      } else {
        throw Exception("Failed to update phone number");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Phone Number")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "New Phone Number",
                  border: OutlineInputBorder(),
                  hintText: "+254700000000", // Example for Kenya
                ),
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Enter a valid phone number";
                  }
                  if (!RegExp(r'^\+?[0-9]{9,15}$').hasMatch(val)) {
                    return "Invalid phone format (e.g., +254700000000)";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _changePhone,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update Phone"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
