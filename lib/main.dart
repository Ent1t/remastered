import 'package:flutter/material.dart';
import 'screen/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Huni sa Tribu',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Regular',
      ),
      home: WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  String _selectedRole = 'Visitor';
  bool _showSchoolField = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // Replace with your background image
          image: DecorationImage(
            image: AssetImage('assets/image/background/logging/main.png'), // Add your image here
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // Dark overlay for better text visibility
          color: Colors.black.withOpacity(0.6),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  
                  // Logo/Title Box
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'HUNI SA TRIBU',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Welcome Text
                  Text(
                    'Welcome!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Name Input Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Name',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Role Selection Dropdown
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _selectedRole == 'Visitor' 
                          ? Colors.grey.withOpacity(0.8)
                          : Colors.yellow.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedRole,
                        isExpanded: true,
                        style: TextStyle(
                          color: _selectedRole == 'Visitor' ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                        dropdownColor: Colors.white,
                        items: <String>['Visitor', 'Student'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                value,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedRole = newValue!;
                            _showSchoolField = (_selectedRole == 'Student');
                          });
                        },
                        icon: Padding(
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: _selectedRole == 'Visitor' ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // School Input Field (only for students)
                  if (_showSchoolField) ...[
                    SizedBox(height: 20),
                    Text(
                      'What School?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.yellow.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _schoolController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Ex: STI College Tagum',
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                      ),
                    ),
                  ],
                  
                  SizedBox(height: 40),
                  
                  // Proceed Button
                  ElevatedButton(
                    onPressed: () {
                      _proceedToNext();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'PROCEED',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _proceedToNext() {
    // Validate inputs
    if (_nameController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your name');
      return;
    }
    
    if (_selectedRole == 'Student' && _schoolController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your school');
      return;
    }

    // Process the data and navigate to next screen
    Map<String, dynamic> userData = {
      'name': _nameController.text.trim(),
      'role': _selectedRole,
      if (_selectedRole == 'Student') 'school': _schoolController.text.trim(),
    };

    // Navigate to home screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(userData: userData),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }
}