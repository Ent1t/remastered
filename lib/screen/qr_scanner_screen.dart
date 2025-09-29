import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../global.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  
  String? barcodeResult;
  bool isScanning = true;
  String? errorMessage;
  bool torchEnabled = false;
  bool isProcessing = false;
  String? lastScannedCode;
  DateTime? lastScanTime;

  @override
  void initState() {
    super.initState();
    cameraController.start();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              torchEnabled ? Icons.flash_on : Icons.flash_off,
              color: torchEnabled ? Colors.yellow : Colors.grey,
            ),
            onPressed: () async {
              try {
                await cameraController.toggleTorch();
                setState(() {
                  torchEnabled = !torchEnabled;
                });
              } catch (e) {
                print('Error toggling torch: $e');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_front),
            onPressed: () async {
              try {
                await cameraController.switchCamera();
              } catch (e) {
                print('Error switching camera: $e');
              }
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          
          return Stack(
            children: [
              Column(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxHeight: availableHeight * 0.7,
                      ),
                      child: Stack(
                        children: [
                          ClipRect(
                            child: OverflowBox(
                              alignment: Alignment.center,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: screenWidth,
                                  height: screenWidth,
                                  child: MobileScanner(
                                    controller: cameraController,
                                    onDetect: (capture) {
                                      // CRITICAL: Check all guards at the very start
                                      if (!isScanning || isProcessing) return;
                                      
                                      final List<Barcode> barcodes = capture.barcodes;
                                      if (barcodes.isEmpty) return;
                                      
                                      final barcode = barcodes.first;
                                      final scannedCode = barcode.rawValue ?? 'No data';
                                      
                                      // Check if this is the same code scanned recently (within 3 seconds)
                                      final now = DateTime.now();
                                      if (lastScannedCode == scannedCode && 
                                          lastScanTime != null && 
                                          now.difference(lastScanTime!) < const Duration(seconds: 3)) {
                                        print('Duplicate scan ignored: $scannedCode');
                                        return;
                                      }
                                      
                                      // Immediately set processing flag and update last scan info
                                      // This prevents race conditions
                                      setState(() {
                                        isProcessing = true;
                                        isScanning = false;
                                        lastScannedCode = scannedCode;
                                        lastScanTime = now;
                                        barcodeResult = scannedCode;
                                        errorMessage = null;
                                      });
                                      
                                      // Process the QR code
                                      _handleQRCodeScan(scannedCode);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          if (isScanning) _buildScanningOverlay(),
                        ],
                      ),
                    ),
                  ),
                  
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: availableHeight * 0.3,
                      minHeight: 120,
                    ),
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (barcodeResult != null) ...[
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'QR Code Scanned Successfully!',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _resetScanner,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Scan Another'),
                              ),
                            ),
                          ] else if (errorMessage != null) ...[
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ] else ...[
                            const Icon(
                              Icons.qr_code_scanner,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Point your camera at a QR code',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Make sure the QR code is well-lit and centered',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // Loading overlay
              if (isProcessing)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Processing QR Code...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Container(
      decoration: const ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderRadius: 12,
          borderLength: 30,
          borderWidth: 8,
          cutOutSize: 220,
        ),
      ),
    );
  }

  Future<void> _handleQRCodeScan(String result) async {
    try {
      // Handle entrance QR code for attendance
      if (result.toLowerCase() == "entrance") {
        try {
          // Visit endpoint
          http.Response response = await http.post(
            Uri.parse("${Config.baseUrl}visit/"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': Global.userData["name"],
              'school': Global.userData["school"],
            })
          );

          if (!mounted) return;
          
          setState(() {
            isProcessing = false;
          });

          if (response.statusCode == 409) {
            if (!mounted) return;
            _showErrorDialog('You have already visited today!');
            return;
          }

          if (response.statusCode >= 400) {
            if (!mounted) return;
            _showErrorDialog(response.body);
            return;
          }

          // Success - show dialog
          if (!mounted) return;
          _showSuccessDialog('Thank you for visiting!');
          return;
        } catch (e) {
          if (!mounted) return;
          setState(() {
            isProcessing = false;
          });
          _showErrorDialog('Failed to connect: $e');
          return;
        }
      }

      // Handle regular QR codes - Navigate to content screen
      print('=== SENDING REQUEST ===');
      print('URL: ${Config.baseUrl}content/?id=$result');
      
      // Your API uses GET with id parameter
      http.Response response = await http.get(
        Uri.parse("${Config.baseUrl}content/?id=$result"),
        headers: {'Content-Type': 'application/json'},
      );

      // Log the response for debugging
      print('=== QR SCAN RESPONSE ===');
      print('Response Status: ${response.statusCode}');
      print('Response Body Length: ${response.body.length}');
      print('Response Body: "${response.body}"');
      print('Response Headers: ${response.headers}');

      if (!mounted) return;
      
      setState(() {
        isProcessing = false;
      });

      // Check status code first
      if (response.statusCode >= 400) {
        if (!mounted) return;
        print('Error: Status code ${response.statusCode}');
        _showErrorDialog('Content not found (${response.statusCode})');
        return;
      }

      // Check if response body is empty or just whitespace
      if (response.body.trim().isEmpty) {
        if (!mounted) return;
        print('Error: Empty or whitespace-only response body');
        _showErrorDialog('Server returned empty response.\n\nThe QR code "$result" may not exist in the database.');
        return;
      }

      // Try to parse response
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
        print('Parsed Response Keys: ${responseData.keys}');
        print('Full Parsed Response: $responseData');
      } catch (e) {
        if (!mounted) return;
        print('Error parsing JSON: $e');
        print('Raw response that failed: "${response.body}"');
        _showErrorDialog('Invalid JSON from server.');
        return;
      }

      // Check for error in response
      if (responseData['error'] != null) {
        if (!mounted) return;
        print('API returned error: ${responseData['error']}');
        _showErrorDialog(responseData['error']);
        return;
      }

      // Check if data exists in response
      if (responseData['data'] == null) {
        if (!mounted) return;
        print('Error: No data field found');
        print('Available keys: ${responseData.keys.toList()}');
        _showErrorDialog('No content data in response.');
        return;
      }

      // Get the content data
      Map<String, dynamic> contentData = responseData['data'];
      
      // Build full file URL
      if (contentData['file'] != null && contentData['file'].toString().isNotEmpty) {
        String fileName = contentData['file'];
        // If file is just a filename, prepend the base URL
        if (!fileName.startsWith('http')) {
          contentData['file'] = 'https://huni-cms.ionvop.com/uploads/$fileName';
        }
      }

      print('Content Data to display: $contentData');
      print('Navigating to content screen...');
      
      if (!mounted) return;
      
      // Navigate to content screen with the data
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContentDisplayScreen(
            contentData: contentData,
          ),
        ),
      );
      
      // Reset scanner when returning from content screen
      if (mounted) {
        print('Returned from content screen, resetting scanner');
        _resetScanner();
      }

    } catch (e, stackTrace) {
      if (!mounted) return;
      print('=== EXCEPTION CAUGHT ===');
      print('Exception: $e');
      print('StackTrace: $stackTrace');
      setState(() {
        isProcessing = false;
      });
      _showErrorDialog('Failed to process QR code:\n\n$e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetScanner();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetScanner();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetScanner() {
    setState(() {
      barcodeResult = null;
      isScanning = true;
      isProcessing = false;
      errorMessage = null;
    });
    
    // Clear last scanned code after a delay to allow rescanning
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          lastScannedCode = null;
          lastScanTime = null;
        });
      }
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

