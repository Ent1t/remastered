import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screen/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Huni sa Tribu',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Regular',
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

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
          decoration: const BoxDecoration(
            // Replace with your background image
            image: DecorationImage(
              image: AssetImage('assets/images/login.jpg'), // Add your image here
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
                    const SizedBox(height: 40),
                    
                    // Logo/Title Box - centered (REMOVED name and role display)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
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
                    
                    const SizedBox(height: 30),
                    
                    // Welcome Text - aligned to the left
                    const Align(
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
                    
                    const SizedBox(height: 40),
                    
                    // Transparent container wrapping Name, Role, and School inputs
                    Container(
                      padding: const EdgeInsets.all(20),
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
                                const Positioned(
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
                                  style: const TextStyle(
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
                                  decoration: const InputDecoration(
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
                          
                          const SizedBox(height: 20),
                          
                          // Role Selection Dropdown with "Role" label in top-left - FIXED COLOR
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.4), // SAME COLOR AS NAME FIELD
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                // "Role" label in top-left corner
                                const Positioned(
                                  top: 8,
                                  left: 15,
                                  child: Text(
                                    'Role',
                                    style: TextStyle(
                                      color: Colors.white70, // CONSISTENT COLOR
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                                // Dropdown with padding for label
                                Padding(
                                  padding: const EdgeInsets.only(top: 25, bottom: 8),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedRole,
                                      isExpanded: true,
                                      style: const TextStyle(
                                        color: Colors.white, // CONSISTENT WHITE TEXT
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
                                              style: const TextStyle(
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
                                              padding: const EdgeInsets.symmetric(vertical: 4), // Add vertical padding
                                              child: Text(
                                                value,
                                                style: const TextStyle(
                                                  color: Colors.white, // CONSISTENT WHITE TEXT
                                                  fontSize: 18, // Increased font size
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList();
                                      },
                                      icon: const Padding(
                                        padding: EdgeInsets.only(right: 20),
                                        child: Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.white, // CONSISTENT WHITE ICON
                                          size: 28, // Increased icon size
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // School Input Field (only for students) - MOVED INSIDE CONTAINER AND FIXED STYLING
                          if (_showSchoolField) ...[
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.4), // SAME COLOR AS OTHER FIELDS
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Stack(
                                children: [
                                  // "What School?" label in top-left corner
                                  const Positioned(
                                    top: 8,
                                    left: 15,
                                    child: Text(
                                      'What School?',
                                      style: TextStyle(
                                        color: Colors.white70, // CONSISTENT COLOR
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                  // TextField with centered text and top padding
                                  TextField(
                                    controller: _schoolController,
                                    focusNode: _schoolFocusNode,
                                    style: const TextStyle(
                                      color: Colors.white, // CONSISTENT WHITE TEXT
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center, // CENTER THE INPUT TEXT
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
                                    decoration: const InputDecoration(
                                      hintText: 'Ex: STI College Tagum',
                                      hintStyle: TextStyle(color: Colors.white54), // CONSISTENT HINT COLOR
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
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Proceed Button - centered
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Hide keyboard before proceeding
                          FocusScope.of(context).unfocus();
                          _proceedToNext();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFDF8D7), // Updated to FDF8D7 color
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'PROCEED',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    const Spacer(),
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
      _showCustomErrorDialog(
        'Name Required',
        'Please enter your name to continue.',
        Icons.person_outline,
      );
      return;
    }
    
    if (_selectedRole == 'Student' && _schoolController.text.trim().isEmpty) {
      _showCustomErrorDialog(
        'School Information Required',
        'Please enter your school name to continue.',
        Icons.school_outlined,
      );
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

  void _showCustomErrorDialog(String title, String message, IconData icon) {
    HapticFeedback.lightImpact(); // Add haptic feedback for better UX
    
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              // Dark background with gradient similar to your app theme
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2a2a2a),
                  Color(0xFF1a1a1a),
                  Color(0xFF0d0d0d),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.red.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Icon with animated container
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.red,
                    size: 35,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Error Title
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                // Error Message
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                // Custom OK Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                      
                      // Auto-focus the appropriate field after closing dialog
                      if (title.contains('Name')) {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _nameFocusNode.requestFocus();
                        });
                      } else if (title.contains('School')) {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _schoolFocusNode.requestFocus();
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDF8D7), // Same as your proceed button
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'GOT IT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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