import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _currentIndex == 0 
          ? _buildHomeContent() 
          : _currentIndex == 1 
            ? _buildTribesContent()
            : _buildTranslationContent(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildQRScannerSection(),
                SizedBox(height: 20),
                _buildAboutSection(),
                SizedBox(height: 20),
                _buildTribeCard(
                  title: "ATA-MANOBO",
                  description: "The Ata-Manobo people are known for their rich cultural heritage and traditional practices. They have maintained their ancestral ways while adapting to modern times.",
                  imagePath: "assets/images/atamanon.jpg", // Replace with your image
                ),
                SizedBox(height: 16),
                _buildTribeCard(
                  title: "MANDAYA",
                  description: "The Mandaya tribe is renowned for their intricate weaving techniques and colorful traditional clothing. Their cultural practices have been passed down through generations.",
                  imagePath: "assets/images/mandaya.jpg", // Replace with your image
                ),
                SizedBox(height: 16),
                _buildTribeCard(
                  title: "MANSAKA",
                  description: "The Mansaka people are skilled in various traditional crafts and have a deep connection with nature. Their customs reflect their harmonious relationship with the environment.",
                  imagePath: "assets/images/mansaka.jpg", // Replace with your image
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[800],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Home',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'HUNI SA TRIBU',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRScannerSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: Column(
        children: [
          Text(
            'Scan QR Code to',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Text(
            'Start your AR Experience',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.qr_code_scanner,
              size: 40,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              _openQRScanner();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'SCANNER',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ABOUT THE TRIBES',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Discover the rich cultural heritage of the three indigenous tribes of Davao Region. Each tribe has its unique traditions, customs, and stories that have been preserved for generations.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTribeCard({
    required String title,
    required String description,
    required String imagePath,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              image: DecorationImage(
                // Replace with your actual images
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
                // Fallback color if image doesn't load
                onError: (exception, stackTrace) {},
              ),
              // Fallback background color
              color: Colors.grey[600],
            ),
            // Fallback content if image fails
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    _learnMore(title);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'LEARN MORE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTribesContent() {
    return Center(
      child: Text(
        'Tribes Screen\n(To be implemented)',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildTranslationContent() {
    return Center(
      child: Text(
        'Translation Screen\n(To be implemented)',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          top: BorderSide(color: Colors.grey[700]!, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey[500],
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Tribes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.translate),
            label: 'Translate',
          ),
        ],
      ),
    );
  }

  void _openQRScanner() {
    // TODO: Implement QR scanner with camera
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'QR Scanner',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'QR Scanner will be implemented later with camera access.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.amber),
              ),
            ),
          ],
        );
      },
    );
  }

  void _learnMore(String tribeName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            tribeName,
            style: TextStyle(color: Colors.amber),
          ),
          content: Text(
            'More detailed information about $tribeName will be available in the Tribes section.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.amber),
              ),
            ),
          ],
        );
      },
    );
  }
}