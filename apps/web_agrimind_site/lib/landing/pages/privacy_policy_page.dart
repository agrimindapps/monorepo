import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Agrimind',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Política de Privacidade',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Última atualização: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildSection(
                    '1. Sobre Este Site',
                    'Este site (agrimind.com.br) é um portal informativo da Agrimind Soluções Tecnológicas, '
                    'que apresenta nosso portfólio de aplicativos móveis. Este site tem caráter exclusivamente '
                    'informativo e de divulgação.',
                  ),
                  _buildSection(
                    '2. Coleta de Dados',
                    'Este site pode coletar dados de navegação através de:\n\n'
                    '• Cookies de analytics (Google Analytics ou similar)\n'
                    '• Informações de acesso (IP, navegador, dispositivo)\n'
                    '• Dados de interação com o site\n\n'
                    'Não coletamos dados pessoais identificáveis através deste site.',
                  ),
                  _buildSection(
                    '3. Uso de Cookies',
                    'Este site pode utilizar cookies para:\n\n'
                    '• Análise de tráfego e comportamento de usuários\n'
                    '• Melhorar a experiência de navegação\n'
                    '• Estatísticas de acesso\n\n'
                    'Você pode desabilitar cookies nas configurações do seu navegador.',
                  ),
                  _buildSection(
                    '4. Compartilhamento de Dados',
                    'Não compartilhamos, vendemos ou alugamos dados pessoais coletados neste site com terceiros, '
                    'exceto quando necessário para:\n\n'
                    '• Cumprir obrigações legais\n'
                    '• Proteger nossos direitos\n'
                    '• Serviços de analytics (Google Analytics)',
                  ),
                  _buildSection(
                    '5. Políticas dos Aplicativos',
                    'Cada aplicativo da Agrimind possui sua própria Política de Privacidade e Termos de Uso. '
                    'Ao utilizar nossos aplicativos, você estará sujeito às políticas específicas de cada produto:\n\n'
                    '• ReceituAgro: receituagro.agrimind.com.br/privacy\n'
                    '• Petiveti: petiveti.agrimind.com.br/privacy\n'
                    '• Plantis: plantis.agrimind.com.br/privacy\n'
                    '• Gasometer: gasometer.agrimind.com.br/privacy\n'
                    '• Nebulalist: nebulalist.agrimind.com.br/privacy\n'
                    '• Taskolist: taskolist.agrimind.com.br/privacy\n'
                    '• AgriHurbi: agrihurbi.agrimind.com.br/privacy\n'
                    '• Nutrituti: nutrituti.agrimind.com.br/privacy\n'
                    '• Termos Técnicos: termostecnicos.agrimind.com.br/privacy',
                  ),
                  _buildSection(
                    '6. Segurança',
                    'Implementamos medidas de segurança técnicas e organizacionais para proteger as informações '
                    'contra acesso não autorizado, alteração, divulgação ou destruição.',
                  ),
                  _buildSection(
                    '7. Direitos do Usuário (LGPD)',
                    'De acordo com a Lei Geral de Proteção de Dados (LGPD), você tem direito a:\n\n'
                    '• Confirmação da existência de tratamento\n'
                    '• Acesso aos dados\n'
                    '• Correção de dados incompletos, inexatos ou desatualizados\n'
                    '• Anonimização, bloqueio ou eliminação de dados\n'
                    '• Portabilidade dos dados\n'
                    '• Revogação do consentimento',
                  ),
                  _buildSection(
                    '8. Alterações nesta Política',
                    'Podemos atualizar esta Política de Privacidade periodicamente. Recomendamos que você '
                    'revise esta página regularmente para se manter informado.',
                  ),
                  _buildSection(
                    '9. Contato',
                    'Para questões sobre privacidade ou exercer seus direitos:\n\n'
                    'Email: contato@agrimind.com.br\n'
                    'Agrimind Soluções Tecnológicas\n'
                    'CNPJ: [Inserir CNPJ]',
                  ),
                  const SizedBox(height: 60),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Voltar para o início'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3ECF8E),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3ECF8E),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey.shade300,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
