import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../global.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> with WidgetsBindingObserver {
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
  bool isProcessing = false;
  bool cameraPermissionGranted = false;
  bool isCheckingPermission = true;
  
  // Track scanned codes in this session to prevent duplicates (stored in normalized form)
  final Set<String> _scannedCodesInSession = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      
      if (status.isGranted) {
        if (mounted) {
          setState(() {
            cameraPermissionGranted = true;
            isCheckingPermission = false;
          });
        }
        await cameraController.start();
      } else if (status.isDenied) {
        final result = await Permission.camera.request();
        if (mounted) {
          setState(() {
            cameraPermissionGranted = result.isGranted;
            isCheckingPermission = false;
          });
        }
        if (result.isGranted) {
          await cameraController.start();
        }
      } else if (status.isPermanentlyDenied) {
        if (mounted) {
          setState(() {
            cameraPermissionGranted = false;
            isCheckingPermission = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking camera permission: $e');
      if (mounted) {
        setState(() {
          isCheckingPermission = false;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (!mounted || !cameraPermissionGranted) return;
    
    switch (state) {
      case AppLifecycleState.paused:
        _stopCamera();
        break;
      case AppLifecycleState.resumed:
        _startCamera();
        break;
      default:
        break;
    }
  }

  Future<void> _stopCamera() async {
    try {
      await cameraController.stop();
    } catch (e) {
      debugPrint('Error stopping camera: $e');
    }
  }

  Future<void> _startCamera() async {
    try {
      await cameraController.start();
    } catch (e) {
      debugPrint('Error starting camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isCheckingPermission) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('QR Code Scanner'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!cameraPermissionGranted) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('QR Code Scanner'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Camera Permission Required',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'This app needs camera access to scan QR codes. Please grant camera permission in your device settings.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    await openAppSettings();
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Open Settings'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                if (mounted) {
                  setState(() {
                    torchEnabled = !torchEnabled;
                  });
                }
              } catch (e) {
                debugPrint('Error toggling torch: $e');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_front),
            onPressed: () async {
              try {
                await cameraController.switchCamera();
              } catch (e) {
                debugPrint('Error switching camera: $e');
              }
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          final availableWidth = constraints.maxWidth;
          
          // Calculate responsive sizes with better constraints for edge cases
          final aspectRatio = availableWidth / availableHeight;
          final cameraHeight = aspectRatio > 0.75 
              ? (availableHeight * 0.6).clamp(280.0, availableHeight * 0.65)
              : (availableHeight * 0.65).clamp(300.0, availableHeight * 0.7);
          final bottomSectionHeight = (availableHeight * 0.35).clamp(120.0, 280.0);
          
          return Column(
            children: <Widget>[
              // Camera preview section
              Container(
                width: double.infinity,
                height: cameraHeight,
                constraints: BoxConstraints(
                  maxHeight: cameraHeight,
                  minHeight: 280.0,
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
                                _handleBarcodeDetection(capture);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Scanning overlay
                    if (isScanning && !isProcessing) _buildScanningOverlay(availableWidth, cameraHeight),
                    
                    // Processing indicator
                    if (isProcessing)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
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
                        if (barcodeResult != null && !isProcessing) ...[
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
                        ] else if (errorMessage != null && !isProcessing) ...[
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
                        ] else if (!isProcessing) ...[
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

  void _handleBarcodeDetection(BarcodeCapture capture) {
    // Prevent multiple simultaneous scans
    if (!isScanning || isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    final barcode = barcodes.first;
    final scannedCode = barcode.rawValue;
    
    if (scannedCode == null || scannedCode.isEmpty) return;
    
    // Normalize code for case-insensitive comparison
    final normalizedCode = scannedCode.trim().toLowerCase();
    
    // Check if this code was already scanned in this session
    if (_scannedCodesInSession.contains(normalizedCode)) {
      // Allow re-scan after 5 seconds for same code
      final now = DateTime.now();
      if (lastScanTime != null && 
          normalizedCode == lastScannedCode &&
          now.difference(lastScanTime!).inSeconds < 5) {
        return;
      }
    }
    
    // Set processing flag immediately to prevent race conditions
    if (!mounted) return;
    setState(() {
      barcodeResult = scannedCode;
      isScanning = false;
      isProcessing = true;
      errorMessage = null;
      lastScannedCode = normalizedCode; // Store normalized version for consistency
      lastScanTime = DateTime.now();
    });
    
    _showResultDialog(scannedCode);
  }

  Widget _buildScanningOverlay(double screenWidth, double cameraHeight) {
    // Calculate responsive cutout size with better handling for different aspect ratios
    final cutOutSize = (screenWidth * 0.6).clamp(180.0, 300.0);
    final borderLength = (cutOutSize * 0.15).clamp(25.0, 45.0);
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
    try {
      final normalizedResult = result.trim().toLowerCase();
      
      // Handle entrance/attendance scan
      if (normalizedResult == "entrance") {
        if (hasScannedAttendance) {
          if (!mounted) return;
          setState(() {
            isProcessing = false;
          });
          // Safely show dialog only if widget is still mounted
          if (!mounted) return;
          _showStandardDialog(
            title: 'Already Scanned',
            content: 'You have already scanned for attendance in this session. Please scan content QR codes to view information.',
          );
          return;
        }

        final response = await http.post(
          Uri.parse("${Config.baseUrl}visit/"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': Global.userData["name"],
            'school': Global.userData["school"],
          }),
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw Exception('Connection timeout. Please check your internet connection and try again.');
          },
        );

        if (!mounted) return;

        if (response.statusCode == 409) {
          setState(() {
            hasScannedAttendance = true;
            isProcessing = false;
          });
          
          _scannedCodesInSession.add(normalizedResult);
          
          if (!mounted) return;
          _showStandardDialog(
            title: 'Already Visited',
            content: 'You have already recorded your visit today!',
          );
          return;
        }

        if (response.statusCode >= 400) {
          if (!mounted) return;
          setState(() {
            isProcessing = false;
          });
          
          String errorMsg = 'Failed to record attendance.';
          try {
            final errorData = jsonDecode(response.body);
            errorMsg = errorData['message'] ?? errorMsg;
          } catch (e) {
            errorMsg = response.body.isNotEmpty ? response.body : errorMsg;
          }
          
          if (!mounted) return;
          _showStandardDialog(
            title: 'Error',
            content: errorMsg,
          );
          return;
        }

        if (!mounted) return;
        setState(() {
          hasScannedAttendance = true;
          isProcessing = false;
        });

        _scannedCodesInSession.add(normalizedResult);

        if (!mounted) return;
        _showStandardDialog(
          title: 'Success',
          content: 'Thank you for visiting! You can now scan content QR codes to view information.',
        );
        return;
      }

      // Handle content QR scan
      final scanResponse = await http.post(
        Uri.parse("${Config.baseUrl}scan/"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'code': result,
          'name': Global.userData["name"],
          'school': Global.userData["school"],
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Connection timeout. Please check your internet connection and try again.');
        },
      );

      if (!mounted) return;

      if (scanResponse.statusCode >= 400) {
        setState(() {
          isProcessing = false;
        });
        
        String errorMsg = 'Failed to scan QR code.';
        try {
          final errorData = jsonDecode(scanResponse.body);
          errorMsg = errorData['message'] ?? errorMsg;
        } catch (e) {
          errorMsg = scanResponse.body.isNotEmpty ? scanResponse.body : errorMsg;
        }
        
        if (!mounted) return;
        _showStandardDialog(
          title: 'Error',
          content: errorMsg,
        );
        return;
      }

      debugPrint(scanResponse.body);
      final scanData = jsonDecode(scanResponse.body);
      final int contentId = scanData["data"]["id"];

      // Get content details
      final contentResponse = await http.get(
        Uri.parse("${Config.baseUrl}content/?id=$contentId"),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Connection timeout. Please check your internet connection and try again.');
        },
      );

      if (!mounted) return;

      if (contentResponse.statusCode >= 400) {
        setState(() {
          isProcessing = false;
        });
        
        if (!mounted) return;
        _showStandardDialog(
          title: 'Error',
          content: 'Failed to load content details. Please try again.',
        );
        return;
      }

      final Map<String, dynamic> contentData = jsonDecode(contentResponse.body)["data"];

      if (!mounted) return;
      setState(() {
        isProcessing = false;
      });

      _scannedCodesInSession.add(normalizedResult);

      // Display content details in dialog
      if (!mounted) return;
      _showContentDialog(contentData);
    } on http.ClientException catch (e) {
      debugPrint('Network error in _showResultDialog: $e');
      
      if (!mounted) return;
      setState(() {
        isProcessing = false;
      });
      
      if (!mounted) return;
      _showStandardDialog(
        title: 'Network Error',
        content: 'Unable to connect to the server. Please check your internet connection and try again.',
      );
    } catch (e) {
      debugPrint('Error in _showResultDialog: $e');
      
      if (!mounted) return;
      setState(() {
        isProcessing = false;
      });
      
      String errorMsg = 'An unexpected error occurred. Please try again.';
      if (e.toString().contains('timeout')) {
        errorMsg = 'Connection timeout. Please check your internet connection and try again.';
      }
      
      if (!mounted) return;
      _showStandardDialog(
        title: 'Error',
        content: errorMsg,
      );
    }
  }

  void _showStandardDialog({required String title, required String content}) {
    if (!mounted) return;
    
    // Use a post-frame callback to ensure the widget tree is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
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
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }

  void _showContentDialog(Map<String, dynamic> contentData) {
    if (!mounted) return;
    
    // Use a post-frame callback to ensure the widget tree is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return ExpandableContentDialog(contentData: contentData);
        },
      );
    });
  }

  Future<void> _resetScanner() async {
    if (mounted) {
      setState(() {
        barcodeResult = null;
        isScanning = true;
        isProcessing = false;
        errorMessage = null;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    super.dispose();
  }
}

// Expandable Content Dialog Widget
class ExpandableContentDialog extends StatefulWidget {
  final Map<String, dynamic> contentData;

  const ExpandableContentDialog({
    Key? key,
    required this.contentData,
  }) : super(key: key);

  @override
  State<ExpandableContentDialog> createState() => _ExpandableContentDialogState();
}

class _ExpandableContentDialogState extends State<ExpandableContentDialog> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (!mounted) return const SizedBox.shrink();
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final String fileUrl = "https://huni-cms.ionvop.com/uploads/${widget.contentData['file']}";
    final DateTime contentTime = DateTime.fromMillisecondsSinceEpoch(widget.contentData['time'] * 1000);
    
    // Calculate adaptive sizes
    final maxImageHeight = isExpanded ? screenHeight * 0.4 : screenHeight * 0.25;
    final maxDialogHeight = isExpanded ? screenHeight * 0.8 : screenHeight * 0.65;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: maxDialogHeight,
          maxWidth: screenWidth * 0.92,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.contentData['title'] ?? 'Content Details',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isExpanded ? Icons.unfold_less : Icons.unfold_more,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      }
                    },
                    tooltip: isExpanded ? 'Show less' : 'Show more',
                  ),
                ],
              ),
            ),
            
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with zoom functionality and caching
                    if (widget.contentData['file'] != null && widget.contentData['file'].isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _showZoomableImage(context, fileUrl);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          constraints: BoxConstraints(
                            maxHeight: maxImageHeight,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: fileUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    height: 150,
                                    padding: const EdgeInsets.all(32),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    height: 150,
                                    padding: const EdgeInsets.all(16),
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text('Failed to load image', style: TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.zoom_in, color: Colors.white, size: 18),
                                      SizedBox(width: 4),
                                      Text('Tap to zoom', style: TextStyle(color: Colors.white, fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Description section with expand/collapse
                    if (widget.contentData['description'] != null && widget.contentData['description'].isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.description, size: 18, color: Colors.grey.shade700),
                                const SizedBox(width: 8),
                                const Text(
                                  'Description:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            AnimatedCrossFade(
                              firstChild: Text(
                                widget.contentData['description'],
                                style: const TextStyle(fontSize: 14, height: 1.5),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              secondChild: Text(
                                widget.contentData['description'],
                                style: const TextStyle(fontSize: 14, height: 1.5),
                              ),
                              crossFadeState: isExpanded 
                                  ? CrossFadeState.showSecond 
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 300),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Metadata section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          // Tribe
                          if (widget.contentData['tribe'] != null && widget.contentData['tribe'].isNotEmpty)
                            _buildInfoRow(
                              icon: Icons.people,
                              label: 'Tribe:',
                              value: widget.contentData['tribe'],
                              color: Colors.blue,
                            ),
                          
                          if (widget.contentData['tribe'] != null && widget.contentData['tribe'].isNotEmpty)
                            const Divider(height: 20),
                          
                          // Category
                          if (widget.contentData['category'] != null && widget.contentData['category'].isNotEmpty)
                            _buildInfoRow(
                              icon: Icons.category,
                              label: 'Category:',
                              value: widget.contentData['category'],
                              color: Colors.orange,
                            ),
                          
                          if (widget.contentData['category'] != null && widget.contentData['category'].isNotEmpty)
                            const Divider(height: 20),
                          
                          // Time
                          _buildInfoRow(
                            icon: Icons.access_time,
                            label: 'Date:',
                            value: '${contentTime.day}/${contentTime.month}/${contentTime.year} ${contentTime.hour.toString().padLeft(2, '0')}:${contentTime.minute.toString().padLeft(2, '0')}',
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer with close button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  void _showZoomableImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      padding: const EdgeInsets.all(32),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      padding: const EdgeInsets.all(32),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.broken_image, size: 60, color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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