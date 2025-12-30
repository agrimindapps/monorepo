import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

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
                    'Termos de Uso',
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
                    '1. Aceitação dos Termos',
                    'Ao acessar e usar este site (agrimind.com.br), você concorda em cumprir estes Termos de Uso. '
                    'Se você não concordar com algum destes termos, por favor, não utilize este site.',
                  ),
                  _buildSection(
                    '2. Descrição do Serviço',
                    'Este site é um portal informativo da Agrimind Soluções Tecnológicas que apresenta nosso '
                    'portfólio de aplicativos móveis. O site tem caráter exclusivamente informativo e de divulgação, '
                    'servindo como ponto de acesso para conhecer e baixar nossos aplicativos.',
                  ),
                  _buildSection(
                    '3. Uso do Site',
                    'Você concorda em usar este site apenas para fins legais e de maneira que não infrinja os '
                    'direitos de terceiros ou restrinja ou iniba o uso e aproveitamento do site por terceiros.\n\n'
                    'É proibido:\n\n'
                    '• Usar o site de forma ilegal ou não autorizada\n'
                    '• Tentar obter acesso não autorizado ao site\n'
                    '• Interferir ou interromper o site ou servidores\n'
                    '• Coletar dados de usuários sem autorização\n'
                    '• Transmitir vírus ou códigos maliciosos',
                  ),
                  _buildSection(
                    '4. Termos dos Aplicativos',
                    'Este site apenas apresenta informações sobre nossos aplicativos. Cada aplicativo possui seus '
                    'próprios Termos de Uso e Política de Privacidade que você deve aceitar antes de utilizá-los.\n\n'
                    'Os Termos de Uso específicos de cada aplicativo podem ser encontrados em:\n\n'
                    '• ReceituAgro: receituagro.agrimind.com.br/terms\n'
                    '• Petiveti: petiveti.agrimind.com.br/terms\n'
                    '• Plantis: plantis.agrimind.com.br/terms\n'
                    '• Gasometer: gasometer.agrimind.com.br/terms\n'
                    '• Nebulalist: nebulalist.agrimind.com.br/terms\n'
                    '• Taskolist: taskolist.agrimind.com.br/terms\n'
                    '• AgriHurbi: agrihurbi.agrimind.com.br/terms\n'
                    '• Nutrituti: nutrituti.agrimind.com.br/terms\n'
                    '• Termos Técnicos: termostecnicos.agrimind.com.br/terms',
                  ),
                  _buildSection(
                    '5. Propriedade Intelectual',
                    'Todo o conteúdo deste site, incluindo textos, gráficos, logos, ícones, imagens e software, '
                    'é propriedade da Agrimind Soluções Tecnológicas e protegido pelas leis de direitos autorais.\n\n'
                    'Você não pode:\n\n'
                    '• Reproduzir, duplicar ou copiar material do site\n'
                    '• Redistribuir conteúdo sem autorização\n'
                    '• Usar marcas registradas da Agrimind sem permissão',
                  ),
                  _buildSection(
                    '6. Links Externos',
                    'Este site pode conter links para sites externos. A Agrimind não é responsável pelo conteúdo '
                    'ou práticas de privacidade destes sites. A inclusão de links não implica endosso.',
                  ),
                  _buildSection(
                    '7. Isenção de Garantias',
                    'Este site é fornecido "como está" sem garantias de qualquer tipo, expressas ou implícitas. '
                    'A Agrimind não garante que:\n\n'
                    '• O site estará disponível ininterruptamente\n'
                    '• As informações estejam sempre atualizadas\n'
                    '• O site estará livre de erros ou vírus',
                  ),
                  _buildSection(
                    '8. Limitação de Responsabilidade',
                    'A Agrimind não será responsável por quaisquer danos diretos, indiretos, incidentais ou '
                    'consequenciais resultantes do uso ou incapacidade de usar este site.',
                  ),
                  _buildSection(
                    '9. Modificações dos Termos',
                    'A Agrimind se reserva o direito de modificar estes Termos de Uso a qualquer momento. '
                    'As alterações entrarão em vigor imediatamente após a publicação no site. Recomendamos '
                    'que você revise estes termos periodicamente.',
                  ),
                  _buildSection(
                    '10. Lei Aplicável',
                    'Estes Termos de Uso são regidos pelas leis da República Federativa do Brasil. Quaisquer '
                    'disputas serão resolvidas nos tribunais brasileiros.',
                  ),
                  _buildSection(
                    '11. Contato',
                    'Para questões sobre estes Termos de Uso:\n\n'
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
