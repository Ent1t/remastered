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
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _schoolFocusNode = FocusNode();
  String _selectedRole = 'Visitor';
  bool _showSchoolField = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Hide keyboard when tapping outside text fields
          FocusScope.of(context).unfocus();
        },
        child: Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start, // Changed to start for left alignment
                  children: [
                    SizedBox(height: 40),
                    
                    // Logo/Title Box - centered (REMOVED name and role display)
                    Center(
                      child: Container(
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
                    ),
                    
                    SizedBox(height: 30),
                    
                    // Welcome Text - aligned to the left
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Welcome!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 40),
                    
                    // Transparent container wrapping both Name and Role inputs
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3), // Transparent dark background
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Name Input Field with "Name" label in top-left
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.4), // More transparent
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                // "Name" label in top-left corner
                                Positioned(
                                  top: 8,
                                  left: 15,
                                  child: Text(
                                    'Name',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                                // TextField with centered text and top padding
                                TextField(
                                  controller: _nameController,
                                  focusNode: _nameFocusNode,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center, // Center the input text
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  onTap: () {
                                    _nameFocusNode.requestFocus();
                                  },
                                  onSubmitted: (value) {
                                    if (_showSchoolField) {
                                      _schoolFocusNode.requestFocus();
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: '', // Remove placeholder text
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                      left: 20, 
                                      right: 20, 
                                      top: 35, // Top padding for label
                                      bottom: 15
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Role Selection Dropdown with "Role" label in top-left
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: _selectedRole == 'Visitor' 
                                  ? Colors.grey.withOpacity(0.4) // More transparent
                                  : Color(0xFFF5E6A8).withOpacity(0.9), // Cream/beige color for Student
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                // "Role" label in top-left corner
                                Positioned(
                                  top: 8,
                                  left: 15,
                                  child: Text(
                                    'Role',
                                    style: TextStyle(
                                      color: _selectedRole == 'Visitor' ? Colors.white70 : Colors.black54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                                // Dropdown with padding for label
                                Padding(
                                  padding: EdgeInsets.only(top: 25, bottom: 8),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedRole,
                                      isExpanded: true,
                                      style: TextStyle(
                                        color: _selectedRole == 'Visitor' ? Colors.white : Colors.black,
                                        fontSize: 18, // Increased font size
                                        fontWeight: FontWeight.w500,
                                      ),
                                      dropdownColor: Colors.white,
                                      items: <String>['Visitor', 'Student'].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Center( // Center the dropdown text
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18, // Increased font size
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedRole = newValue!;
                                          _showSchoolField = (_selectedRole == 'Student');
                                        });
                                        FocusScope.of(context).unfocus();
                                      },
                                      selectedItemBuilder: (BuildContext context) {
                                        return <String>['Visitor', 'Student'].map((String value) {
                                          return Center( // Center the selected item text
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(vertical: 4), // Add vertical padding
                                              child: Text(
                                                value,
                                                style: TextStyle(
                                                  color: _selectedRole == 'Visitor' ? Colors.white : Colors.black,
                                                  fontSize: 18, // Increased font size
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList();
                                      },
                                      icon: Padding(
                                        padding: EdgeInsets.only(right: 20),
                                        child: Icon(
                                          Icons.arrow_drop_down,
                                          color: _selectedRole == 'Visitor' ? Colors.white : Colors.black,
                                          size: 28, // Increased icon size
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                          color: Color(0xFFF5E6A8).withOpacity(0.9), // Cream/beige color
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _schoolController,
                          focusNode: _schoolFocusNode,
                          style: TextStyle(color: Colors.black),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          onTap: () {
                            // Explicitly request focus when tapped
                            _schoolFocusNode.requestFocus();
                          },
                          onSubmitted: (value) {
                            // Hide keyboard when done
                            FocusScope.of(context).unfocus();
                            _proceedToNext();
                          },
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
                    
                    // Proceed Button - centered
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Hide keyboard before proceeding
                          FocusScope.of(context).unfocus();
                          _proceedToNext();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFDF8D7), // Updated to FDF8D7 color
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
                    ),
                    
                    Spacer(),
                  ],
                ),
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
    _nameFocusNode.dispose();
    _schoolFocusNode.dispose();
    super.dispose();
  }
}