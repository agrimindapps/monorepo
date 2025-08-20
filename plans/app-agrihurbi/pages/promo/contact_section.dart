// Flutter imports:
import 'package:flutter/material.dart';

class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Lista de assuntos pré-definidos para o dropdown
  final List<String> _subjects = [
    'Quero conhecer mais sobre os aplicativos',
    'Tenho interesse em parcerias',
    'Suporte técnico',
    'Sugestão de funcionalidade',
    'Outros assuntos'
  ];
  String _selectedSubject = 'Quero conhecer mais sobre os aplicativos';

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 800;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.green.shade50,
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
          vertical: 80, horizontal: isSmallScreen ? 24 : 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Título da seção
              Text(
                'Quer saber mais sobre nossas soluções?',
                style: TextStyle(
                  fontSize: isSmallScreen ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: 80,
                height: 4,
                color: Colors.green.shade700,
              ),
              const SizedBox(height: 24),

              // Subtítulo/descrição
              Container(
                constraints: const BoxConstraints(maxWidth: 700),
                margin: const EdgeInsets.only(bottom: 48),
                child: Text(
                  'Entre em contato conosco para descobrir como nossos aplicativos podem ajudar você ou sua empresa. Nossa equipe está pronta para atender às suas necessidades.',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.6,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Layout responsivo para formulário e informações de contato
              isSmallScreen ? _buildVerticalLayout() : _buildHorizontalLayout(),
            ],
          ),
        ),
      ),
    );
  }

  // Layout horizontal para telas maiores
  Widget _buildHorizontalLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Informações de contato
        Expanded(
          flex: 4,
          child: _buildContactInfo(),
        ),

        const SizedBox(width: 40),

        // Formulário
        Expanded(
          flex: 6,
          child: _buildFormCard(),
        ),
      ],
    );
  }

  // Layout vertical para telas menores
  Widget _buildVerticalLayout() {
    return Column(
      children: [
        _buildContactInfo(),
        const SizedBox(height: 40),
        _buildFormCard(),
      ],
    );
  }

  // Card com o formulário
  Widget _buildFormCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Envie sua mensagem',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // Campo de nome
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Digite seu nome completo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe seu nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo de email
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  hintText: 'Digite seu e-mail',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe seu e-mail';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Por favor, informe um e-mail válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo de assunto (dropdown)
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: InputDecoration(
                  labelText: 'Assunto',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.subject),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: _subjects.map((String subject) {
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedSubject = newValue;
                      subjectController.text = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Campo de mensagem
              TextFormField(
                controller: messageController,
                decoration: InputDecoration(
                  labelText: 'Mensagem',
                  hintText: 'Digite sua mensagem',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite sua mensagem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botão de enviar
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Enviar Mensagem',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Informações de contato
  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Outras formas de contato',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),

        // Lista de contatos
        _buildContactItem(
          icon: Icons.email_outlined,
          title: 'E-mail',
          subtitle: 'contato@agrimind.com.br',
          onTap: () {},
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          icon: Icons.phone_outlined,
          title: 'Telefone',
          subtitle: '+55 (11) 9999-9999',
          onTap: () {},
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          icon: Icons.location_on_outlined,
          title: 'Endereço',
          subtitle: 'São Paulo, SP - Brasil',
          onTap: () {},
        ),

        const SizedBox(height: 40),

        // Redes sociais
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nossas redes sociais',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSocialButton(Icons.facebook, Colors.blue),
                const SizedBox(width: 16),
                _buildSocialButton(Icons.snapchat, Colors.amber),
                const SizedBox(width: 16),
                _buildSocialButton(Icons.telegram, Colors.blue.shade300),
                const SizedBox(width: 16),
                _buildSocialButton(Icons.whatshot, Colors.red),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Item de contato individual
  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Botão de rede social
  Widget _buildSocialButton(IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
    );
  }

  void _submitForm() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simula o envio (seria substituído pela lógica real de envio)
      await Future.delayed(const Duration(seconds: 2));

      // Desativa o loading
      setState(() {
        _isLoading = false;
      });

      // Exibe mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
              SizedBox(width: 12),
              Text(
                  'Mensagem enviada com sucesso! Entraremos em contato em breve.'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Limpa os campos
      nameController.clear();
      emailController.clear();
      setState(() {
        _selectedSubject = _subjects[0];
      });
      subjectController.clear();
      messageController.clear();
    }
  }
}
