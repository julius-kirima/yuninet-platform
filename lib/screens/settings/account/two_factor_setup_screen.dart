import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TwoFactorSetupScreen extends StatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  State<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _loading = false;
  bool _otpSent = false;

  Future<void> _sendOTP() async {
    setState(() => _loading = true);
    try {
      final phone = _phoneController.text.trim();

      if (phone.isEmpty || !RegExp(r'^\+?[0-9]{9,15}$').hasMatch(phone)) {
        throw Exception("Enter a valid phone number (e.g. +254700000000)");
      }

      await Supabase.instance.client.auth.signInWithOtp(
        phone: phone,
      );

      setState(() {
        _otpSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📲 OTP sent to your phone")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verifyOTP() async {
    setState(() => _loading = true);
    try {
      final phone = _phoneController.text.trim();
      final otp = _otpController.text.trim();

      if (otp.isEmpty) {
        throw Exception("Enter the OTP code sent to your phone");
      }

      final response = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.sms,
        token: otp,
        phone: phone,
      );

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ 2FA Enabled Successfully!")),
        );
        Navigator.pop(context); // ✅ Go back to Account Settings
      } else {
        throw Exception("Invalid OTP");
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
      appBar: AppBar(title: const Text("Enable Two-Factor Authentication")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                hintText: "+254700000000",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              enabled: !_otpSent, // disable after sending OTP
            ),
            const SizedBox(height: 20),
            if (_otpSent) ...[
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: "Enter OTP",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : _otpSent
                      ? _verifyOTP
                      : _sendOTP,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_otpSent ? "Verify OTP" : "Send OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
