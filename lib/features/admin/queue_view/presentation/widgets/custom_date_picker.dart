import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDatePicker extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CustomDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          // Header with month/year selector
          _buildHeader(),

          const SizedBox(height: 20),

          // Calendar grid
          _buildCalendar(),

          const SizedBox(height: 20),

          // Action buttons
          _buildActions(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous month button
          IconButton(
            onPressed: () {
              setState(() {
                _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
              });
            },
            icon: const Icon(Icons.chevron_left_rounded),
            color: const Color(0xFF3B82F6),
            iconSize: 28,
          ),

          // Month and year display
          Column(
            children: [
              Text(
                months[_displayedMonth.month - 1],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                _displayedMonth.year.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),

          // Next month button
          IconButton(
            onPressed: () {
              setState(() {
                _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
              });
            },
            icon: const Icon(Icons.chevron_right_rounded),
            color: const Color(0xFF3B82F6),
            iconSize: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7; // Minggu = 0, Senin = 1, ...
    final daysInMonth = lastDayOfMonth.day;

    final days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Day names header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((day) {
              return SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Calendar grid
          Column(
            children: List.generate(6, (weekIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (dayIndex) {
                    final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
                    
                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return const SizedBox(width: 40, height: 40);
                    }

                    final date = DateTime(_displayedMonth.year, _displayedMonth.month, dayNumber);
                    final isSelected = _selectedDate.year == date.year &&
                        _selectedDate.month == date.month &&
                        _selectedDate.day == date.day;
                    final isToday = DateTime.now().year == date.year &&
                        DateTime.now().month == date.month &&
                        DateTime.now().day == date.day;

                    return _buildDayCell(date, isSelected, isToday);
                  }),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime date, bool isSelected, bool isToday) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6)
              : isToday
                  ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isToday && !isSelected
              ? Border.all(
                  color: const Color(0xFF3B82F6),
                  width: 1.5,
                )
              : null,
        ),
        child: Center(
          child: Text(
            date.day.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : isToday
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF1E293B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Today button
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedDate = DateTime.now();
                  _displayedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Hari Ini',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Confirm button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                widget.onDateSelected(_selectedDate);
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Pilih Tanggal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
