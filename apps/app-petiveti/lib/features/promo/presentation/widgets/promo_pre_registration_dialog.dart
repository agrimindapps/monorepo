import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';

import '../providers/promo_provider.dart';
import '../states/promo_state.dart';

class PromoPreRegistrationDialog extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const PromoPreRegistrationDialog({
    super.key,
    required this.onClose,
  });

  @override
  ConsumerState<PromoPreRegistrationDialog> createState() => _PromoPreRegistrationDialogState();
}

class _PromoPreRegistrationDialogState extends ConsumerState<PromoPreRegistrationDialog> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(promoProvider);
    
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 8, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Pré-cadastro PetiVeti',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: state.preRegistrationSuccess
                    ? _buildSuccessContent(theme)
                    : _buildFormContent(theme, state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessContent(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 32,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Pré-cadastro realizado!',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Você será notificado assim que o PetiVeti for lançado.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 24),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Fechar'),
          ),
        ),
      ],
    );
  }

  Widget _buildFormContent(ThemeData theme, PromoState state) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seja o primeiro a saber quando o PetiVeti for lançado!',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 24),
          
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Seu e-mail',
              hintText: 'exemplo@email.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.email),
              errorText: state.hasPreRegistrationError ? state.preRegistrationError : null,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, digite seu e-mail';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Por favor, digite um e-mail válido';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isSubmittingPreRegistration ? null : _submitPreRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: state.isSubmittingPreRegistration
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Fazer pré-cadastro'),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Seus dados estão seguros conosco e você pode cancelar a qualquer momento.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _submitPreRegistration() {
    if (_formKey.currentState!.validate()) {
      ref.read(promoProvider.notifier).submitPreRegistration(_emailController.text.trim());
    }
  }
}