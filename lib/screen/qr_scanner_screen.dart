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
    detectionSpeed: DetectionSpeed.normal, // Changed from noDuplicates to normal
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  
  String? barcodeResult;
  bool isScanning = true;
  String? errorMessage;
  bool torchEnabled = false;
  String? lastScannedCode; // Track last scanned code
  DateTime? lastScanTime; // Track last scan time
  bool hasScannedAttendance = false; // Track if user has already scanned attendance

  @override
  void initState() {
    super.initState();
    // Start the scanner when the screen loads
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
          // Toggle flashlight
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
          // Switch camera
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
          // Calculate available height
          final appBarHeight = AppBar().preferredSize.height;
          final statusBarHeight = MediaQuery.of(context).padding.top;
          final bottomPadding = MediaQuery.of(context).padding.bottom;
          final availableHeight = constraints.maxHeight;
          
          return Column(
            children: <Widget>[
              // Camera preview section - FIXED HEIGHT
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: availableHeight * 0.7, // Max 70% of screen
                  ),
                  child: Stack(
                    children: [
                      // Camera preview
                      ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: screenWidth,
                              height: screenWidth, // Square aspect ratio
                              child: MobileScanner(
                                controller: cameraController,
                                onDetect: (capture) {
                                  if (!isScanning) return;
                                  
                                  final List<Barcode> barcodes = capture.barcodes;
                                  if (barcodes.isNotEmpty) {
                                    final barcode = barcodes.first;
                                    final scannedCode = barcode.rawValue;
                                    
                                    // Allow scanning if it's been more than 1 second since last scan
                                    // This prevents multiple rapid scans while allowing intentional re-scans
                                    final now = DateTime.now();
                                    if (lastScanTime != null && 
                                        scannedCode == lastScannedCode &&
                                        now.difference(lastScanTime!).inMilliseconds < 1000) {
                                      return; // Ignore if same code scanned within 1 second
                                    }
                                    
                                    setState(() {
                                      barcodeResult = scannedCode;
                                      isScanning = false;
                                      errorMessage = null;
                                      lastScannedCode = scannedCode;
                                      lastScanTime = now;
                                    });
                                    
                                    // Show success dialog
                                    _showResultDialog(scannedCode ?? 'No data');
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Scanning overlay
                      if (isScanning) _buildScanningOverlay(),
                    ],
                  ),
                ),
              ),
              
              // Bottom section with result and controls - FIXED OVERFLOW
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: availableHeight * 0.3, // Max 30% of screen
                  minHeight: 120, // Minimum height
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
                            fontSize: 16, // Fixed size
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
                            fontSize: 14, // Fixed size
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
          borderWidth: 8, // Reduced border width
          cutOutSize: 220, // Reduced cut out size
        ),
      ),
    );
  }

  Future<void> _showResultDialog(String result) async {
    if (result == "entrance") {
      // Check if user has already scanned attendance in this session
      if (hasScannedAttendance) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Already Scanned'),
              content: const Text('You have already scanned for attendance in this session. Please scan content QR codes to view information.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }

      http.Response response = await http.post(
        Uri.parse("${Config.baseUrl}visit/"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': Global.userData["name"],
          'school': Global.userData["school"],
        })
      );

      if (response.statusCode == 409) {
        // Mark as scanned even if they already visited today (from previous app session)
        setState(() {
          hasScannedAttendance = true;
        });
        
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('You have already visited today!'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }

      if (response.statusCode >= 400) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(response.body),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }

      // Successful attendance scan - mark as scanned
      setState(() {
        hasScannedAttendance = true;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Thank you for visiting! You can now scan content QR codes to view information.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // Scan QR code for content
    http.Response response = await http.post(
      Uri.parse("${Config.baseUrl}scan/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'code': result,
        'name': Global.userData["name"],
        'school': Global.userData["school"],
      })
    );

    if (response.statusCode >= 400) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(response.body),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    print(response.body);
    int contentId = jsonDecode(response.body)["data"]["id"];

    // Get content details
    response = await http.get(Uri.parse("${Config.baseUrl}content/?id=$contentId"));
    Map<String, dynamic> contentData = jsonDecode(response.body)["data"];

    // Display content details in dialog
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final String fileUrl = "https://huni-cms.ionvop.com/uploads/${contentData['file']}";
        final DateTime contentTime = DateTime.fromMillisecondsSinceEpoch(contentData['time'] * 1000);
        
        return AlertDialog(
          title: Text(
            contentData['title'] ?? 'Content Details',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display image if available
                if (contentData['file'] != null && contentData['file'].isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        fileUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            child: const Column(
                              children: [
                                Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Failed to load image', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            padding: const EdgeInsets.all(32),
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
                    ),
                  ),
                
                // Description
                if (contentData['description'] != null && contentData['description'].isNotEmpty) ...[
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contentData['description'],
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Tribe
                if (contentData['tribe'] != null && contentData['tribe'].isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Tribe: ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Expanded(
                        child: Text(
                          contentData['tribe'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Category
                if (contentData['category'] != null && contentData['category'].isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.category, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text(
                        'Category: ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Expanded(
                        child: Text(
                          contentData['category'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Time
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text(
                      'Date: ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Expanded(
                      child: Text(
                        '${contentTime.day}/${contentTime.month}/${contentTime.year} ${contentTime.hour.toString().padLeft(2, '0')}:${contentTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetScanner() async {
    setState(() {
      barcodeResult = null;
      isScanning = true;
      errorMessage = null;
      // Don't reset lastScannedCode here to allow tracking across scans
    });
    
    // No need to restart the camera with DetectionSpeed.normal
    // The scanner will continue detecting
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

// Custom overlay shape for QR scanner - OPTIMIZED
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

    // Draw the corners
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = Path()
      // Top-left corner
      ..moveTo(rect.center.dx - cutOutWidth / 2, rect.center.dy - cutOutHeight / 2)
      ..lineTo(rect.center.dx - cutOutWidth / 2 + borderLength, rect.center.dy - cutOutHeight / 2)
      ..moveTo(rect.center.dx - cutOutWidth / 2, rect.center.dy - cutOutHeight / 2)
      ..lineTo(rect.center.dx - cutOutWidth / 2, rect.center.dy - cutOutHeight / 2 + borderLength)
      
      // Top-right corner
      ..moveTo(rect.center.dx + cutOutWidth / 2, rect.center.dy - cutOutHeight / 2)
      ..lineTo(rect.center.dx + cutOutWidth / 2 - borderLength, rect.center.dy - cutOutHeight / 2)
      ..moveTo(rect.center.dx + cutOutWidth / 2, rect.center.dy - cutOutHeight / 2)
      ..lineTo(rect.center.dx + cutOutWidth / 2, rect.center.dy - cutOutHeight / 2 + borderLength)
      
      // Bottom-left corner
      ..moveTo(rect.center.dx - cutOutWidth / 2, rect.center.dy + cutOutHeight / 2)
      ..lineTo(rect.center.dx - cutOutWidth / 2 + borderLength, rect.center.dy + cutOutHeight / 2)
      ..moveTo(rect.center.dx - cutOutWidth / 2, rect.center.dy + cutOutHeight / 2)
      ..lineTo(rect.center.dx - cutOutWidth / 2, rect.center.dy + cutOutHeight / 2 - borderLength)
      
      // Bottom-right corner
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