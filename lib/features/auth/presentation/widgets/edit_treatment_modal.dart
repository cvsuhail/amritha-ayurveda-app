import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/treatment.dart';

class EditTreatmentModal extends StatefulWidget {
  final Treatment treatment;
  final Function(Treatment) onSave;

  const EditTreatmentModal({
    super.key,
    required this.treatment,
    required this.onSave,
  });

  @override
  State<EditTreatmentModal> createState() => _EditTreatmentModalState();
}

class _EditTreatmentModalState extends State<EditTreatmentModal>
    with TickerProviderStateMixin {
  late int _maleCount;
  late int _femaleCount;
  
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _maleCount = widget.treatment.maleCount;
    _femaleCount = widget.treatment.femaleCount;
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black54,
          child: Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildTreatmentInfo(),
                    const SizedBox(height: 32),
                    _buildPatientsSection(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Edit Treatment',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Color(0xFF666666)),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildTreatmentInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3D704D).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Treatment',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.treatment.name,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          if (widget.treatment.description != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.treatment.description!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPatientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Edit Patient Count',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 16),
        _buildPatientCounter('Male', _maleCount, (count) {
          setState(() => _maleCount = count);
        }),
        const SizedBox(height: 16),
        _buildPatientCounter('Female', _femaleCount, (count) {
          setState(() => _femaleCount = count);
        }),
      ],
    );
  }

  Widget _buildPatientCounter(String gender, int count, Function(int) onChanged) {
    return Row(
      children: [
        Container(
          width: 120,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Text(
            gender,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildCounterButton(
          icon: Icons.remove,
          onPressed: count > 0 ? () => onChanged(count - 1) : null,
        ),
        const SizedBox(width: 16),
        Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildCounterButton(
          icon: Icons.add,
          onPressed: () => onChanged(count + 1),
        ),
      ],
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF3D704D),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isEnabled ? [
          BoxShadow(
            color: const Color(0xFF3D704D).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Icon(
            icon,
            color: isEnabled ? Colors.white : Colors.white.withOpacity(0.5),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final canSave = _maleCount > 0 || _femaleCount > 0;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: canSave ? const Color(0xFF3D704D) : const Color(0xFFCCCCCC),
              boxShadow: canSave ? [
                BoxShadow(
                  color: const Color(0xFF3D704D).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ] : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canSave ? _handleSave : null,
                onTapDown: canSave ? (_) => _scaleController.forward() : null,
                onTapUp: canSave ? (_) => _scaleController.reverse() : null,
                onTapCancel: canSave ? () => _scaleController.reverse() : null,
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Text(
                    'Update',
                    style: TextStyle(
                      color: canSave ? Colors.white : const Color(0xFF666666),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleSave() {
    if (_maleCount > 0 || _femaleCount > 0) {
      HapticFeedback.lightImpact();
      
      // Create updated treatment with new counts
      final updatedTreatment = widget.treatment.copyWith(
        maleCount: _maleCount,
        femaleCount: _femaleCount,
      );
      
      widget.onSave(updatedTreatment);
      Navigator.pop(context);
    }
  }
}

// Helper function to show the modal
Future<void> showEditTreatmentModal(
  BuildContext context,
  Treatment treatment,
  Function(Treatment) onSave,
) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return EditTreatmentModal(
        treatment: treatment,
        onSave: onSave,
      );
    },
  );
}
