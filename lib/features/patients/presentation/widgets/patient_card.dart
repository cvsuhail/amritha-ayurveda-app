import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/patient_model.dart';

class PatientCard extends StatefulWidget {
  final PatientModel patient;
  final int index;
  final bool isSelected;
  final VoidCallback onViewDetails;
  final VoidCallback onPatientSelected;

  const PatientCard({
    super.key,
    required this.patient,
    required this.index,
    required this.isSelected,
    required this.onViewDetails,
    required this.onPatientSelected,
  });

  @override
  State<PatientCard> createState() => _PatientCardState();
}

class _PatientCardState extends State<PatientCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    // Staggered animation based on index
    Future.delayed(Duration(milliseconds: 200 + (widget.index * 100)), () {
      _fadeController.forward();
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _onCardPressed() {
    if (_isPressed) return;
    
    setState(() {
      _isPressed = true;
    });
    
    HapticFeedback.lightImpact();
    widget.onPatientSelected();
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
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.isSelected 
                          ? const Color(0xFF2E7D32) 
                          : const Color(0xFFE0E0E0),
                      width: widget.isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isSelected 
                            ? const Color(0xFF2E7D32).withOpacity(0.2)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: widget.isSelected ? 12 : 8,
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

                            // View Details Button
                            GestureDetector(
                              onTap: _onViewDetailsPressed,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'View Booking details',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF2C2C2C),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color(0xFF2E7D32),
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
