// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/pre_register_controller.dart';
import '../models/pre_register_model.dart';
import '../services/responsive_service.dart';
import '../utils/promo_constants.dart';
import '../utils/promo_helpers.dart';
import '../utils/responsive_helpers.dart';

class PreRegisterDialogWidget extends StatefulWidget {
  final PreRegisterController controller;

  const PreRegisterDialogWidget({
    super.key,
    required this.controller,
  });

  @override
  State<PreRegisterDialogWidget> createState() => _PreRegisterDialogWidgetState();
}

class _PreRegisterDialogWidgetState extends State<PreRegisterDialogWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: PromoConstants.defaultAnimation,
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: PromoConstants.fastAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: PromoConstants.defaultCurve,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _slideAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildDialog(context),
          ),
        );
      },
    );
  }

  Widget _buildDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: ResponsiveHelpers.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(PromoConstants.defaultPadding),
        tablet: const EdgeInsets.all(PromoConstants.cardPadding),
        desktop: const EdgeInsets.all(PromoConstants.largeSpacing),
      ),
      child: ConstrainedBox(
        constraints: ResponsiveHelpers.getResponsiveDialogConstraints(context),
        child: Container(
          decoration: BoxDecoration(
            color: PromoConstants.whiteColor,
            borderRadius: BorderRadius.circular(PromoConstants.cardBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                spreadRadius: 3,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (context, child) {
              return ResponsiveHelpers.buildResponsiveLayout(
                context,
                builder: (context, constraints, breakpoint) {
                  switch (breakpoint) {
                    case ResponsiveBreakpoint.mobile:
                      return _buildMobileLayout(context);
                    case ResponsiveBreakpoint.tablet:
                    case ResponsiveBreakpoint.desktop:
                    case ResponsiveBreakpoint.ultrawide:
                      return _buildDesktopLayout(context);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(PromoConstants.cardPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const SizedBox(height: PromoConstants.largeSpacing),
            _buildForm(context),
            const SizedBox(height: PromoConstants.largeSpacing),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(PromoConstants.cardPadding + 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                const SizedBox(height: PromoConstants.itemSpacing),
                _buildBenefits(context),
              ],
            ),
          ),
          const SizedBox(width: PromoConstants.largeSpacing),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildForm(context),
                const SizedBox(height: PromoConstants.largeSpacing),
                _buildActions(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Close button
        Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: _closeDialog,
            borderRadius: BorderRadius.circular(PromoConstants.iconBorderRadius),
            child: Padding(
              padding: const EdgeInsets.all(PromoConstants.smallSpacing),
              child: Icon(
                Icons.close,
                size: ResponsiveHelpers.getResponsiveIconSize(context, 24),
                color: PromoConstants.textColor.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
        
        // Icon
        Container(
          width: ResponsiveHelpers.getResponsiveIconSize(context, 80),
          height: ResponsiveHelpers.getResponsiveIconSize(context, 80),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PromoConstants.primaryColor,
                PromoConstants.accentColor,
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications_active,
            size: ResponsiveHelpers.getResponsiveIconSize(context, 40),
            color: PromoConstants.whiteColor,
          ),
        ),
        
        const SizedBox(height: PromoConstants.itemSpacing),
        
        // Title
        Text(
          'Seja o primeiro a saber!',
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 24),
            fontWeight: FontWeight.bold,
            color: PromoConstants.textColor,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: PromoConstants.smallSpacing),
        
        // Subtitle
        Text(
          'Cadastre-se para receber uma notificação assim que o PetiVeti estiver disponível.',
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 16),
            color: PromoConstants.textColor.withValues(alpha: 0.7),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name field
        _buildFormField(
          context,
          label: 'Nome completo',
          hint: 'Digite seu nome',
          icon: Icons.person_outline,
          value: widget.controller.name,
          error: widget.controller.formErrors['name'],
          onChanged: (value) => widget.controller.updateName(value),
        ),
        
        const SizedBox(height: PromoConstants.inputSpacing),
        
        // Email field
        _buildFormField(
          context,
          label: 'Email',
          hint: 'Digite seu email',
          icon: Icons.email_outlined,
          value: widget.controller.email,
          error: widget.controller.formErrors['email'],
          onChanged: (value) => widget.controller.updateEmail(value),
          keyboardType: TextInputType.emailAddress,
        ),
        
        const SizedBox(height: PromoConstants.inputSpacing),
        
        // Platform selection
        _buildPlatformSelection(context),
        
        const SizedBox(height: PromoConstants.itemSpacing),
        
        // Privacy notice
        _buildPrivacyNotice(context),
      ],
    );
  }

  Widget _buildFormField(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    required String value,
    String? error,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 14),
            fontWeight: FontWeight.w600,
            color: PromoConstants.textColor,
          ),
        ),
        const SizedBox(height: PromoConstants.smallSpacing),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 16),
            color: PromoConstants.textColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: PromoConstants.textColor.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(
              icon,
              color: error != null 
                  ? PromoConstants.errorColor 
                  : PromoConstants.primaryColor,
              size: ResponsiveHelpers.getResponsiveIconSize(context, 20),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PromoConstants.inputBorderRadius),
              borderSide: const BorderSide(
                color: PromoConstants.backgroundColor,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PromoConstants.inputBorderRadius),
              borderSide: BorderSide(
                color: error != null 
                    ? PromoConstants.errorColor 
                    : PromoConstants.backgroundColor,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PromoConstants.inputBorderRadius),
              borderSide: BorderSide(
                color: error != null 
                    ? PromoConstants.errorColor 
                    : PromoConstants.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PromoConstants.inputBorderRadius),
              borderSide: const BorderSide(
                color: PromoConstants.errorColor,
                width: 2,
              ),
            ),
            contentPadding: PromoConstants.inputPadding,
            filled: true,
            fillColor: PromoConstants.backgroundColor.withValues(alpha: 0.3),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: PromoConstants.smallSpacing / 2),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: ResponsiveHelpers.getResponsiveIconSize(context, 16),
                color: PromoConstants.errorColor,
              ),
              const SizedBox(width: PromoConstants.smallSpacing / 2),
              Expanded(
                child: Text(
                  error,
                  style: TextStyle(
                    fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 12),
                    color: PromoConstants.errorColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPlatformSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plataforma preferida',
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 14),
            fontWeight: FontWeight.w600,
            color: PromoConstants.textColor,
          ),
        ),
        const SizedBox(height: PromoConstants.smallSpacing),
        Row(
          children: AppPlatform.values.map((platform) {
            final isSelected = widget.controller.selectedPlatform == platform;
            
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: platform != AppPlatform.values.last ? PromoConstants.smallSpacing : 0,
                ),
                child: InkWell(
                  onTap: () => widget.controller.selectPlatform(platform),
                  borderRadius: BorderRadius.circular(PromoConstants.inputBorderRadius),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: PromoConstants.defaultPadding,
                      horizontal: PromoConstants.smallSpacing,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? PromoConstants.primaryColor.withValues(alpha: 0.1)
                          : PromoConstants.backgroundColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(PromoConstants.inputBorderRadius),
                      border: Border.all(
                        color: isSelected 
                            ? PromoConstants.primaryColor 
                            : PromoConstants.backgroundColor,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          PromoHelpers.getPlatformIcon(platform),
                          size: ResponsiveHelpers.getResponsiveIconSize(context, 24),
                          color: isSelected 
                              ? PromoConstants.primaryColor 
                              : PromoConstants.textColor.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: PromoConstants.smallSpacing / 2),
                        Text(
                          platform.displayName,
                          style: TextStyle(
                            fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 12),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected 
                                ? PromoConstants.primaryColor 
                                : PromoConstants.textColor.withValues(alpha: 0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrivacyNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PromoConstants.defaultPadding),
      decoration: BoxDecoration(
        color: PromoConstants.infoColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(PromoConstants.inputBorderRadius),
        border: Border.all(
          color: PromoConstants.infoColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            size: ResponsiveHelpers.getResponsiveIconSize(context, 20),
            color: PromoConstants.infoColor,
          ),
          const SizedBox(width: PromoConstants.smallSpacing),
          Expanded(
            child: Text(
              'Seus dados estão seguros. Usaremos apenas para te notificar sobre o lançamento.',
              style: TextStyle(
                fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 12),
                color: PromoConstants.textColor.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits(BuildContext context) {
    final benefits = [
      'Seja o primeiro a baixar o app',
      'Acesso antecipado a recursos beta',
      'Dicas exclusivas de cuidados pet',
      'Suporte prioritário no lançamento',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Benefícios exclusivos:',
          style: TextStyle(
            fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.w600,
            color: PromoConstants.textColor,
          ),
        ),
        const SizedBox(height: PromoConstants.itemSpacing),
        ...benefits.map((benefit) {
          return Padding(
            padding: const EdgeInsets.only(bottom: PromoConstants.smallSpacing),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: ResponsiveHelpers.getResponsiveIconSize(context, 16),
                  color: PromoConstants.successColor,
                ),
                const SizedBox(width: PromoConstants.smallSpacing),
                Expanded(
                  child: Text(
                    benefit,
                    style: TextStyle(
                      fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 14),
                      color: PromoConstants.textColor.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final isLoading = widget.controller.isSubmitting;
    final isValid = widget.controller.isFormValid;

    return Column(
      children: [
        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isValid && !isLoading ? _handleSubmit : null,
            icon: isLoading
                ? SizedBox(
                    width: ResponsiveHelpers.getResponsiveIconSize(context, 16),
                    height: ResponsiveHelpers.getResponsiveIconSize(context, 16),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(PromoConstants.whiteColor),
                    ),
                  )
                : Icon(
                    Icons.notifications_active,
                    size: ResponsiveHelpers.getResponsiveIconSize(context, 20),
                  ),
            label: Text(
              isLoading ? 'Cadastrando...' : 'Receber Notificação',
              style: TextStyle(
                fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 16),
                fontWeight: PromoConstants.buttonWeight,
              ),
            ),
            style: ElevatedButton.styleFrom(
              foregroundColor: PromoConstants.whiteColor,
              backgroundColor: PromoConstants.primaryColor,
              disabledForegroundColor: PromoConstants.whiteColor.withValues(alpha: 0.7),
              disabledBackgroundColor: PromoConstants.primaryColor.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(
                horizontal: PromoConstants.ctaButtonHorizontalPadding,
                vertical: PromoConstants.ctaButtonPadding + 4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PromoConstants.buttonBorderRadius),
              ),
              elevation: PromoConstants.buttonElevation,
            ),
          ),
        ),
        
        const SizedBox(height: PromoConstants.itemSpacing),
        
        // Cancel button
        TextButton(
          onPressed: isLoading ? null : _closeDialog,
          child: Text(
            'Cancelar',
            style: TextStyle(
              fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 14),
              color: PromoConstants.textColor.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSubmit() async {
    await widget.controller.submitRegistration(
      widget.controller.name,
      widget.controller.email,
      widget.controller.selectedPlatform ?? AppPlatform.android,
    );
    
    if (widget.controller.hasSuccess && mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PromoConstants.cardBorderRadius),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: ResponsiveHelpers.getResponsiveIconSize(context, 60),
              color: PromoConstants.successColor,
            ),
            const SizedBox(height: PromoConstants.itemSpacing),
            Text(
              'Cadastro realizado!',
              style: TextStyle(
                fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: PromoConstants.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: PromoConstants.smallSpacing),
            Text(
              PromoHelpers.getPreRegistrationSuccessMessage(
                widget.controller.name,
                widget.controller.selectedPlatform ?? AppPlatform.android,
              ),
              style: TextStyle(
                fontSize: ResponsiveHelpers.getResponsiveFontSize(context, 14),
                color: PromoConstants.textColor.withValues(alpha: 0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close success dialog
              Navigator.of(context).pop(); // Close pre-register dialog
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PromoConstants.successColor,
              foregroundColor: PromoConstants.whiteColor,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _closeDialog() {
    _fadeController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}
