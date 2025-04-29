import 'package:hive_flutter/hive_flutter.dart';

part 'Adapterg.dart';

@HiveType(typeId: 1)
class Aktivite {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String ID;
  Aktivite({required this.ID, required this.title, required this.date});
}