// Content Display Screen
class ContentDisplayScreen extends StatelessWidget {
  final Map<String, dynamic> contentData;

  const ContentDisplayScreen({
    super.key,
    required this.contentData,
  });

  @override
  Widget build(BuildContext context) {
    print('=== CONTENT DISPLAY SCREEN ===');
    print('Received data: $contentData');
    
    final title = contentData['title']?.toString() ?? 'Untitled';
    final category = contentData['category']?.toString() ?? '';
    final tribe = contentData['tribe']?.toString() ?? '';
    final description = contentData['description']?.toString() ?? 'No description available';
    final fileUrl = contentData['file']?.toString() ?? '';
    final id = contentData['id']?.toString() ?? '';

    print('Title: $title');
    print('Category: $category');
    print('Tribe: $tribe');
    print('Description: $description');
    print('File URL: $fileUrl');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card with Title
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (category.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Image/File Display (if available)
            if (fileUrl.isNotEmpty) ...[
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Image.network(
                      fileUrl,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Image load error: $error');
                        return Container(
                          height: 250,
                          color: Colors.grey[300],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Image not available', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          height: 250,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Tribe Information
            if (tribe.isNotEmpty)
              _buildInfoCard(
                context,
                'Tribe',
                tribe,
                Icons.people,
              ),
            
            // Category Information
            if (category.isNotEmpty)
              _buildInfoCard(
                context,
                'Category',
                category,
                Icons.category,
              ),
            
            // Description
            if (description.isNotEmpty && description != 'No description available')
              _buildInfoCard(
                context,
                'Description',
                description,
                Icons.description,
              ),
            
            // ID (optional - you might want to hide this)
            if (id.isNotEmpty)
              _buildInfoCard(
                context,
                'ID',
                id,
                Icons.tag,
              ),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      print('Scan Another button pressed');
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan Another'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      print('Go Home button pressed');
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Go Home'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatKey(String key) {
    // Convert camelCase or snake_case to Title Case
    return key
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .replaceAll('_', ' ')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}

// Custom overlay shape for QR scanner
class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final cutOutWidth = cutOutSize < width ? cutOutSize : width - borderWidth * 2;
    final cutOutHeight = cutOutSize < height ? cutOutSize : height - borderWidth * 2;

    final backgroundPath = Path()
      ..addRect(rect)
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: cutOutWidth,
            height: cutOutHeight,
          ),
          Radius.circular(borderRadius),
        ),
      )
      ..fillType = PathFillType.evenOdd;
    
    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(backgroundPath, backgroundPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = Path()
      ..moveTo(rect.center.dx - cutOutWidth / 2, rect.center.dy - cutOutHeight / 2)
      ..lineTo(rect.center.dx - cutOutWidth / 2 + borderLength, rect.center.dy - cutOutHeight / 2)
      ..moveTo(rect.center.dx - cutOutWidth / 2, rect.center.dy - cutOutHeight / 2)
      ..lineTo(rect.center.dx - cutOutWidth / 2, rect.center.dy - cutOutHeight / 2 + borderLength)
      
      ..moveTo(rect.center.dx + cutOutWidth / 2, rect.center.dy - cutOutHeight / 2)
      ..lineTo(rect.center.dx + cutOutWidth / 2 - borderLength, rect.center.dy - cutOutHeight / 2)
      ..moveTo(rect.center.dx + cutOutWidth / 2, rect.center.dy - cutOutHeight / 2)
      ..lineTo(rect.center.dx + cutOutWidth / 2, rect.center.dy - cutOutHeight / 2 + borderLength)
      
      ..moveTo(rect.center.dx - cutOutWidth / 2, rect.center.dy + cutOutHeight / 2)
      ..lineTo(rect.center.dx - cutOutWidth / 2 + borderLength, rect.center.dy + cutOutHeight / 2)
      ..moveTo(rect.center.dx - cutOutWidth / 2, rect.center.dy + cutOutHeight / 2)
      ..lineTo(rect.center.dx - cutOutWidth / 2, rect.center.dy + cutOutHeight / 2 - borderLength)
      
      ..moveTo(rect.center.dx + cutOutWidth / 2, rect.center.dy + cutOutHeight / 2)
      ..lineTo(rect.center.dx + cutOutWidth / 2 - borderLength, rect.center.dy + cutOutHeight / 2)
      ..moveTo(rect.center.dx + cutOutWidth / 2, rect.center.dy + cutOutHeight / 2)
      ..lineTo(rect.center.dx + cutOutWidth / 2, rect.center.dy + cutOutHeight / 2 - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}