import 'package:flutter/material.dart';

class VehicleDetailsPage extends StatelessWidget {
  final String vehicleId;
  
  const VehicleDetailsPage({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Vehicle Details Page - Vehicle ID: $vehicleId - Em desenvolvimento'),
      ),
    );
  }
}
