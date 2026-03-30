import 'package:flutter/material.dart';

enum CarType { bugattiChiron, lamborghiniUrus, ferrariSF90 }

class CarData {
  final CarType type;
  final String name;
  final String engineSpec;
  final double maxSpeed;
  final double acceleration;
  final double handling;
  final Color primaryColor;
  final Color accentColor;
  final Color secondaryColor;
  final String topSpeed;
  final String zeroToHundred;
  final int horsepower;
  final int stars;

  const CarData({
    required this.type,
    required this.name,
    required this.engineSpec,
    required this.maxSpeed,
    required this.acceleration,
    required this.handling,
    required this.primaryColor,
    required this.accentColor,
    required this.secondaryColor,
    required this.topSpeed,
    required this.zeroToHundred,
    required this.horsepower,
    required this.stars,
  });

  static const List<CarData> all = [bugattiChiron, lamborghiniUrus, ferrariSF90];

  static const bugattiChiron = CarData(
    type: CarType.bugattiChiron,
    name: 'Bugatti Chiron',
    engineSpec: '8.0L W16 Quad-Turbo',
    maxSpeed: 920,
    acceleration: 78,
    handling: 72,
    primaryColor: Color(0xFF1B3A8C),
    accentColor: Color(0xFF87CEEB),
    secondaryColor: Color(0xFF111111),
    topSpeed: '420 km/h',
    zeroToHundred: '2.4s',
    horsepower: 1500,
    stars: 5,
  );

  static const lamborghiniUrus = CarData(
    type: CarType.lamborghiniUrus,
    name: 'Lamborghini Urus',
    engineSpec: '4.0L V8 Twin-Turbo',
    maxSpeed: 700,
    acceleration: 60,
    handling: 88,
    primaryColor: Color(0xFFE8620A),
    accentColor: Color(0xFF222222),
    secondaryColor: Color(0xFF111111),
    topSpeed: '305 km/h',
    zeroToHundred: '3.6s',
    horsepower: 650,
    stars: 4,
  );

  static const ferrariSF90 = CarData(
    type: CarType.ferrariSF90,
    name: 'Ferrari SF90',
    engineSpec: '4.0L V8 Hybrid',
    maxSpeed: 810,
    acceleration: 70,
    handling: 82,
    primaryColor: Color(0xFFCC0000),
    accentColor: Color(0xFFFFD700),
    secondaryColor: Color(0xFF1A1A1A),
    topSpeed: '340 km/h',
    zeroToHundred: '2.5s',
    horsepower: 1000,
    stars: 5,
  );
}
