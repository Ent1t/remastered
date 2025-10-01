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
  void initState() {
    super.initState();
    
    // Add listeners to handle keyboard interactions
    _nameFocusNode.addListener(() {
      if (_nameFocusNode.hasFocus) {
        setState(() {});
      }
    });
    
    _customSchoolFocusNode.addListener(() {
      if (_customSchoolFocusNode.hasFocus) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;
    
    // Calculate available height
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final availableHeight = screenHeight - topPadding - bottomPadding - keyboardHeight;
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                        maxWidth: screenWidth,
                      ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: (screenWidth * 0.05).clamp(16.0, 40.0),
                        vertical: (screenHeight * 0.02).clamp(12.0, 24.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: isKeyboardVisible 
                              ? (screenHeight * 0.02).clamp(8.0, 16.0)
                              : (screenHeight * 0.05).clamp(20.0, 40.0)
                          ),
                          
                          // Logo/Title Box - centered and responsive
                          Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: screenWidth * 0.85,
                                minHeight: (screenHeight * 0.06).clamp(40.0, 60.0),
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: (screenWidth * 0.08).clamp(20.0, 50.0),
                                  vertical: (screenHeight * 0.018).clamp(12.0, 20.0),
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'HUNI SA TRIBU',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: (screenWidth * 0.06).clamp(18.0, 30.0),
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(
                            height: isKeyboardVisible 
                              ? (screenHeight * 0.02).clamp(8.0, 16.0)
                              : (screenHeight * 0.04).clamp(16.0, 32.0)
                          ),
                          
                          // Welcome Text - responsive
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Welcome!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: (screenWidth * 0.07).clamp(20.0, 32.0),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(
                            height: isKeyboardVisible 
                              ? (screenHeight * 0.02).clamp(8.0, 16.0)
                              : (screenHeight * 0.04).clamp(16.0, 32.0)
                          ),
                          
                          // Transparent container with form inputs
                          Container(
                            constraints: BoxConstraints(
                              minHeight: (availableHeight * 0.3).clamp(200.0, 400.0),
                              maxWidth: screenWidth,
                            ),
                            padding: EdgeInsets.all((screenWidth * 0.05).clamp(16.0, 30.0)),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
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
                                
                                SizedBox(height: (screenHeight * 0.02).clamp(12.0, 20.0)),
                                
                                // Role Selection Dropdown
                                _buildRoleDropdown(screenWidth, screenHeight),
                                
                                // School Selection Dropdown
                                if (_showSchoolField) ...[
                                  SizedBox(height: (screenHeight * 0.02).clamp(12.0, 20.0)),
                                  _buildSchoolDropdown(screenWidth, screenHeight),
                                ],
                                
                                // Custom School Input Field
                                if (_showSchoolField && _showCustomSchoolField) ...[
                                  SizedBox(height: (screenHeight * 0.02).clamp(12.0, 20.0)),
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
                          
                          SizedBox(
                            height: isKeyboardVisible 
                              ? (screenHeight * 0.02).clamp(8.0, 16.0)
                              : (screenHeight * 0.04).clamp(16.0, 32.0)
                          ),
                          
                          // Proceed Button - responsive
                          Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: (screenWidth * 0.4).clamp(120.0, 200.0),
                                maxWidth: (screenWidth * 0.7).clamp(200.0, 300.0),
                                minHeight: (screenHeight * 0.06).clamp(40.0, 60.0),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  _proceedToNext();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFDF8D7),
                                  foregroundColor: Colors.black,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: (screenWidth * 0.1).clamp(24.0, 48.0),
                                    vertical: (screenHeight * 0.018).clamp(12.0, 20.0),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'PROCEED',
                                    style: TextStyle(
                                      fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const Expanded(child: SizedBox()),
                          
                          SizedBox(
                            height: isKeyboardVisible 
                              ? (screenHeight * 0.02).clamp(8.0, 16.0)
                              : 0
                          ),
                        ],
                      ),
                    ),
                      ),
                    ),
                  );
                },
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
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: (screenHeight * 0.08).clamp(50.0, 80.0),
        maxWidth: screenWidth,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Positioned(
              top: (screenHeight * 0.01).clamp(6.0, 12.0),
              left: (screenWidth * 0.04).clamp(12.0, 20.0),
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: (screenWidth * 0.03).clamp(10.0, 14.0),
                  fontWeight: FontWeight.w300,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            TextField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(
                color: Colors.white,
                fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
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
              onTapOutside: (event) {
                // Dismiss keyboard when tapping outside
                FocusScope.of(context).unfocus();
              },
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.white54,
                  fontSize: (screenWidth * 0.035).clamp(12.0, 16.0),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(
                  left: (screenWidth * 0.05).clamp(16.0, 30.0),
                  right: (screenWidth * 0.05).clamp(16.0, 30.0),
                  top: (screenHeight * 0.04).clamp(24.0, 36.0),
                  bottom: (screenHeight * 0.018).clamp(12.0, 20.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleDropdown(double screenWidth, double screenHeight) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: (screenHeight * 0.08).clamp(50.0, 80.0),
        maxWidth: screenWidth,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Positioned(
              top: (screenHeight * 0.01).clamp(6.0, 12.0),
              left: (screenWidth * 0.04).clamp(12.0, 20.0),
              child: Text(
                'Role',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: (screenWidth * 0.03).clamp(10.0, 14.0),
                  fontWeight: FontWeight.w300,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: (screenHeight * 0.03).clamp(20.0, 30.0),
                bottom: (screenHeight * 0.01).clamp(6.0, 12.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRole,
                  isExpanded: true,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (screenWidth * 0.045).clamp(14.0, 18.0),
                    fontWeight: FontWeight.w500,
                  ),
                  dropdownColor: Colors.white,
                  items: <String>['Visitor', 'Student'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: (screenWidth * 0.045).clamp(14.0, 18.0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    // Dismiss keyboard first
                    FocusScope.of(context).unfocus();
                    
                    // Then update state
                    setState(() {
                      _selectedRole = newValue!;
                      _showSchoolField = (_selectedRole == 'Student');
                      if (!_showSchoolField) {
                        _selectedSchool = null;
                        _showCustomSchoolField = false;
                        _customSchoolController.clear();
                      }
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return <String>['Visitor', 'Student'].map((String value) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: (screenHeight * 0.005).clamp(4.0, 8.0)
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: (screenWidth * 0.045).clamp(14.0, 18.0),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList();
                  },
                  icon: Padding(
                    padding: EdgeInsets.only(right: (screenWidth * 0.05).clamp(12.0, 20.0)),
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                      size: (screenWidth * 0.07).clamp(24.0, 32.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolDropdown(double screenWidth, double screenHeight) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: (screenHeight * 0.08).clamp(50.0, 80.0),
        maxWidth: screenWidth,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Positioned(
              top: (screenHeight * 0.01).clamp(6.0, 12.0),
              left: (screenWidth * 0.04).clamp(12.0, 20.0),
              child: Text(
                'What School?',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: (screenWidth * 0.03).clamp(10.0, 14.0),
                  fontWeight: FontWeight.w300,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: (screenHeight * 0.03).clamp(20.0, 30.0),
                bottom: (screenHeight * 0.01).clamp(6.0, 12.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSchool,
                  hint: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Select your school',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: (screenWidth * 0.04).clamp(12.0, 16.0),
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  isExpanded: true,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (screenWidth * 0.04).clamp(12.0, 16.0),
                    fontWeight: FontWeight.w500,
                  ),
                  dropdownColor: Colors.white,
                  menuMaxHeight: (screenHeight * 0.4).clamp(200.0, 350.0),
                  items: _schoolOptions.map((String school) {
                    return DropdownMenuItem<String>(
                      value: school,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: (screenWidth * 0.02).clamp(6.0, 12.0)
                        ),
                        child: Text(
                          school,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: (screenWidth * 0.035).clamp(11.0, 14.0),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    // Dismiss keyboard first
                    FocusScope.of(context).unfocus();
                    
                    // Then update state
                    setState(() {
                      _selectedSchool = newValue;
                      _showCustomSchoolField = (newValue == 'Others');
                      if (!_showCustomSchoolField) {
                        _customSchoolController.clear();
                      } else {
                        // Auto-focus custom school field after dropdown closes
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (mounted) {
                            _customSchoolFocusNode.requestFocus();
                          }
                        });
                      }
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return _schoolOptions.map((String school) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: (screenHeight * 0.005).clamp(4.0, 8.0),
                            horizontal: (screenWidth * 0.02).clamp(6.0, 12.0),
                          ),
                          child: Text(
                            school,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: (screenWidth * 0.04).clamp(12.0, 16.0),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  icon: Padding(
                    padding: EdgeInsets.only(right: (screenWidth * 0.05).clamp(12.0, 20.0)),
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                      size: (screenWidth * 0.07).clamp(24.0, 32.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: (screenWidth * 0.9).clamp(280.0, 400.0),
              maxHeight: (screenHeight * 0.5).clamp(250.0, 400.0),
            ),
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: (screenWidth * 0.05).clamp(12.0, 24.0)
              ),
              padding: EdgeInsets.all((screenWidth * 0.06).clamp(16.0, 32.0)),
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
                    width: (screenWidth * 0.18).clamp(50.0, 80.0),
                    height: (screenWidth * 0.18).clamp(50.0, 80.0),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular((screenWidth * 0.09).clamp(25.0, 40.0)),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.red,
                      size: (screenWidth * 0.09).clamp(28.0, 40.0),
                    ),
                  ),
                  
                  SizedBox(height: (screenHeight * 0.025).clamp(12.0, 20.0)),
                  
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: (screenWidth * 0.05).clamp(16.0, 22.0),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: (screenHeight * 0.015).clamp(8.0, 16.0)),
                  
                  Flexible(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: (screenWidth * 0.04).clamp(12.0, 16.0),
                        fontWeight: FontWeight.w300,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  SizedBox(height: (screenHeight * 0.03).clamp(16.0, 24.0)),
                  
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (screenHeight * 0.06).clamp(40.0, 60.0),
                      maxWidth: double.infinity,
                    ),
                    child: SizedBox(
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
                          padding: EdgeInsets.symmetric(
                            vertical: (screenHeight * 0.018).clamp(12.0, 18.0)
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'GOT IT',
                            style: TextStyle(
                              fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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