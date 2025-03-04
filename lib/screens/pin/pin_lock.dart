import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:securenote/screens/home/home.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  _PinLockScreenState createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _storedPin;
  bool _isFirstTime = false;

  @override
  void initState() {
    super.initState();
    _checkForStoredPin();
  }

  Future<void> _checkForStoredPin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _storedPin = prefs.getString('user_pin');
      _isFirstTime = _storedPin == null;
    });
  }

  Future<void> _savePin(String pin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pin', pin);
  }

  void _validatePin() async {
    if (_isFirstTime) {
      // Save the new PIN and navigate to the home screen
      await _savePin(_pinController.text);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home(title: 'Secure Note')),
      );
    } else {
      // Validate the entered PIN
      if (_pinController.text == _storedPin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home(title: 'Secure Note')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect PIN')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(94, 114, 228, 1.0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/logo.png',
                  height: 100.0,
                ),
                const SizedBox(height: 20),

                const SizedBox(height: 40),
                Text(
                  _isFirstTime ? 'Create a PIN' : 'Enter PIN to Unlock',
                  style: const TextStyle(fontSize: 24.0, color: Colors.white),
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter PIN',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _validatePin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    _isFirstTime ? 'Set PIN' : 'Unlock',
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}