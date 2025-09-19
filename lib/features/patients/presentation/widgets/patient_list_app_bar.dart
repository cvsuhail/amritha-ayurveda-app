import 'package:flutter/material.dart';

class PatientListAppBar extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onNotificationPressed;

  const PatientListAppBar({
    super.key,
    required this.onBackPressed,
    required this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: onBackPressed,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF2C2C2C),
                size: 20,
              ),
            ),
          ),

          // Notifications Button
          GestureDetector(
            onTap: onNotificationPressed,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF2C2C2C),
                    size: 24,
                  ),
                  // Notification Badge
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53E3E),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
