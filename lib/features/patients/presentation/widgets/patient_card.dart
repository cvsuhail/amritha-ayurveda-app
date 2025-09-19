import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/patient_model.dart';

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

class _PatientCardState extends State<PatientCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF2C2C2C),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF2C2C2C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onCardPressed() {
    if (_isPressed) return;
    
    setState(() {
      _isPressed = true;
    });
    
    HapticFeedback.lightImpact();
    widget.onToggleExpanded();
    _scaleController.forward().then((_) {
      _scaleController.reverse().then((_) {
        setState(() {
          _isPressed = false;
        });
      });
    });
  }

  void _onViewDetailsPressed() {
    HapticFeedback.mediumImpact();
    widget.onViewDetails();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _onCardPressed,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Patient Number and Name
                            Row(
                              children: [
                                Text(
                                  '${widget.index}.',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C2C2C),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.patient.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C2C2C),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Package Description
                            Text(
                              widget.patient.packageDescription,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 12),

                            // Date and Assigned Person
                            Row(
                              children: [
                                // Date
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      color: Color(0xFFFF9800),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatDate(widget.patient.date),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFFF9800),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(width: 24),

                                // Assigned Person
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: Color(0xFFFF9800),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.patient.assignedPerson,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFFF9800),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Divider
                            Container(
                              height: 1,
                              color: const Color(0xFFE0E0E0),
                            ),

                            const SizedBox(height: 8),

                            // Expand/Collapse Button
                            GestureDetector(
                              onTap: _onViewDetailsPressed,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.isExpanded ? 'Hide details' : 'View Booking details',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF2C2C2C),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    AnimatedRotation(
                                      turns: widget.isExpanded ? 0.5 : 0,
                                      duration: const Duration(milliseconds: 200),
                                      child: const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Color(0xFF2E7D32),
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Expanded Details Section
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              height: widget.isExpanded ? null : 0,
                              child: widget.isExpanded
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 12),
                                        const Divider(color: Color(0xFFE0E0E0)),
                                        const SizedBox(height: 12),
                                        
                                        // Phone Number
                                        if (widget.patient.phone != null && widget.patient.phone!.isNotEmpty)
                                          _buildDetailRow('Phone:', widget.patient.phone!),
                                        
                                        // Total Amount
                                        if (widget.patient.totalAmount != null && widget.patient.totalAmount!.isNotEmpty)
                                          _buildDetailRow('Total Amount:', '₹${widget.patient.totalAmount}'),
                                        
                                        // Additional details can be added here
                                        const SizedBox(height: 8),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }
}
