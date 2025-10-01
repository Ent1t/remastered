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
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  
  String? barcodeResult;
  bool isScanning = true;
  String? errorMessage;
  bool torchEnabled = false;
  String? lastScannedCode;
  DateTime? lastScanTime;
  bool hasScannedAttendance = false;

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
        title: const Text(
          'QR Code Scanner',
          overflow: TextOverflow.ellipsis,
        ),
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
          final availableWidth = constraints.maxWidth;
          
          // Calculate responsive sizes with constraints
          final cameraHeight = (availableHeight * 0.65).clamp(300.0, availableHeight * 0.7);
          final bottomSectionHeight = (availableHeight * 0.35).clamp(120.0, 250.0);
          
          return Column(
            children: <Widget>[
              // Camera preview section
              Container(
                width: double.infinity,
                height: cameraHeight,
                constraints: BoxConstraints(
                  maxHeight: cameraHeight,
                  minHeight: 300.0,
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
                            width: availableWidth,
                            height: availableWidth,
                            child: MobileScanner(
                              controller: cameraController,
                              onDetect: (capture) {
                                if (!isScanning) return;
                                
                                final List<Barcode> barcodes = capture.barcodes;
                                if (barcodes.isNotEmpty) {
                                  final barcode = barcodes.first;
                                  final scannedCode = barcode.rawValue;
                                  
                                  final now = DateTime.now();
                                  if (lastScanTime != null && 
                                      scannedCode == lastScannedCode &&
                                      now.difference(lastScanTime!).inMilliseconds < 1000) {
                                    return;
                                  }
                                  
                                  setState(() {
                                    barcodeResult = scannedCode;
                                    isScanning = false;
                                    errorMessage = null;
                                    lastScannedCode = scannedCode;
                                    lastScanTime = now;
                                  });
                                  
                                  _showResultDialog(scannedCode ?? 'No data');
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Scanning overlay
                    if (isScanning) _buildScanningOverlay(availableWidth, cameraHeight),
                  ],
                ),
              ),
              
              // Bottom section with result and controls
              Expanded(
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: bottomSectionHeight,
                    minHeight: 120.0,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: (availableWidth * 0.04).clamp(12.0, 24.0),
                    vertical: (availableHeight * 0.02).clamp(12.0, 20.0),
                  ),
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
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: (availableWidth * 0.08).clamp(28.0, 40.0),
                          ),
                          SizedBox(height: (availableHeight * 0.01).clamp(6.0, 10.0)),
                          Flexible(
                            child: Text(
                              'QR Code Scanned Successfully!',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: (availableWidth * 0.04).clamp(14.0, 18.0),
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          SizedBox(height: (availableHeight * 0.015).clamp(8.0, 14.0)),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: (availableWidth * 0.8).clamp(200.0, 400.0),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _resetScanner,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: (availableHeight * 0.015).clamp(10.0, 14.0),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Scan Another',
                                    style: TextStyle(
                                      fontSize: (availableWidth * 0.04).clamp(14.0, 16.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ] else if (errorMessage != null) ...[
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: (availableWidth * 0.08).clamp(28.0, 40.0),
                          ),
                          SizedBox(height: (availableHeight * 0.01).clamp(6.0, 10.0)),
                          Flexible(
                            child: Text(
                              errorMessage!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: (availableWidth * 0.035).clamp(13.0, 16.0),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ] else ...[
                          Icon(
                            Icons.qr_code_scanner,
                            size: (availableWidth * 0.08).clamp(28.0, 40.0),
                          ),
                          SizedBox(height: (availableHeight * 0.01).clamp(6.0, 10.0)),
                          Flexible(
                            child: Text(
                              'Point your camera at a QR code',
                              style: TextStyle(
                                fontSize: (availableWidth * 0.038).clamp(13.0, 16.0),
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          SizedBox(height: (availableHeight * 0.005).clamp(2.0, 6.0)),
                          Flexible(
                            child: Text(
                              'Make sure the QR code is well-lit and centered',
                              style: TextStyle(
                                fontSize: (availableWidth * 0.032).clamp(11.0, 14.0),
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildScanningOverlay(double screenWidth, double cameraHeight) {
    // Calculate responsive cutout size
    final cutOutSize = (screenWidth * 0.6).clamp(180.0, 280.0);
    final borderLength = (cutOutSize * 0.15).clamp(25.0, 40.0);
    final borderWidth = (screenWidth * 0.02).clamp(6.0, 10.0);
    
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderRadius: 12,
          borderLength: borderLength,
          borderWidth: borderWidth,
          cutOutSize: cutOutSize,
        ),
      ),
    );
  }

  Future<void> _showResultDialog(String result) async {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (result == "entrance") {
      if (hasScannedAttendance) {
        _showStandardDialog(
          title: 'Already Scanned',
          content: 'You have already scanned for attendance in this session. Please scan content QR codes to view information.',
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
        setState(() {
          hasScannedAttendance = true;
        });
        
        _showStandardDialog(
          title: 'Error',
          content: 'You have already visited today!',
        );
        return;
      }

      if (response.statusCode >= 400) {
        _showStandardDialog(
          title: 'Error',
          content: response.body,
        );
        return;
      }

      setState(() {
        hasScannedAttendance = true;
      });

      _showStandardDialog(
        title: 'Success',
        content: 'Thank you for visiting! You can now scan content QR codes to view information.',
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
      _showStandardDialog(
        title: 'Error',
        content: response.body,
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
    
    _showContentDialog(contentData, screenWidth);
  }

  void _showStandardDialog({required String title, required String content}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
          ),
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
  }

  void _showContentDialog(Map<String, dynamic> contentData, double screenWidth) {
    final String fileUrl = "https://huni-cms.ionvop.com/uploads/${contentData['file']}";
    final DateTime contentTime = DateTime.fromMillisecondsSinceEpoch(contentData['time'] * 1000);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            contentData['title'] ?? 'Content Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: (screenWidth * 0.045).clamp(16.0, 20.0),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
              maxWidth: screenWidth * 0.9,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display image if available
                  if (contentData['file'] != null && contentData['file'].isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      constraints: BoxConstraints(
                        maxHeight: (MediaQuery.of(context).size.height * 0.3).clamp(150.0, 300.0),
                      ),
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
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.broken_image, size: (screenWidth * 0.12).clamp(40.0, 60.0), color: Colors.grey),
                                  const SizedBox(height: 8),
                                  const Text('Failed to load image', style: TextStyle(color: Colors.grey)),
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
                    Text(
                      'Description:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: (screenWidth * 0.036).clamp(13.0, 16.0),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contentData['description'],
                      style: TextStyle(
                        fontSize: (screenWidth * 0.035).clamp(12.0, 15.0),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Tribe
                  if (contentData['tribe'] != null && contentData['tribe'].isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.people, size: (screenWidth * 0.04).clamp(14.0, 18.0), color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Tribe: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: (screenWidth * 0.036).clamp(13.0, 16.0),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            contentData['tribe'],
                            style: TextStyle(
                              fontSize: (screenWidth * 0.035).clamp(12.0, 15.0),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Category
                  if (contentData['category'] != null && contentData['category'].isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.category, size: (screenWidth * 0.04).clamp(14.0, 18.0), color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Category: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: (screenWidth * 0.036).clamp(13.0, 16.0),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            contentData['category'],
                            style: TextStyle(
                              fontSize: (screenWidth * 0.035).clamp(12.0, 15.0),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Time
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.access_time, size: (screenWidth * 0.04).clamp(14.0, 18.0), color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Date: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: (screenWidth * 0.036).clamp(13.0, 16.0),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${contentTime.day}/${contentTime.month}/${contentTime.year} ${contentTime.hour.toString().padLeft(2, '0')}:${contentTime.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: (screenWidth * 0.035).clamp(12.0, 15.0),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(
                  fontSize: (screenWidth * 0.038).clamp(14.0, 16.0),
                ),
              ),
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
    });
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