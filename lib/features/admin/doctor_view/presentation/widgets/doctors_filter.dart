// import 'package:antrean_online/features/admin/doctor_view/presentation/controllers/doctor_admin_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class DoctorsFilter extends StatelessWidget {
//   const DoctorsFilter({super.key}); 

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 50,
//       child: GetBuilder<DoctorController>(
//         builder: (controller) {
//           final specializations = ['Semua', ...controller.specializations];
          
//           return ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: specializations.length,
//             itemBuilder: (context, index) {
//               final specialization = specializations[index];
//               final isSelected = index == 0 
//                   ? controller.searchController.text.isEmpty && controller.selectedSpecialization.isEmpty
//                   : controller.selectedSpecialization == specialization;

//               return Padding(
//                 padding: EdgeInsets.only(
//                   right: index == specializations.length - 1 ? 0 : 12,
//                 ),
//                 child: FilterChip(
//                   label: Text(specialization),
//                   selected: isSelected,
//                   onSelected: (selected) {
//                     if (selected) {
//                       if (specialization == 'Semua') {
//                         controller.setSelectedSpecialization('');
//                         controller.clearSearch();
//                       } else {
//                         controller.setSelectedSpecialization(specialization);
//                         controller.filterBySpecialization(specialization);
//                       }
//                     }
//                   },
//                   selectedColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
//                   checkmarkColor: const Color(0xFF3B82F6),
//                   labelStyle: TextStyle(
//                     color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
//                     fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                   ),
//                   side: BorderSide(
//                     color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }