import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CurrentQueueCard extends StatelessWidget {
  const CurrentQueueCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('queues')
          .where('doctor_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .where('status', isEqualTo: 'dipanggil')
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Log error for diagnostics (missing composite index etc.)
          // ignore: avoid_print
          print('[CurrentQueueCard] snapshot error: ${snapshot.error}');
          return const SizedBox.shrink();
        }

        final hasCurrentQueue = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: hasCurrentQueue
                  ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                  : [Colors.grey[300]!, Colors.grey[400]!],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (hasCurrentQueue ? Colors.green : Colors.grey).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.medical_services,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Antrean Saat Ini',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (hasCurrentQueue) ...[
                Builder(
                  builder: (context) {
                    final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                    final queueNumber = data['queue_number'] ?? 0;
                    final patientName = data['patient_name'] ?? '';
                    return Column(
                      children: [
                        Text(
                          queueNumber.toString().padLeft(3, '0'),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          patientName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ] else ...[
                Icon(
                  Icons.event_busy,
                  size: 48,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 8),
                Text(
                  'Belum ada yang dipanggil',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
