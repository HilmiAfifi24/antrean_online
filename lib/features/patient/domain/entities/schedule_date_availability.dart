import 'package:equatable/equatable.dart';

class ScheduleDateAvailability extends Equatable {
  final DateTime date;
  final int currentPatients;
  final int maxPatients;

  const ScheduleDateAvailability({
    required this.date,
    required this.currentPatients,
    required this.maxPatients,
  });

  bool get isFull => currentPatients >= maxPatients;

  @override
  List<Object?> get props => [date, currentPatients, maxPatients];
}
