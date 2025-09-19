import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/patient_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/pdf_service.dart';

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
  bool _isDownloadingPdf = false;

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Cache formatted date to avoid repeated formatting
  String get _formattedDate => _formatDate(widget.patient.date);

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

  Future<void> _downloadPrescription() async {
    if (_isDownloadingPdf) return;

    setState(() => _isDownloadingPdf = true);
    HapticFeedback.mediumImpact();

    try {
      // Prepare patient data for PDF generation
      final pdfData = {
        'name': widget.patient.name,
        'phone': widget.patient.phone ?? widget.patient.whatsapp ?? '',
        'address': widget.patient.address ?? '',
        'totalAmount': widget.patient.totalAmount ?? '0',
        'discountAmount': widget.patient.discountAmount ?? '0',
        'advanceAmount': widget.patient.advanceAmount ?? '0',
        'balanceAmount': widget.patient.balanceAmount ?? '0',
        'dateNdTime': widget.patient.date.toIso8601String(),
        'branch': 'Kumarakom', // Default branch
        'executive': widget.patient.assignedPerson,
        'payment': 'Cash', // Default payment method
        'treatments': [
          {
            'id': 1,
            'name': widget.patient.packageDescription,
            'maleCount': 1,
            'femaleCount': 0,
          }
        ],
      };

      await PdfService.generateAndDownloadPatientPdf(pdfData);
      
      if (mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Prescription downloaded successfully!'),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.selectionClick();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Failed to download prescription: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloadingPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1), // Updated background color
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2C2C),
                    fontFamily: 'Poppins',
                  ),
                ),
                
                const SizedBox(width: 8),
                
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
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Package Description
                      Text(
                        widget.patient.packageDescription,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF006837), // Green color matching the UI
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                Row(
                  children: [
                    Image.asset(
                      'assets/icons/calendar.png',
                      width: 16,
                      height: 16,
                      color: const Color(0xFFFF6B35), // Orange color
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formattedDate,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 32),

                // Assigned Person with person icon
                Row(
                  children: [
                    Image.asset(
                      'assets/icons/person.png',
                      width: 16,
                      height: 16,
                      color: const Color(0xFFFF6B35), // Orange color
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.patient.assignedPerson,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Divider
            Container(
              height: 1,
              width: double.infinity,
              color: const Color(0xFFE0E0E0),
            ),

            const SizedBox(height: 16),

            // View Booking Details Button
            GestureDetector(
              onTap: _onViewDetailsPressed,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'View Booking details',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2C2C2C),
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    AnimatedRotation(
                      turns: widget.isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.keyboard_arrow_right,
                        color: Color(0xFF006837),
                        size: 20,
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
                        
                        const SizedBox(height: 16),
                        
                        // Download Prescription Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isDownloadingPdf ? null : _downloadPrescription,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: _isDownloadingPdf
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.download, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Download Prescription',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
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
