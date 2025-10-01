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
    final RegExp regExp = RegExp(r"^[a-zA-Z\s\-'.]*$");
    
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    if (regExp.hasMatch(newValue.text)) {
      if (!newValue.text.contains(RegExp(r'[\s\-''.]{2,}')) &&
          !newValue.text.startsWith(RegExp(r'[\s\-''.]+')) &&
          !newValue.text.endsWith('  ')) {
        return newValue;
      }
    }
    
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
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return HomeScreen(userData: args ?? {});
        },
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
    'STI College Tagum',
    'Tagum City College of Science and Technology Foundation Incorporated',
    'Tagum City National Highschool (City High)',
    'Tagum Doctors College, Inc.',
    'Tagum National Trade School (Trade)',
    'UM Tagum College',
    'University of Southeastern Philippines',
    'Others'
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/login.jpg'),
              fit: BoxFit.cover,
              opacity: 4.0,
            ),
          ),
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight - 
                               MediaQuery.of(context).padding.top - 
                               MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.02,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: isKeyboardVisible ? screenHeight * 0.02 : screenHeight * 0.05),
                          
                          // Logo/Title Box - centered and responsive
                          Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.08,
                                vertical: screenHeight * 0.018,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'HUNI SA TRIBU',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.06,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: isKeyboardVisible ? screenHeight * 0.02 : screenHeight * 0.04),
                          
                          // Welcome Text - responsive
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Welcome!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.07,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: isKeyboardVisible ? screenHeight * 0.02 : screenHeight * 0.04),
                          
                          // Transparent container with form inputs
                          Container(
                            padding: EdgeInsets.all(screenWidth * 0.05),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                // Name Input Field
                                _buildInputField(
                                  label: 'Name',
                                  controller: _nameController,
                                  focusNode: _nameFocusNode,
                                  hintText: '',
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                  inputFormatters: [
                                    NameInputFormatter(),
                                    LengthLimitingTextInputFormatter(50),
                                  ],
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  onSubmitted: (value) {
                                    FocusScope.of(context).unfocus();
                                  },
                                ),
                                
                                SizedBox(height: screenHeight * 0.02),
                                
                                // Role Selection Dropdown
                                _buildRoleDropdown(screenWidth, screenHeight),
                                
                                // School Selection Dropdown
                                if (_showSchoolField) ...[
                                  SizedBox(height: screenHeight * 0.02),
                                  _buildSchoolDropdown(screenWidth, screenHeight),
                                ],
                                
                                // Custom School Input Field
                                if (_showSchoolField && _showCustomSchoolField) ...[
                                  SizedBox(height: screenHeight * 0.02),
                                  _buildInputField(
                                    label: 'Please specify your school',
                                    controller: _customSchoolController,
                                    focusNode: _customSchoolFocusNode,
                                    hintText: 'Enter your school name',
                                    screenWidth: screenWidth,
                                    screenHeight: screenHeight,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(100),
                                      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9\s\-'.()#&,]")),
                                    ],
                                    textInputAction: TextInputAction.done,
                                    textCapitalization: TextCapitalization.words,
                                    onSubmitted: (value) {
                                      FocusScope.of(context).unfocus();
                                      _proceedToNext();
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          SizedBox(height: isKeyboardVisible ? screenHeight * 0.02 : screenHeight * 0.04),
                          
                          // Proceed Button - responsive
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                _proceedToNext();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFDF8D7),
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.1,
                                  vertical: screenHeight * 0.018,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'PROCEED',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          
                          const Expanded(child: SizedBox()),
                          
                          SizedBox(height: isKeyboardVisible ? screenHeight * 0.02 : 0),
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required double screenWidth,
    required double screenHeight,
    required List<TextInputFormatter> inputFormatters,
    required TextInputAction textInputAction,
    required TextCapitalization textCapitalization,
    required Function(String) onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.01,
            left: screenWidth * 0.04,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          TextField(
            controller: controller,
            focusNode: focusNode,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.name,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
            onTap: () {
              focusNode.requestFocus();
            },
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
                top: screenHeight * 0.04,
                bottom: screenHeight * 0.018,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown(double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.01,
            left: screenWidth * 0.04,
            child: Text(
              'Role',
              style: TextStyle(
                color: Colors.white70,
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.03, bottom: screenHeight * 0.01),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRole,
                isExpanded: true,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w500,
                ),
                dropdownColor: Colors.white,
                items: <String>['Visitor', 'Student'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Center(
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.045,
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
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                        child: Text(
                          value,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList();
                },
                icon: Padding(
                  padding: EdgeInsets.only(right: screenWidth * 0.05),
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                    size: screenWidth * 0.07,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolDropdown(double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.01,
            left: screenWidth * 0.04,
            child: Text(
              'What School?',
              style: TextStyle(
                color: Colors.white70,
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.03, bottom: screenHeight * 0.01),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSchool,
                hint: Center(
                  child: Text(
                    'Select your school',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                isExpanded: true,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w500,
                ),
                dropdownColor: Colors.white,
                menuMaxHeight: screenHeight * 0.4,
                items: _schoolOptions.map((String school) {
                  return DropdownMenuItem<String>(
                    value: school,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                      child: Text(
                        school,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.035,
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
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                        child: Text(
                          school,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    );
                  }).toList();
                },
                icon: Padding(
                  padding: EdgeInsets.only(right: screenWidth * 0.05),
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                    size: screenWidth * 0.07,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToNext() {
    final String trimmedName = _nameController.text.trim();
    
    if (trimmedName.isEmpty) {
      _showCustomErrorDialog(
        'Name Required',
        'Please enter your name to continue.',
        Icons.person_outline,
      );
      return;
    }
    
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
    
    if (_selectedRole == 'Student' && _selectedSchool == 'Others' && !RegExp(r'[a-zA-Z]').hasMatch(_customSchoolController.text.trim())) {
      _showCustomErrorDialog(
        'Invalid School Name',
        'Please enter a valid school name with letters.',
        Icons.school_outlined,
      );
      return;
    }

    String finalSchoolName = '';
    if (_selectedRole == 'Student') {
      if (_selectedSchool == 'Others') {
        finalSchoolName = _customSchoolController.text.trim();
      } else {
        finalSchoolName = _selectedSchool!;
      }
    }

    Map<String, dynamic> userData = {
      'name': trimmedName,
      'role': _selectedRole,
      if (_selectedRole == 'Student') 'school': finalSchoolName,
    };

    try {
      GlobalData.userData = userData;
      Global.userData = userData;
    } catch (e) {
      debugPrint('Error setting global data: $e');
    }
    
    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: userData,
    );
  }

  void _showCustomErrorDialog(String title, String message, IconData icon) {
    HapticFeedback.lightImpact();
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            padding: EdgeInsets.all(screenWidth * 0.06),
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
                Container(
                  width: screenWidth * 0.18,
                  height: screenWidth * 0.18,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(screenWidth * 0.09),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.red,
                    size: screenWidth * 0.09,
                  ),
                ),
                
                SizedBox(height: screenHeight * 0.025),
                
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: screenHeight * 0.015),
                
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w300,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: screenHeight * 0.03),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                      
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
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'GOT IT',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
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