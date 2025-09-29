import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screen/home_screen.dart';
import 'global.dart';

// Import your QR scanner screen files based on actual structure
import 'screen/mandaya_detail_screen.dart';
import 'screen/mansaka_detail_screen.dart';
import 'screen/kagan_detail_screen.dart';

// Custom input formatter to allow only letters, spaces, hyphens, apostrophes, and periods
class NameInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow only letters (a-z, A-Z), spaces, hyphens, apostrophes, and periods
    // This covers names like "Mary-Jane", "O'Connor", "Jr.", "St. Mary"
    final RegExp regExp = RegExp(r"^[a-zA-Z\s\-'.]*$");
    
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    // Check if the entire new text matches our pattern
    if (regExp.hasMatch(newValue.text)) {
      // Additional validation: prevent multiple consecutive spaces or special chars
      // and ensure it doesn't start with special characters
      if (!newValue.text.contains(RegExp(r'[\s\-''.]{2,}')) &&
          !newValue.text.startsWith(RegExp(r'[\s\-''.]+')) &&
          !newValue.text.endsWith('  ')) {
        return newValue;
      }
    }
    
    // If validation fails, return the old value
    return oldValue;
  }
}

void main() {
  runApp(const MyApp());
}

class GlobalData {
  static dynamic userData;
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
      // Set up proper routing
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/home': (context) {
          // Get arguments passed to the route
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return HomeScreen(userData: args ?? {});
        },
        // QR Scanner content routes - Updated to match your actual file structure
        '/mandaya_detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return MandayaCulturalDetailScreen(contentData: args);
        },
        '/mansaka_detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return MansakaCulturalDetailScreen(contentData: args);
        },
        '/kagan_detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return KaganCulturalDetailScreen(contentData: args);
        },
       },
      debugShowCheckedModeBanner: false,
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _customSchoolController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _customSchoolFocusNode = FocusNode();
  String _selectedRole = 'Visitor';
  String? _selectedSchool;
  bool _showSchoolField = false;
  bool _showCustomSchoolField = false;

  // List of available schools
  final List<String> _schoolOptions = [
    'Aces Polytechnic College',
    'Arriesgado College Foundation, Inc',
    'Assumpta School of Tagum',
    'CARD-MRI Development Institute Inc.',
    'La Filipina National Highschool',
    'Laureta National Highschool',
    'Letran De Davao Inc.',
    'Liceo De Davao',
    'Magdum National Highschool',
    'Max Mirafuentes Academy',
    'NDC Tagum Foundation Inc.',
    'Rizal Memorial Colleges, Inc.',
    'Saint Lorenzo Ruiz Academy',
    'Saint Marys College of Tagum',
    'St. Thomas More School of Law and Business',
    'System Technology Institute',
    'Tagum City College of Science and Technology Foundation Incorporated',
    'Tagum City National Highschool (City High)',
    'Tagum Doctors College, Inc.',
    'Tagum National Trade School (Trade)',
    'UM Tagum College',
    'University of Southeastern Philippines',
    'Others' // Option for schools not in the list
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Prevent automatic resizing when keyboard appears
      resizeToAvoidBottomInset: false,
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
              image: AssetImage('assets/images/login.jpg'),
              fit: BoxFit.cover,
              opacity: 4.0, // 40% visible, 60% transparent
            ),
          ),
          child: Container(
            // Dark overlay for better text visibility
            color: Colors.black.withOpacity(0.5),
            child: SafeArea(
              child: SingleChildScrollView(
                // Ensure the scroll view takes full height when keyboard is hidden
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 
                               MediaQuery.of(context).padding.top - 
                               MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          
                          // Logo/Title Box - centered
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
                          
                          // Responsive spacing - reduced when keyboard is shown
                          SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 40),
                          
                          // Transparent container wrapping Name, Role, and School inputs
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                // Name Input Field with "Name" label in top-left
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.4),
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
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.name,
                                        textInputAction: TextInputAction.next,
                                        textCapitalization: TextCapitalization.words,
                                        inputFormatters: [
                                          NameInputFormatter(), // Custom formatter
                                          LengthLimitingTextInputFormatter(50), // Reasonable limit
                                        ],
                                        onTap: () {
                                          _nameFocusNode.requestFocus();
                                        },
                                        onSubmitted: (value) {
                                          FocusScope.of(context).unfocus();
                                        },
                                        decoration: const InputDecoration(
                                          hintText: '',
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                            left: 20, 
                                            right: 20, 
                                            top: 35,
                                            bottom: 15
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Role Selection Dropdown with "Role" label in top-left
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.4),
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
                                            color: Colors.white70,
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
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            dropdownColor: Colors.white,
                                            items: <String>['Visitor', 'Student'].map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Center(
                                                  child: Text(
                                                    value,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18,
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
                                                // Clear school selection when switching to Visitor
                                                if (!_showSchoolField) {
                                                  _selectedSchool = null;
                                                }
                                              });
                                              FocusScope.of(context).unfocus();
                                            },
                                            selectedItemBuilder: (BuildContext context) {
                                              return <String>['Visitor', 'Student'].map((String value) {
                                                return Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                                    child: Text(
                                                      value,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
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
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // School Selection Dropdown (only for students)
                                if (_showSchoolField) ...[
                                  const SizedBox(height: 20),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.4),
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
                                              color: Colors.white70,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                        // School dropdown with padding for label
                                        Padding(
                                          padding: const EdgeInsets.only(top: 25, bottom: 8),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: _selectedSchool,
                                              hint: const Center(
                                                child: Text(
                                                  'Select your school',
                                                  style: TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              isExpanded: true,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              dropdownColor: Colors.white,
                                              menuMaxHeight: 300,
                                              items: _schoolOptions.map((String school) {
                                                return DropdownMenuItem<String>(
                                                  value: school,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    child: Text(
                                                      school,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  _selectedSchool = newValue;
                                                  _showCustomSchoolField = (newValue == 'Others');
                                                  // Clear custom school field when switching away from Others
                                                  if (!_showCustomSchoolField) {
                                                    _customSchoolController.clear();
                                                  }
                                                });
                                                FocusScope.of(context).unfocus();
                                              },
                                              selectedItemBuilder: (BuildContext context) {
                                                return _schoolOptions.map((String school) {
                                                  return Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                                      child: Text(
                                                        school,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  );
                                                }).toList();
                                              },
                                              icon: const Padding(
                                                padding: EdgeInsets.only(right: 20),
                                                child: Icon(
                                                  Icons.arrow_drop_down,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                
                                // Custom School Input Field (only when "Others" is selected AND role is Student)
                                if (_showSchoolField && _showCustomSchoolField) ...[
                                  const SizedBox(height: 20),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Stack(
                                      children: [
                                        // "Please specify your school" label in top-left corner
                                        const Positioned(
                                          top: 8,
                                          left: 15,
                                          child: Text(
                                            'Please specify your school',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                        // TextField with centered text and top padding
                                        TextField(
                                          controller: _customSchoolController,
                                          focusNode: _customSchoolFocusNode,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.name,
                                          textInputAction: TextInputAction.done,
                                          textCapitalization: TextCapitalization.words,
                                          inputFormatters: [
                                            // Reuse the school input formatter from original code
                                            LengthLimitingTextInputFormatter(100),
                                            // Allow letters, numbers, spaces, and common punctuation for school names
                                            FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9\s\-'.()#&,]")),
                                          ],
                                          onTap: () {
                                            _customSchoolFocusNode.requestFocus();
                                          },
                                          onSubmitted: (value) {
                                            FocusScope.of(context).unfocus();
                                            _proceedToNext();
                                          },
                                          decoration: const InputDecoration(
                                            hintText: 'Enter your school name',
                                            hintStyle: TextStyle(color: Colors.white54),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.only(
                                              left: 20, 
                                              right: 20, 
                                              top: 35,
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
                          
                          // Responsive spacing
                          SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 40),
                          
                          // Proceed Button - centered
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                _proceedToNext();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFDF8D7),
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
                          
                          // Use Flexible Spacer that adapts to available space
                          const Expanded(child: SizedBox()),
                          
                          // Add bottom padding when keyboard is visible
                          SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _proceedToNext() {
    // Trim whitespace and validate inputs
    final String trimmedName = _nameController.text.trim();
    
    if (trimmedName.isEmpty) {
      _showCustomErrorDialog(
        'Name Required',
        'Please enter your name to continue.',
        Icons.person_outline,
      );
      return;
    }
    
    // Additional validation: check if name has at least one letter
    if (!RegExp(r'[a-zA-Z]').hasMatch(trimmedName)) {
      _showCustomErrorDialog(
        'Invalid Name',
        'Please enter a valid name with letters.',
        Icons.person_outline,
      );
      return;
    }
    
    if (_selectedRole == 'Student' && _selectedSchool == null) {
      _showCustomErrorDialog(
        'School Selection Required',
        'Please select your school to continue.',
        Icons.school_outlined,
      );
      return;
    }
    
    if (_selectedRole == 'Student' && _selectedSchool == 'Others' && _customSchoolController.text.trim().isEmpty) {
      _showCustomErrorDialog(
        'Custom School Required',
        'Please enter your school name.',
        Icons.school_outlined,
      );
      return;
    }
    
    // Additional validation for custom school name
    if (_selectedRole == 'Student' && _selectedSchool == 'Others' && !RegExp(r'[a-zA-Z]').hasMatch(_customSchoolController.text.trim())) {
      _showCustomErrorDialog(
        'Invalid School Name',
        'Please enter a valid school name with letters.',
        Icons.school_outlined,
      );
      return;
    }

    // Determine the final school name to save
    String finalSchoolName = '';
    if (_selectedRole == 'Student') {
      if (_selectedSchool == 'Others') {
        finalSchoolName = _customSchoolController.text.trim();
      } else {
        finalSchoolName = _selectedSchool!;
      }
    }

    // Process the data and navigate to next screen
    Map<String, dynamic> userData = {
      'name': trimmedName,
      'role': _selectedRole,
      if (_selectedRole == 'Student') 'school': finalSchoolName,
    };

    // Store user data globally - use consistent global storage
    try {
      GlobalData.userData = userData;
      Global.userData = userData;
    } catch (e) {
      // Handle any potential errors when setting global data
      debugPrint('Error setting global data: $e');
      // Continue with navigation even if global storage fails
    }
    
    // Navigate to home screen using named route with arguments
    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: userData,
    );
  }

  void _showCustomErrorDialog(String title, String message, IconData icon) {
    HapticFeedback.lightImpact();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
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
                      } else if (title.contains('Custom School') || (title.contains('School') && _selectedSchool == 'Others')) {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _customSchoolFocusNode.requestFocus();
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDF8D7),
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
    _customSchoolController.dispose();
    _nameFocusNode.dispose();
    _customSchoolFocusNode.dispose();
    super.dispose();
  }
}