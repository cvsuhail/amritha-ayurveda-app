import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/minimal_text_field.dart';
import '../widgets/add_treatment_modal.dart';
import '../widgets/edit_treatment_modal.dart';
import '../widgets/success_modal.dart';
import '../../../../core/models/branch.dart';
import '../../../../core/models/treatment.dart';
import '../../../../core/services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for all form fields
  final _nameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _addressController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _discountAmountController = TextEditingController();
  final _advanceAmountController = TextEditingController();
  final _balanceAmountController = TextEditingController();
  
  // Field keys for validation
  final _nameFieldKey = GlobalKey<MinimalTextFieldState>();
  final _whatsappFieldKey = GlobalKey<MinimalTextFieldState>();
  final _addressFieldKey = GlobalKey<MinimalTextFieldState>();
  final _totalAmountFieldKey = GlobalKey<MinimalTextFieldState>();
  final _discountAmountFieldKey = GlobalKey<MinimalTextFieldState>();
  final _advanceAmountFieldKey = GlobalKey<MinimalTextFieldState>();
  final _balanceAmountFieldKey = GlobalKey<MinimalTextFieldState>();
  
  // Dropdown selections
  String? _selectedLocation;
  String? _selectedBranch;
  String _selectedPaymentOption = 'Cash';
  DateTime? _selectedDate;
  String? _selectedHour;
  String? _selectedMinute;
  
  // Branch data
  List<Branch> _branches = [];
  bool _isBranchLoading = false;
  String? _branchError;
  
  // Loading state
  bool _isLoading = false;
  
  // Treatment data
  List<Treatment> _treatments = [];
  
  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _staggerController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _staggerAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _setupAmountCalculation();
    _fetchBranches();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _staggerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      _staggerController.forward();
    });
  }

  void _setupAmountCalculation() {
    _totalAmountController.addListener(_calculateBalance);
    _discountAmountController.addListener(_calculateBalance);
    _advanceAmountController.addListener(_calculateBalance);
  }

  void _calculateBalance() {
    final total = double.tryParse(_totalAmountController.text) ?? 0.0;
    final discount = double.tryParse(_discountAmountController.text) ?? 0.0;
    final advance = double.tryParse(_advanceAmountController.text) ?? 0.0;
    
    final balance = total - discount - advance;
    _balanceAmountController.text = balance > 0 ? balance.toString() : '0';
  }

  Future<void> _fetchBranches() async {
    if (!mounted) return;
    
    setState(() {
      _isBranchLoading = true;
      _branchError = null;
    });

    try {
      final result = await ApiService.getBranchList();
      
      if (!mounted) return;

      if (result['success'] == true) {
        final branchData = result['data'] as List;
        setState(() {
          _branches = branchData.map((json) => Branch.fromJson(json)).toList();
          _isBranchLoading = false;
        });
      } else {
        setState(() {
          _branchError = result['message'] ?? 'Failed to load branches';
          _isBranchLoading = false;
        });
        
        if (result['requiresAuth'] == true) {
          // Handle authentication required - could navigate to login
          _showErrorSnackBar('Session expired. Please login again.');
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _branchError = 'Failed to load branches. Please try again.';
        _isBranchLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _staggerController.dispose();
    
    _nameController.dispose();
    _whatsappController.dispose();
    _addressController.dispose();
    _totalAmountController.dispose();
    _discountAmountController.dispose();
    _advanceAmountController.dispose();
    _balanceAmountController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/icons/back.png',
            width: 24,
            height: 24,
            color: const Color(0xFF333333),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Register',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: const Color(0xFF333333),
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/icons/notificaion.png',
              width: 24,
              height: 24,
              color: const Color(0xFF333333),
            ),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32.0 : 20.0,
                vertical: 16.0,
              ),
              child: AnimatedBuilder(
                animation: _staggerAnimation,
                builder: (context, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAnimatedSection(_buildBasicInfoSection(), 0),
                      const SizedBox(height: 24),
                      _buildAnimatedSection(_buildLocationSection(), 1),
                      const SizedBox(height: 24),
                      _buildAnimatedSection(_buildTreatmentsSection(), 2),
                      const SizedBox(height: 24),
                      _buildAnimatedSection(_buildAmountSection(), 3),
                      const SizedBox(height: 24),
                      _buildAnimatedSection(_buildPaymentSection(), 4),
                      const SizedBox(height: 24),
                      _buildAnimatedSection(_buildDateTimeSection(), 5),
                      const SizedBox(height: 32),
                      _buildAnimatedSection(_buildSaveButton(), 6),
                      const SizedBox(height: 16),
                      // Debug connectivity test button (only in debug mode)
                      if (kDebugMode) ...[
                        _buildAnimatedSection(_buildDebugButton(), 7),
                        const SizedBox(height: 8),
                        _buildAnimatedSection(_buildEndpointTestButton(), 8),
                        const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection(Widget child, int index) {
    const double staggerDelay = 0.15;
    final animationStart = (index * staggerDelay).clamp(0.0, 1.0);
    final animationEnd = ((index * staggerDelay) + 0.3).clamp(0.0, 1.0);
    
    final opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: Interval(animationStart, animationEnd, curve: Curves.easeOut),
    ));
    
    final slideOffset = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: Interval(animationStart, animationEnd, curve: Curves.easeOutCubic),
    ));
    
    return SlideTransition(
      position: slideOffset,
      child: FadeTransition(
        opacity: opacity,
        child: child,
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Name'),
        const SizedBox(height: 8),
        MinimalTextField(
          key: _nameFieldKey,
          controller: _nameController,
          hintText: 'Enter your full name',
          validator: _validateName,
        ),
        
        const SizedBox(height: 20),
        _buildSectionLabel('Whatsapp Number'),
        const SizedBox(height: 8),
        MinimalTextField(
          key: _whatsappFieldKey,
          controller: _whatsappController,
          hintText: 'Enter your Whatsapp number',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(15), // Reasonable phone number length
          ],
          validator: _validateWhatsapp,
        ),
        
        const SizedBox(height: 20),
        _buildSectionLabel('Address'),
        const SizedBox(height: 8),
        MinimalTextField(
          key: _addressFieldKey,
          controller: _addressController,
          hintText: 'Enter your full address',
          maxLines: 2,
          validator: _validateAddress,
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Location'),
        const SizedBox(height: 8),
        _buildDropdown(
          value: _selectedLocation,
          hint: 'Choose your location',
          items: ['Kochi', 'Thiruvananthapuram', 'Kozhikode', 'Thrissur'],
          onChanged: (value) => setState(() => _selectedLocation = value),
        ),
        
        const SizedBox(height: 20),
        _buildSectionLabel('Branch'),
        const SizedBox(height: 8),
        _buildBranchDropdown(),
      ],
    );
  }

  Widget _buildTreatmentsSection() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isTablet = screenWidth > 600;
    final isMobile = screenWidth < 480;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Treatments'),
        const SizedBox(height: 16),
        
        // Responsive treatment list
        if (isTablet && _treatments.length > 1)
          // Grid layout for tablets with multiple treatments
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 1.2 : 1.5,
            ),
            itemCount: _treatments.length,
            itemBuilder: (context, index) {
              return _buildTreatmentItem(_treatments[index], index);
            },
          )
        else
          // Single column layout for mobile or single treatment
          Column(
            children: _treatments.asMap().entries.map((entry) {
              final index = entry.key;
              final treatment = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTreatmentItem(treatment, index),
              );
            }).toList(),
          ),
        
        const SizedBox(height: 20),
        _buildAddTreatmentButton(),
      ],
    );
  }

  Widget _buildTreatmentItem(Treatment treatment, int index) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isTablet = screenWidth > 600;
    final isMobile = screenWidth < 480;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3D704D).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3D704D).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row with number and actions
          Row(
            children: [
              Container(
                width: isTablet ? 32 : 28,
                height: isTablet ? 32 : 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3D704D), Color(0xFF2A5A3A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3D704D).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(
                    icon: Icons.edit_outlined,
                    color: const Color(0xFF3D704D),
                    onTap: () => _editTreatment(index),
                  ),
                  if (_treatments.length > 1) ...[
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.close,
                      color: const Color(0xFFFF6B6B),
                      onTap: () {
                        setState(() => _treatments.removeAt(index));
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Treatment name
          Text(
            treatment.name,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: isTablet ? 16 : 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 16),
          
          // Gender counters
          if (isMobile)
            Column(
              children: [
                _buildGenderCounter('Male', treatment.maleCount, (count) {
                  setState(() => treatment.maleCount = count);
                }),
                const SizedBox(height: 12),
                _buildGenderCounter('Female', treatment.femaleCount, (count) {
                  setState(() => treatment.femaleCount = count);
                }),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildGenderCounter('Male', treatment.maleCount, (count) {
                    setState(() => treatment.maleCount = count);
                  }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGenderCounter('Female', treatment.femaleCount, (count) {
                    setState(() => treatment.femaleCount = count);
                  }),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildGenderCounter(String gender, int count, Function(int) onChanged) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isMobile = screenWidth < 480;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          gender,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF3D704D).withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
            children: [
              _buildCounterButton(
                icon: Icons.remove,
                onTap: () => count > 0 ? onChanged(count - 1) : null,
                isEnabled: count > 0,
                isLeft: true,
              ),
              Container(
                width: isMobile ? null : 40,
                constraints: isMobile ? const BoxConstraints(minWidth: 40) : null,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Center(
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ),
              _buildCounterButton(
                icon: Icons.add,
                onTap: () => onChanged(count + 1),
                isEnabled: true,
                isLeft: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isEnabled,
    required bool isLeft,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isLeft ? 12 : 0),
          bottomLeft: Radius.circular(isLeft ? 12 : 0),
          topRight: Radius.circular(isLeft ? 0 : 12),
          bottomRight: Radius.circular(isLeft ? 0 : 12),
        ),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isEnabled 
                ? const Color(0xFF3D704D).withOpacity(0.1)
                : const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isLeft ? 12 : 0),
              bottomLeft: Radius.circular(isLeft ? 12 : 0),
              topRight: Radius.circular(isLeft ? 0 : 12),
              bottomRight: Radius.circular(isLeft ? 0 : 12),
            ),
          ),
          child: Icon(
            icon,
            color: isEnabled 
                ? const Color(0xFF3D704D)
                : const Color(0xFFCCCCCC),
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildAddTreatmentButton() {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isTablet = screenWidth > 600;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _addTreatment,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 16 : 14,
            horizontal: 20,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF3D704D).withOpacity(0.08),
                const Color(0xFF3D704D).withOpacity(0.12),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF3D704D).withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3D704D).withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF3D704D).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.add,
                  color: Color(0xFF3D704D),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Add Treatment',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: isTablet ? 16 : 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3D704D),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Total Amount'),
        const SizedBox(height: 8),
        MinimalTextField(
          key: _totalAmountFieldKey,
          controller: _totalAmountController,
          hintText: 'Enter total amount',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10), // Reasonable amount limit
          ],
          validator: _validateAmount,
        ),
        
        const SizedBox(height: 20),
        _buildSectionLabel('Discount Amount'),
        const SizedBox(height: 8),
        MinimalTextField(
          key: _discountAmountFieldKey,
          controller: _discountAmountController,
          hintText: 'Enter discount amount',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10), // Reasonable amount limit
          ],
        ),
        
        const SizedBox(height: 20),
        _buildSectionLabel('Advance Amount'),
        const SizedBox(height: 8),
        MinimalTextField(
          key: _advanceAmountFieldKey,
          controller: _advanceAmountController,
          hintText: 'Enter advance amount',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10), // Reasonable amount limit
          ],
          validator: _validateAmount,
        ),
        
        const SizedBox(height: 20),
        _buildSectionLabel('Balance Amount'),
        const SizedBox(height: 8),
        MinimalTextField(
          key: _balanceAmountFieldKey,
          controller: _balanceAmountController,
          hintText: 'Balance amount',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10), // Reasonable amount limit
          ],
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Payment Option'),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildPaymentOption('Cash'),
            const SizedBox(width: 20),
            _buildPaymentOption('Card'),
            const SizedBox(width: 20),
            _buildPaymentOption('UPI'),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String option) {
    final isSelected = _selectedPaymentOption == option;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentOption = option),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFF3D704D) : const Color(0xFFCCCCCC),
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3D704D),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            option,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? const Color(0xFF3D704D) : const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Treatment Date'),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select date',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: _selectedDate != null ? const Color(0xFF333333) : const Color(0xFF999999),
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today, color: Color(0xFF3D704D), size: 20),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        _buildSectionLabel('Treatment Time'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTimeDropdown(
                'Hour', 
                List.generate(24, (i) => i.toString().padLeft(2, '0')),
                _selectedHour,
                (value) => setState(() => _selectedHour = value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTimeDropdown(
                'Minutes', 
                List.generate(60, (i) => i.toString().padLeft(2, '0')),
                _selectedMinute,
                (value) => setState(() => _selectedMinute = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeDropdown(String label, List<String> items, String? selectedValue, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              hint: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF999999),
                ),
              ),
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF3D704D)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF3D704D),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3D704D).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isLoading ? null : _handleSave,
                onTapDown: _isLoading ? null : (_) => _scaleController.forward(),
                onTapUp: _isLoading ? null : (_) => _scaleController.reverse(),
                onTapCancel: _isLoading ? null : () => _scaleController.reverse(),
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: _isLoading 
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
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

  Widget _buildDebugButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.orange.withOpacity(0.1),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _testConnectivity,
          borderRadius: BorderRadius.circular(12),
          child: const Center(
            child: Text(
              'Test API Connectivity (Debug)',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEndpointTestButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.withOpacity(0.1),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _testEndpoints,
          borderRadius: BorderRadius.circular(12),
          child: const Center(
            child: Text(
              'Test Patient Endpoints (Debug)',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Color(0xFF999999),
            ),
          ),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF3D704D)),
        ),
      ),
    );
  }

  Widget _buildBranchDropdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: _isBranchLoading
          ? Container(
              height: 48,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF3D704D).withOpacity(0.6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Loading branches...',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            )
          : _branchError != null
              ? Container(
                  height: 48,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Color(0xFFFF6B6B),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _branchError!,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Color(0xFFFF6B6B),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _fetchBranches,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.refresh,
                              size: 16,
                              color: const Color(0xFF3D704D).withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedBranch,
                    hint: const Text(
                      'Select the branch',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                    items: _branches.map((Branch branch) {
                      return DropdownMenuItem<String>(
                        value: branch.name,
                        child: Text(
                          branch.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Color(0xFF333333),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: _branches.isEmpty
                        ? null
                        : (String? value) {
                            setState(() => _selectedBranch = value);
                          },
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF3D704D)),
                  ),
                ),
    );
  }

  // Validation methods
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateWhatsapp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'WhatsApp number is required';
    }
    if (value.trim().length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    if (value.trim().length < 10) {
      return 'Please enter a complete address';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  // Action methods
  void _addTreatment() {
    showAddTreatmentModal(
      context,
      (Treatment treatment) {
        setState(() {
          _treatments.add(treatment);
        });
      },
    );
  }

  void _editTreatment(int index) {
    final currentTreatment = _treatments[index];
    showEditTreatmentModal(
      context,
      currentTreatment,
      (Treatment updatedTreatment) {
        setState(() {
          _treatments[index] = updatedTreatment;
        });
      },
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3D704D),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF333333),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Helper method to format date and time according to API specification
  String _formatDateTime() {
    if (_selectedDate == null || _selectedHour == null || _selectedMinute == null) {
      return '';
    }
    
    // Create DateTime object with selected date and time
    final hour = int.parse(_selectedHour!);
    final minute = int.parse(_selectedMinute!);
    
    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      hour,
      minute,
    );
    
    // Format as ISO string to match existing data format (2025-09-19T09:13:00)
    // Based on the PatientList response, the API expects ISO format, not DD/MM/YYYY-HH:MM AM/PM
    final isoString = dateTime.toIso8601String();
    
    // Remove milliseconds and 'Z' to match the format seen in existing data
    final formattedDateTime = isoString.split('.')[0];
    
    if (kDebugMode) {
      print('Original API doc format would be: ${_formatDateTimeOriginal()}');
      print('Using ISO format instead: $formattedDateTime');
    }
    
    return formattedDateTime;
  }
  
  // Keep the original format as backup
  String _formatDateTimeOriginal() {
    if (_selectedDate == null || _selectedHour == null || _selectedMinute == null) {
      return '';
    }
    
    final day = _selectedDate!.day.toString().padLeft(2, '0');
    final month = _selectedDate!.month.toString().padLeft(2, '0');
    final year = _selectedDate!.year.toString();
    
    final hour = int.parse(_selectedHour!);
    final minute = _selectedMinute!.padLeft(2, '0');
    
    // Convert 24-hour to 12-hour format with AM/PM
    String period = 'AM';
    int displayHour = hour;
    
    if (hour == 0) {
      displayHour = 12;
    } else if (hour > 12) {
      displayHour = hour - 12;
      period = 'PM';
    } else if (hour == 12) {
      period = 'PM';
    }
    
    final formattedHour = displayHour.toString().padLeft(2, '0');
    
    return '$day/$month/$year-$formattedHour:$minute $period';
  }
  
  // Helper method to get treatment IDs for male treatments
  String _getMaleTreatmentIds() {
    final maleIds = <String>[];
    for (final treatment in _treatments) {
      if (treatment.maleCount > 0) {
        // Add the treatment ID for each male count
        for (int i = 0; i < treatment.maleCount; i++) {
          maleIds.add(treatment.id.toString());
        }
      }
    }
    return maleIds.join(',');
  }
  
  // Helper method to get treatment IDs for female treatments
  String _getFemaleTreatmentIds() {
    final femaleIds = <String>[];
    for (final treatment in _treatments) {
      if (treatment.femaleCount > 0) {
        // Add the treatment ID for each female count
        for (int i = 0; i < treatment.femaleCount; i++) {
          femaleIds.add(treatment.id.toString());
        }
      }
    }
    return femaleIds.join(',');
  }
  
  // Helper method to get all treatment IDs
  String _getAllTreatmentIds() {
    final treatmentIds = <String>[];
    for (final treatment in _treatments) {
      final totalCount = treatment.maleCount + treatment.femaleCount;
      if (totalCount > 0) {
        // Add the treatment ID for total count
        for (int i = 0; i < totalCount; i++) {
          treatmentIds.add(treatment.id.toString());
        }
      }
    }
    return treatmentIds.join(',');
  }
  
  // Helper method to get executive name (using selected branch as executive for now)
  String _getExecutiveName() {
    // For now, use the selected branch as executive name
    // This might need to be changed based on actual business logic
    return _selectedBranch ?? 'Default Executive';
  }
  
  // Helper method to get branch ID from branch name
  String _getBranchId() {
    if (_selectedBranch == null || _branches.isEmpty) {
      return '';
    }
    
    // Find the branch object by name and return its ID
    final branch = _branches.firstWhere(
      (branch) => branch.name == _selectedBranch,
      orElse: () => Branch(id: 0, name: ''),
    );
    
    if (kDebugMode) {
      print('Selected branch name: $_selectedBranch');
      print('Found branch ID: ${branch.id}');
    }
    
    return branch.id.toString();
  }

  void _testConnectivity() async {
    if (kDebugMode) {
      print('Testing API connectivity...');
    }
    
    try {
      final result = await ApiService.testConnectivity();
      
      if (mounted) {
        if (result['success'] == true) {
          _showSuccessSnackBar('✅ API connectivity test successful!');
        } else {
          _showErrorSnackBar('❌ Connectivity test failed: ${result['message']}');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('❌ Connectivity test error: $e');
      }
    }
  }

  void _testEndpoints() async {
    if (kDebugMode) {
      print('Testing /PatientUpdate endpoint specifically...');
    }
    
    try {
      // Test the PatientUpdate endpoint specifically since it exists in Django URLs
      final result = await ApiService.testEndpoint('/PatientUpdate', method: 'POST');
      
      if (mounted) {
        final statusCode = result['statusCode'] ?? 'unknown';
        final contentType = result['contentType'] ?? 'unknown';
        final isJson = result['isJson'] ?? false;
        
        if (statusCode == 200) {
          _showSuccessSnackBar('✅ /PatientUpdate: Works! ($statusCode - ${isJson ? 'JSON' : contentType})');
        } else if (statusCode == 405) {
          _showErrorSnackBar('⚠️ /PatientUpdate: Method Not Allowed (405) - Endpoint exists but doesn\'t accept POST');
        } else if (statusCode == 400) {
          _showErrorSnackBar('⚠️ /PatientUpdate: Bad Request (400) - Wrong data format');
        } else if (statusCode == 422) {
          _showErrorSnackBar('⚠️ /PatientUpdate: Unprocessable Entity (422) - Invalid data');
        } else {
          _showErrorSnackBar('⚠️ /PatientUpdate: $statusCode (${isJson ? 'JSON' : contentType})');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('❌ /PatientUpdate: Error - $e');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF3D704D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _handleSave() async {
    if (_isLoading) return;
    
    HapticFeedback.mediumImpact();
    
    // Validate required fields
    final nameValid = _nameFieldKey.currentState?.validate() ?? false;
    final whatsappValid = _whatsappFieldKey.currentState?.validate() ?? false;
    final addressValid = _addressFieldKey.currentState?.validate() ?? false;
    final totalAmountValid = _totalAmountFieldKey.currentState?.validate() ?? false;
    final advanceAmountValid = _advanceAmountFieldKey.currentState?.validate() ?? false;
    
    // Check dropdowns
    if (_selectedLocation == null) {
      _showErrorSnackBar('Please select a location');
      return;
    }
    
    if (_selectedBranch == null) {
      _showErrorSnackBar('Please select a branch');
      return;
    }
    
    if (_selectedDate == null) {
      _showErrorSnackBar('Please select a treatment date');
      return;
    }
    
    if (_selectedHour == null || _selectedMinute == null) {
      _showErrorSnackBar('Please select a treatment time');
      return;
    }
    
    if (!nameValid || !whatsappValid || !addressValid || !totalAmountValid || !advanceAmountValid) {
      _showErrorSnackBar('Please fix the errors in the form');
      return;
    }
    
    // Check if treatments are selected
    if (_treatments.isEmpty) {
      _showErrorSnackBar('Please add at least one treatment');
      return;
    }
    
    // Check if at least one treatment has male or female count > 0
    bool hasValidTreatment = _treatments.any((treatment) => 
        treatment.maleCount > 0 || treatment.femaleCount > 0);
    
    if (!hasValidTreatment) {
      _showErrorSnackBar('Please set male or female count for at least one treatment');
      return;
    }
    
    // Start loading
    setState(() => _isLoading = true);
    
    try {
      // Prepare API call data
      final dateTime = _formatDateTime();
      final maleTreatmentIds = _getMaleTreatmentIds();
      final femaleTreatmentIds = _getFemaleTreatmentIds();
      final allTreatmentIds = _getAllTreatmentIds();
      final executive = _getExecutiveName();
      final branchId = _getBranchId(); // Get branch ID instead of name
      
      if (kDebugMode) {
        print('=== PATIENT REGISTRATION DATA DEBUG ===');
        print('Name: ${_nameController.text.trim()}');
        print('Executive: $executive');
        print('Payment: $_selectedPaymentOption');
        print('Phone: ${_whatsappController.text.trim()}');
        print('Address: ${_addressController.text.trim()}');
        print('Total Amount: ${_totalAmountController.text}');
        print('Discount Amount: ${_discountAmountController.text}');
        print('Advance Amount: ${_advanceAmountController.text}');
        print('Balance Amount: ${_balanceAmountController.text}');
        print('Date Time: $dateTime');
        print('Branch Name: $_selectedBranch');
        print('Branch ID: $branchId'); // Log both name and ID
        print('All Treatment IDs: $allTreatmentIds');
        print('Male Treatment IDs: $maleTreatmentIds');
        print('Female Treatment IDs: $femaleTreatmentIds');
        print('Number of treatments: ${_treatments.length}');
        for (int i = 0; i < _treatments.length; i++) {
          print('Treatment $i: ID=${_treatments[i].id}, Name=${_treatments[i].name}, Male=${_treatments[i].maleCount}, Female=${_treatments[i].femaleCount}');
        }
        print('=========================================');
      }
      
      // Validate branch ID
      if (branchId.isEmpty || branchId == '0') {
        _showErrorSnackBar('Please select a valid branch');
        return;
      }
      
      // Call the patient registration API
      final result = await ApiService.registerPatient(
        name: _nameController.text.trim(),
        executive: executive,
        payment: _selectedPaymentOption,
        phone: _whatsappController.text.trim(),
        address: _addressController.text.trim(),
        totalAmount: double.parse(_totalAmountController.text),
        discountAmount: double.tryParse(_discountAmountController.text) ?? 0.0,
        advanceAmount: double.parse(_advanceAmountController.text),
        balanceAmount: double.tryParse(_balanceAmountController.text) ?? 0.0,
        dateNdTime: dateTime,
        branch: branchId, // Send branch ID instead of name
        treatments: allTreatmentIds,
        male: maleTreatmentIds.isNotEmpty ? maleTreatmentIds : null,
        female: femaleTreatmentIds.isNotEmpty ? femaleTreatmentIds : null,
      );
      
      if (mounted) {
        if (result['success'] == true) {
          // Success haptic feedback
          HapticFeedback.lightImpact();
          
          // Prepare patient data for PDF generation
          final pdfData = {
            'name': _nameController.text.trim(),
            'executive': _getExecutiveName(),
            'payment': _selectedPaymentOption,
            'phone': _whatsappController.text.trim(),
            'address': _addressController.text.trim(),
            'totalAmount': _totalAmountController.text,
            'discountAmount': _discountAmountController.text.isNotEmpty ? _discountAmountController.text : '0',
            'advanceAmount': _advanceAmountController.text,
            'balanceAmount': _balanceAmountController.text,
            'dateNdTime': _formatDateTime(),
            'branch': _selectedBranch,
            'treatments': _treatments.map((t) => {
              'id': t.id,
              'name': t.name,
              'maleCount': t.maleCount,
              'femaleCount': t.femaleCount,
            }).toList(),
          };
          
          // Stop loading before showing modal
          setState(() => _isLoading = false);
          
          // Show success modal with PDF download option
          showSuccessModal(context, pdfData);
          return; // Early return to avoid executing finally block
        } else {
          // Handle API error
          final errorMessage = result['message'] ?? 'Failed to register patient. Please try again.';
          
          // Check if authentication is required
          if (result['requiresAuth'] == true) {
            _showErrorSnackBar('Session expired. Please login again.');
            // Could navigate to login page here if needed
          } else {
            _showErrorSnackBar(errorMessage);
          }
        }
      }
    } catch (e) {
      // Error handling for unexpected errors
      if (mounted) {
        _showErrorSnackBar('An unexpected error occurred. Please try again.');
        if (kDebugMode) {
          print('Error in _handleSave: $e');
        }
      }
    } finally {
      // Stop loading
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
