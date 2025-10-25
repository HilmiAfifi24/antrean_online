import 'package:flutter/material.dart';

class QueueCard extends StatelessWidget {
  final int queueNumber;
  final String patientName;
  final String complaint;
  final String status;
  const QueueCard({
    super.key,
    required this.queueNumber,
    required this.patientName,
    required this.complaint,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isCalled = status == 'dipanggil';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCalled ? const Color(0xFF4CAF50) : Colors.grey[300]!,
          width: isCalled ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Queue Number
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isCalled 
                  ? const Color(0xFF4CAF50) 
                  : const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                queueNumber.toString().padLeft(3, '0'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Patient Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        patientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCalled)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Dipanggil',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  complaint,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
