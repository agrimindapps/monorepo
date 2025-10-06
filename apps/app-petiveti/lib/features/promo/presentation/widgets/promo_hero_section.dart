import 'package:flutter/material.dart';
import '../../../../shared/constants/splash_constants.dart';

class PromoHeroSection extends StatelessWidget {
  final String appName;
  final String appTagline;
  final String appDescription;
  final VoidCallback onGetStartedPressed;
  final VoidCallback onPreRegisterPressed;

  const PromoHeroSection({
    super.key,
    required this.appName,
    required this.appTagline,
    required this.appDescription,
    required this.onGetStartedPressed,
    required this.onPreRegisterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: SplashColors.heroGradient,
        ),
      ),
      child: Stack(
        children: [
          _buildBackgroundElements(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 32,
                40,
                isMobile ? 16 : 32,
                40,
              ),
              child: isMobile
                  ? _buildMobileLayout(context)
                  : _buildDesktopLayout(context, isTablet),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        _buildHeroImage(context, isMobile: true),
        const SizedBox(height: 32),
        _buildTextContent(context, isMobile: true),
        const SizedBox(height: 32),
        _buildActionButtons(context, isMobile: true),
        const SizedBox(height: 40),
        _buildStoreButtons(context, isMobile: true),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isTablet) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Row(
        children: [
          Expanded(
            flex: isTablet ? 3 : 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextContent(context),
                const SizedBox(height: 32),
                _buildCountdownSection(context),
                const SizedBox(height: 32),
                _buildActionButtons(context),
                const SizedBox(height: 24),
                _buildStoreButtons(context),
              ],
            ),
          ),
          const SizedBox(width: 80),
          Expanded(
            flex: isTablet ? 2 : 2,
            child: _buildHeroImage(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, {bool isMobile = false}) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          appName,
          style: TextStyle(
            fontSize: isMobile ? 36 : 46,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          width: 80,
          height: 4,
          decoration: BoxDecoration(
            color: SplashColors.accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          appTagline,
          style: TextStyle(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.4,
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: SplashColors.accentColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            SplashConstants.launchStatus,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Text(
            appDescription,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LANÇAMENTO PREVISTO PARA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.7),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            SplashConstants.launchDateFormatted,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          _buildCountdownTimer(),
        ],
      ),
    );
  }

  Widget _buildCountdownTimer() {
    final now = DateTime.now();
    final difference = SplashConstants.launchDate.difference(now);
    final days = difference.inDays;
    
    return Row(
      children: [
        const Icon(
          Icons.access_time,
          size: 16,
          color: Colors.white,
        ),
        const SizedBox(width: 8),
        Text(
          'Faltam apenas $days dias',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, {bool isMobile = false}) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: onPreRegisterPressed,
          icon: const Icon(Icons.notifications_active, size: 20),
          label: const Text('Quero ser Notificado'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: SplashColors.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 3,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
          },
          icon: const Icon(Icons.expand_more, size: 20),
          label: const Text('Saiba Mais'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreButtons(BuildContext context, {bool isMobile = false}) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
      children: [
        _buildStoreButton(
          'EM BREVE NA',
          'GOOGLE PLAY',
          Icons.android,
          Colors.black87,
        ),
        _buildStoreButton(
          'EM BREVE NA',
          'APP STORE',
          Icons.apple,
          Colors.black87,
        ),
      ],
    );
  }

  Widget _buildStoreButton(String topText, String bottomText, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                topText,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ),
              ),
              Text(
                bottomText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context, {bool isMobile = false}) {
    final imageSize = isMobile ? 280.0 : 400.0;
    
    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
          SplashConstants.heroImageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: imageSize,
              height: imageSize,
              color: Colors.white.withValues(alpha: 0.1),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: imageSize,
              height: imageSize,
              color: Colors.white.withValues(alpha: 0.1),
              child: const Icon(
                Icons.pets,
                size: 100,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}
