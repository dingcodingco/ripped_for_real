import 'package:flutter/material.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'dart:io';

class ATTPermissionWrapper extends StatefulWidget {
  final Widget child;
  
  const ATTPermissionWrapper({
    super.key,
    required this.child,
  });

  @override
  State<ATTPermissionWrapper> createState() => _ATTPermissionWrapperState();
}

class _ATTPermissionWrapperState extends State<ATTPermissionWrapper> {
  bool _isCheckingPermission = true;

  @override
  void initState() {
    super.initState();
    _checkTrackingPermission();
  }

  Future<void> _checkTrackingPermission() async {
    if (!Platform.isIOS) {
      setState(() {
        _isCheckingPermission = false;
      });
      return;
    }

    // Check current status
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    
    if (status == TrackingStatus.notDetermined) {
      // Wait a bit to ensure the app is fully loaded
      await Future.delayed(const Duration(seconds: 1));
      
      // Request permission
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
    
    setState(() {
      _isCheckingPermission = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }
    
    return widget.child;
  }
}