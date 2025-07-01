import 'dart:async';
import 'package:azkar/provider/language_provider.dart';
import 'package:azkar/screens/qibla/qibla_compass.dart';
import 'package:azkar/widgets/drawer_widget.dart';
import 'package:azkar/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class QiblaPage extends StatefulWidget {
  @override
  _QiblaPageState createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  final Future<bool?> _deviceSupport =
      FlutterQiblah.androidDeviceSensorSupport();

  late StreamController<LocationStatus> _locationStreamController;
  Stream<LocationStatus> get locationStream => _locationStreamController.stream;

  Position? _currentPosition;
  String? _distanceMessage;
  bool _locationPermissionGranted = false;
  bool _checkingLocation = false;

  @override
  void initState() {
    super.initState();
    _locationStreamController = StreamController.broadcast();
    _checkLocationStatus();
  }

  @override
  void dispose() {
    _locationStreamController.close();
    FlutterQiblah().dispose();
    super.dispose();
  }

  Future<void> _checkLocationStatus() async {
    setState(() => _checkingLocation = true);
    try {
      final status = await FlutterQiblah.checkLocationStatus();

      if (status.enabled && status.status == LocationPermission.denied) {
        await _requestLocationPermission();
      } else if (!status.enabled) {
        // Location services disabled
        setState(() {
          _distanceMessage = "Location services are disabled.";
        });
      } else {
        _locationStreamController.add(status);
        await _getCurrentLocationAndCalculateDistance();
      }
    } catch (e) {
      _locationStreamController.addError('Error checking location: $e');
      setState(() {
        _distanceMessage = "Error checking location: $e";
      });
    } finally {
      setState(() => _checkingLocation = false);
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      await FlutterQiblah.requestPermissions();
      final newStatus = await FlutterQiblah.checkLocationStatus();
      _locationStreamController.add(newStatus);
      if (newStatus.status == LocationPermission.always ||
          newStatus.status == LocationPermission.whileInUse) {
        setState(() => _locationPermissionGranted = true);
        await _getCurrentLocationAndCalculateDistance();
      } else {
        setState(() {
          _distanceMessage = "Location permission denied.";
        });
      }
    } catch (e) {
      _locationStreamController.addError('Permission request failed: $e');
      setState(() {
        _distanceMessage = "Permission request failed: $e";
      });
    }
  }

  Future<void> _getCurrentLocationAndCalculateDistance() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      const makkahLat = 21.4225;
      const makkahLng = 39.8262;

      final distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        makkahLat,
        makkahLng,
      );

      final distanceInKm = (distanceInMeters / 1000).round();

      setState(() {
        _distanceMessage = "Qibla is $distanceInKm km away from your location";
      });
    } catch (e) {
      setState(() {
        _distanceMessage = "Failed to get location: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      drawer: DrawerWidget(),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text("Qibla Direction", style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            filterQuality: FilterQuality.high,
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<bool?>(
          future: _deviceSupport,
          builder: (context, AsyncSnapshot<bool?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return LoadingIndicator();

            if (snapshot.hasError)
              return Center(
                child: Text(
                  languageProvider.localizedStrings["Error"] ??
                      "Error: ${snapshot.error.toString()}",
                  style: TextStyle(color: Colors.white),
                ),
              );

            if (snapshot.data != null && snapshot.data == true) {
              // Device supports sensor, show compass
              return QiblahCompass();
            } else {
              // Sensor not supported, show distance or messages
              if (_checkingLocation) {
                return Center(child: LoadingIndicator());
              }

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset("assets/Group 48096676.png"),
                    ),
                    Text(
                      _distanceMessage!,

                      style: TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
