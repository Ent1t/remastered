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
  late MobileScannerController cameraController;
  
  String? barcodeResult;
  bool isScanning = true;
  String? errorMessage;
  bool torchEnabled = false;
  bool hasScannedAttendance = false;
  bool isProcessing = false;
  bool cameraPermissionGranted = false;
  bool isCheckingPermission = true;
  bool isPermanentlyDenied = false;
  
  DateTime? lastScanTime;
  final Set<String> _scannedCodesInSession = {};

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    WidgetsBinding.instance.addObserver(this);
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      
      if (status.isGranted) {
        await _updatePermissionState(true, false);
        await cameraController.start();
      } else if (status.isDenied) {
        // Show custom permission request dialog
        await _updatePermissionState(false, false);
        _requestCameraPermission();
      } else if (status.isPermanentlyDenied) {
        await _updatePermissionState(false, true);
      }
    } catch (e) {
      debugPrint('Error checking camera permission: $e');
      await _updatePermissionState(false, false);
    }
  }

  Future<void> _requestCameraPermission() async {
    if (!mounted) return;
    
    final result = await Permission.camera.request();
    
    if (result.isGranted) {
      await _updatePermissionState(true, false);
      await cameraController.start();
    } else if (result.isPermanentlyDenied) {
      await _updatePermissionState(false, true);
    } else {
      await _updatePermissionState(false, false);
    }
  }

  Future<void> _updatePermissionState(bool granted, bool permanentlyDenied) async {
    if (mounted) {
      setState(() {
        cameraPermissionGranted = granted;
        isCheckingPermission = false;
        isPermanentlyDenied = permanentlyDenied;
      });
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
      return _buildLoadingScreen();
    }

    if (!cameraPermissionGranted) {
      return _buildPermissionScreen();
    }

    return _buildScannerScreen();
  }

  Widget _buildLoadingScreen() {
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

  Widget _buildPermissionScreen() {
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
              Text(
                isPermanentlyDenied
                    ? 'Camera permission was denied. Please enable it in your device settings to scan QR codes.'
                    : 'This app needs camera access to scan QR codes.',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (isPermanentlyDenied)
                ElevatedButton.icon(
                  onPressed: openAppSettings,
                  icon: const Icon(Icons.settings),
                  label: const Text('Open Settings'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: _requestCameraPermission,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Allow Camera Access'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerScreen() {
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
            onPressed: _toggleTorch,
          ),
          IconButton(
            icon: const Icon(Icons.camera_front),
            onPressed: _switchCamera,
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            return _buildLandscapeLayout();
          }
          return _buildPortraitLayout();
        },
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        
        final aspectRatio = availableWidth / availableHeight;
        final cameraHeight = aspectRatio > 0.75 
            ? (availableHeight * 0.6).clamp(280.0, availableHeight * 0.65)
            : (availableHeight * 0.65).clamp(300.0, availableHeight * 0.7);
        final bottomSectionHeight = (availableHeight * 0.35).clamp(120.0, 280.0);
        
        return Column(
          children: <Widget>[
            _buildCameraSection(availableWidth, cameraHeight),
            _buildBottomSection(availableWidth, availableHeight, bottomSectionHeight),
          ],
        );
      },
    );
  }

  Widget _buildLandscapeLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        
        return Row(
          children: [
            // Camera section on the left
            Expanded(
              flex: 3,
              child: _buildCameraSection(availableWidth * 0.6, availableHeight),
            ),
            // Bottom section on the right
            Expanded(
              flex: 2,
              child: Container(
                height: availableHeight,
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: SingleChildScrollView(
                    child: _buildBottomContent(availableWidth * 0.4, availableHeight),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCameraSection(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          ClipRect(
            child: SizedBox(
              width: width,
              height: height,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: width,
                  height: width,
                  child: MobileScanner(
                    controller: cameraController,
                    onDetect: _handleBarcodeDetection,
                  ),
                ),
              ),
            ),
          ),
          
          if (isScanning && !isProcessing) 
            _buildScanningOverlay(width, height),
          
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
    );
  }

  Widget _buildBottomSection(double width, double height, double maxHeight) {
    return Expanded(
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          minHeight: 120.0,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: (width * 0.04).clamp(12.0, 24.0),
          vertical: (height * 0.02).clamp(12.0, 20.0),
        ),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: _buildBottomContent(width, height),
        ),
      ),
    );
  }

  Widget _buildBottomContent(double width, double height) {
    if (isProcessing) {
      return const SizedBox.shrink();
    }

    if (barcodeResult != null) {
      return _buildSuccessContent(width, height);
    }

    if (errorMessage != null) {
      return _buildErrorContent(width, height);
    }

    return _buildInstructionsContent(width, height);
  }

  Widget _buildSuccessContent(double width, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle,
          color: Colors.green,
          size: (width * 0.08).clamp(28.0, 40.0),
        ),
        SizedBox(height: (height * 0.01).clamp(6.0, 10.0)),
        Text(
          'QR Code Scanned Successfully!',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: (width * 0.04).clamp(14.0, 18.0),
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        SizedBox(height: (height * 0.015).clamp(8.0, 14.0)),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: (width * 0.8).clamp(200.0, 400.0),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _resetScanner,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: (height * 0.015).clamp(10.0, 14.0),
                ),
              ),
              child: Text(
                'Scan Another',
                style: TextStyle(
                  fontSize: (width * 0.04).clamp(14.0, 16.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent(double width, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline,
          color: Colors.red,
          size: (width * 0.08).clamp(28.0, 40.0),
        ),
        SizedBox(height: (height * 0.01).clamp(6.0, 10.0)),
        Text(
          errorMessage!,
          style: TextStyle(
            color: Colors.red,
            fontSize: (width * 0.035).clamp(13.0, 16.0),
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildInstructionsContent(double width, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.qr_code_scanner,
          size: (width * 0.08).clamp(28.0, 40.0),
        ),
        SizedBox(height: (height * 0.01).clamp(6.0, 10.0)),
        Text(
          'Point your camera at a QR code',
          style: TextStyle(
            fontSize: (width * 0.038).clamp(13.0, 16.0),
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        SizedBox(height: (height * 0.005).clamp(2.0, 6.0)),
        Text(
          'Make sure the QR code is well-lit and centered',
          style: TextStyle(
            fontSize: (width * 0.032).clamp(11.0, 14.0),
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }

  void _handleBarcodeDetection(BarcodeCapture capture) {
    if (!isScanning || isProcessing || !mounted) return;
    
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    final scannedCode = barcodes.first.rawValue;
    if (scannedCode == null || scannedCode.isEmpty) return;
    
    final normalizedCode = scannedCode.trim().toLowerCase();
    
    // Prevent rapid re-scanning of the same code
    if (_scannedCodesInSession.contains(normalizedCode)) {
      final now = DateTime.now();
      if (lastScanTime != null && now.difference(lastScanTime!).inSeconds < 5) {
        return;
      }
    }
    
    setState(() {
      barcodeResult = scannedCode;
      isScanning = false;
      isProcessing = true;
      errorMessage = null;
      lastScanTime = DateTime.now();
    });
    
    _processScannedCode(scannedCode, normalizedCode);
  }

  Widget _buildScanningOverlay(double width, double height) {
    // Calculate responsive cutout size for both orientations
    final smallerDimension = width < height ? width : height;
    final cutOutSize = (smallerDimension * 0.6).clamp(180.0, 300.0);
    final borderLength = (cutOutSize * 0.15).clamp(25.0, 45.0);
    final borderWidth = (smallerDimension * 0.02).clamp(6.0, 10.0);
    
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

  Future<void> _processScannedCode(String originalCode, String normalizedCode) async {
    try {
      if (normalizedCode == "entrance") {
        await _handleEntranceScan(normalizedCode);
      } else {
        await _handleContentScan(originalCode, normalizedCode);
      }
    } on http.ClientException catch (e) {
      debugPrint('Network error: $e');
      _showError('Unable to connect to the server. Please check your internet connection and try again.');
    } catch (e) {
      debugPrint('Error processing scan: $e');
      String errorMsg = 'An unexpected error occurred. Please try again.';
      if (e.toString().contains('timeout')) {
        errorMsg = 'Connection timeout. Please check your internet connection and try again.';
      }
      _showError(errorMsg);
    }
  }

  Future<void> _handleEntranceScan(String normalizedCode) async {
    if (hasScannedAttendance) {
      _finishProcessing();
      _showDialog(
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
      onTimeout: () => throw Exception('Connection timeout'),
    );

    if (!mounted) return;

    if (response.statusCode == 409) {
      setState(() {
        hasScannedAttendance = true;
      });
      _finishProcessing();
      _scannedCodesInSession.add(normalizedCode);
      
      _showDialog(
        title: 'Already Visited',
        content: 'You have already recorded your visit today!',
      );
      return;
    }

    if (response.statusCode >= 400) {
      _finishProcessing();
      final errorMsg = _extractErrorMessage(response);
      _showDialog(title: 'Error', content: errorMsg);
      return;
    }

    setState(() {
      hasScannedAttendance = true;
    });
    _finishProcessing();
    _scannedCodesInSession.add(normalizedCode);

    _showDialog(
      title: 'Success',
      content: 'Thank you for visiting! You can now scan content QR codes to view information.',
    );
  }

  Future<void> _handleContentScan(String originalCode, String normalizedCode) async {
    final scanResponse = await http.post(
      Uri.parse("${Config.baseUrl}scan/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'code': originalCode,
        'name': Global.userData["name"],
        'school': Global.userData["school"],
      }),
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception('Connection timeout'),
    );

    if (!mounted) return;

    if (scanResponse.statusCode >= 400) {
      _finishProcessing();
      final errorMsg = _extractErrorMessage(scanResponse);
      _showDialog(title: 'Error', content: errorMsg);
      return;
    }

    final scanData = jsonDecode(scanResponse.body);
    final int contentId = scanData["data"]["id"];

    final contentResponse = await http.get(
      Uri.parse("${Config.baseUrl}content/?id=$contentId"),
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception('Connection timeout'),
    );

    if (!mounted) return;

    if (contentResponse.statusCode >= 400) {
      _finishProcessing();
      _showDialog(
        title: 'Error',
        content: 'Failed to load content details. Please try again.',
      );
      return;
    }

    final Map<String, dynamic> contentData = jsonDecode(contentResponse.body)["data"];
    
    _finishProcessing();
    _scannedCodesInSession.add(normalizedCode);
    _showContentDialog(contentData);
  }

  String _extractErrorMessage(http.Response response) {
    String errorMsg = 'An error occurred. Please try again.';
    try {
      final errorData = jsonDecode(response.body);
      errorMsg = errorData['message'] ?? errorMsg;
    } catch (e) {
      if (response.body.isNotEmpty) {
        errorMsg = response.body;
      }
    }
    return errorMsg;
  }

  void _finishProcessing() {
    if (mounted) {
      setState(() {
        isProcessing = false;
      });
    }
  }

  void _showError(String message) {
    _finishProcessing();
    _showDialog(title: 'Error', content: message);
  }

  void _showDialog({required String title, required String content}) {
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
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showContentDialog(Map<String, dynamic> contentData) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ExpandableContentDialog(contentData: contentData);
      },
    );
  }

  Future<void> _toggleTorch() async {
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
  }

  Future<void> _switchCamera() async {
    try {
      await cameraController.switchCamera();
    } catch (e) {
      debugPrint('Error switching camera: $e');
    }
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

class ExpandableContentDialog extends StatefulWidget {
  final Map<String, dynamic> contentData;

  const ExpandableContentDialog({
    super.key,
    required this.contentData,
  });

  @override
  State<ExpandableContentDialog> createState() => _ExpandableContentDialogState();
}

class _ExpandableContentDialogState extends State<ExpandableContentDialog> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final String fileUrl = "https://huni-cms.ionvop.com/uploads/${widget.contentData['file']}";
    final DateTime contentTime = DateTime.fromMillisecondsSinceEpoch(widget.contentData['time'] * 1000);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.85,
          maxWidth: screenWidth * 0.92,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildContent(fileUrl, contentTime),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Text(
        widget.contentData['title'] ?? 'Content Details',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildContent(String fileUrl, DateTime contentTime) {
    return Flexible(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.contentData['file'] != null && widget.contentData['file'].isNotEmpty)
              _buildImageSection(fileUrl),
            
            if (widget.contentData['description'] != null && widget.contentData['description'].isNotEmpty)
              _buildDescriptionSection(),
            
            _buildMetadataSection(contentTime),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(String fileUrl) {
    return GestureDetector(
      onTap: () => _showZoomableImage(context, fileUrl),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: const BoxConstraints(
          maxHeight: 300,
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
                  child: const Center(child: CircularProgressIndicator()),
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Text(
            widget.contentData['description'],
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(DateTime contentTime) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (widget.contentData['tribe'] != null && widget.contentData['tribe'].isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.people,
              label: 'Tribe:',
              value: widget.contentData['tribe'],
              color: Colors.blue,
            ),
            const Divider(height: 20),
          ],
          
          if (widget.contentData['category'] != null && widget.contentData['category'].isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.category,
              label: 'Category:',
              value: widget.contentData['category'],
              color: Colors.orange,
            ),
            const Divider(height: 20),
          ],
          
          _buildInfoRow(
            icon: Icons.access_time,
            label: 'Date:',
            value: '${contentTime.day}/${contentTime.month}/${contentTime.year} ${contentTime.hour.toString().padLeft(2, '0')}:${contentTime.minute.toString().padLeft(2, '0')}',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
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
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
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
          child: GestureDetector(
            onTap: () => Navigator.of(dialogContext).pop(),
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 5.0,
                    boundaryMargin: const EdgeInsets.all(80),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      placeholder: (context, url) => SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Pinch to zoom • Drag to pan • Tap to close',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
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
}

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