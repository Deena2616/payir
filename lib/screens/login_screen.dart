
import 'package:flutter/material.dart';
import '../core/l10n.dart';
import '../core/theme.dart';
import '../widgets/glass.dart';
import 'common.dart';

// BY-01: Mobile number + one-time code.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobile = TextEditingController();
  final _code = TextEditingController();

  bool _codeSent = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _mobile.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final m = _mobile.text.trim();

    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(m)) {
      setState(() => _error = 'bad_mobile');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final success = await context.app.sendOtp(m);

      if (!mounted) return;

      setState(() {
        _loading = false;

        if (success) {
          _codeSent = true;
        } else {
          _error =
          'Could not send OTP. Check your mobile number and server.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Could not send OTP. Please try again.';
      });
    }
  }

  Future<void> _verify() async {
    final otp = _code.text.trim();

    if (!RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      setState(() => _error = 'Please enter a valid 6-digit OTP.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ok = await context.app.verifyOtp(otp);

      if (!mounted) return;

      setState(() {
        _loading = false;

        if (!ok) {
          _error = 'Incorrect or expired OTP. Please try again.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'OTP verification failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingScaffold(
      appBar: AppBar(
        title: Text(context.tr('app_name')),
        actions: const [LangSwitch()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          AnimatedEntry(
            child: Center(
              child: Container(
                width: 104,
                height: 104,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kGreenLight, kTeal],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x662E7D32),
                      blurRadius: 30,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.agriculture,
                  size: 56,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          AnimatedEntry(
            index: 1,
            child: const Text(
              'பயிர் · Payir',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: kInk,
              ),
            ),
          ),

          const SizedBox(height: 22),

          AnimatedEntry(
            index: 2,
            child: GlassCard(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.tr('login_title'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: kInk,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(context.tr('login_sub')),

                    const SizedBox(height: 16),

                    TextField(
                      controller: _mobile,
                      enabled: !_codeSent && !_loading,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: context.tr('mobile'),
                        prefixText: '+91 ',
                        counterText: '',
                      ),
                    ),

                    if (_codeSent) ...[
                      const SizedBox(height: 12),

                      TextField(
                        controller: _code,
                        enabled: !_loading,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: context.tr('enter_code'),
                          counterText: '',
                        ),
                      ),

                      const SizedBox(height: 4),

                      if (context.app.developmentOtp != null)
                        Text(
                          'Local testing OTP: ${context.app.developmentOtp}',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],

                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 18),

                    FilledButton(
                      onPressed: _loading
                          ? null
                          : (_codeSent ? _verify : _send),
                      child: _loading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        context.tr(
                          _codeSent ? 'verify' : 'send_code',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
