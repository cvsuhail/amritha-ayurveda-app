import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/patient_model.dart';
import '../../../../core/constants/app_colors.dart';

class PatientCard extends StatefulWidget {
  final PatientModel patient;
  final int index;
  final VoidCallback onViewDetails;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  const PatientCard({
    super.key,
    required this.patient,
    required this.index,
    required this.onViewDetails,
    this.isExpanded = false,
    required this.onToggleExpanded,
  });

  @override
  State<PatientCard> createState() => _PatientCardState();
}

class _PatientCardState extends State<PatientCard> {

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildEnhancedDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onViewDetailsPressed() {
    HapticFeedback.mediumImpact();
    widget.onViewDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8), // Light gray background matching the UI
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row with Index and Patient Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Index Number
                Text(
                  '${widget.index}.',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Patient Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Patient Name
                      Text(
                        widget.patient.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Package Description
                      Text(
                        widget.patient.packageDescription,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Date and Assigned Person Row
            Row(
              children: [
                // Date with calendar icon
                Expanded(
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/calendar.png',
                        width: 16,
                        height: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(widget.patient.date),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),

                // Assigned Person with person icon
                Expanded(
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/person.png',
                        width: 16,
                        height: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.patient.assignedPerson,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // View Booking Details Button
            GestureDetector(
              onTap: _onViewDetailsPressed,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'View Booking details',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    AnimatedRotation(
                      turns: widget.isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_right_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded Details Section
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              height: widget.isExpanded ? null : 0,
              child: widget.isExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        
                        // Booking Details Container
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.divider.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Patient Details
                              if (widget.patient.phone != null && widget.patient.phone!.isNotEmpty)
                                _buildEnhancedDetailRow(
                                  'Phone:',
                                  widget.patient.phone!,
                                  Icons.phone_outlined,
                                ),
                              
                              if (widget.patient.address != null && widget.patient.address!.isNotEmpty)
                                _buildEnhancedDetailRow(
                                  'Address:',
                                  widget.patient.address!,
                                  Icons.location_on_outlined,
                                ),
                              
                              if (widget.patient.totalAmount != null && widget.patient.totalAmount!.isNotEmpty)
                                _buildEnhancedDetailRow(
                                  'Total Amount:',
                                  '₹${widget.patient.totalAmount}',
                                  Icons.account_balance_wallet_outlined,
                                ),
                              
                              if (widget.patient.advanceAmount != null && widget.patient.advanceAmount!.isNotEmpty)
                                _buildEnhancedDetailRow(
                                  'Advance:',
                                  '₹${widget.patient.advanceAmount}',
                                  Icons.payment_outlined,
                                ),
                              
                              if (widget.patient.balanceAmount != null && widget.patient.balanceAmount!.isNotEmpty)
                                _buildEnhancedDetailRow(
                                  'Balance:',
                                  '₹${widget.patient.balanceAmount}',
                                  Icons.account_balance_outlined,
                                ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
