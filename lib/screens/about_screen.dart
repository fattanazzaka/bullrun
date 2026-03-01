import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/theme.dart';

class _Profile {
  static const String name        = 'Fattan Azzaka';
  static const int    age         = 19;
  static const String major       = 'Computer Science';
  static const String bio         =
      'I am a undergraduate student in Universitas Indonesia that passionate and committed learner deeply interested in technology and programming.'
      'I am always looking forward to expand my knowledge to make inventive solutions, '
      'always on the lookout for chances to improve my abilities and contribute positively. ';


  static const List<Map<String, dynamic>> basics = [
    {'label': 'BEM Fasilkom',    'icon': Icons.groups_outlined},
    {'label': 'Jakarta',       'icon': Icons.location_on_outlined},
    {'label': 'Student',       'icon': Icons.school_outlined},
  ];

  // Social media links
  static const List<Map<String, String>> socials = [
    {'platform': 'Instagram', 'handle': '@ftn.azzaka', 'url': 'https://instagram.com/ftn.azzaka'},
    {'platform': 'LinkedIn',  'handle': 'linkedin.com/in/muhammad-fattan-azzaka', 'url': 'https://www.linkedin.com/in/muhammad-fattan-azzaka-bb5456210/'},
    {'platform': 'GitHub',    'handle': 'github.com/fattanazzaka', 'url': 'https://github.com/fattanazzaka'},
  ];

  
  static const String? photoAsset = 'assets/images/photo.jpg';
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeroPhoto()),
          SliverToBoxAdapter(child: _buildContent()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildHeroPhoto() {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background foto
          _Profile.photoAsset != null
              ? Image.asset(_Profile.photoAsset!, fit: BoxFit.cover)
              : Container(
                  color: AppTheme.surfaceVariant,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_rounded,
                          size: 100, color: AppTheme.primaryDim),
                      SizedBox(height: 8),
                      
                    ],
                  ),
                ),

          // Gradient overlay — gelap di bawah agar teks terbaca
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.35, 0.75, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),

          // Nama + badge di atas foto
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama + umur
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _Profile.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${_Profile.age}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Badge jurusan — pill gelap transparan
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  child: Text(
                    _Profile.major,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      color: AppTheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicsSection(),
          _buildDivider(),
          _buildAboutSection(),
          _buildDivider(),
          _buildSocialsSection(),
          _buildDivider(),
        ],
      ),
    );
  }

  // ── MY BASICS ────────────────────────────────────────────────────────────
  Widget _buildBasicsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('MY BASICS'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _Profile.basics.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 15,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item['label'] as String,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── ABOUT ME ─────────────────────────────────────────────────────────────
  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('ABOUT ME'),
          const SizedBox(height: 12),
          Text(
            _Profile.bio,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              height: 1.65,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ── SOCIAL MEDIA ─────────────────────────────────────────────────────────
  Widget _buildSocialsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('SOCIAL MEDIA'),
          const SizedBox(height: 12),
          ..._Profile.socials.map((s) => _socialTile(
                platform: s['platform']!,
                handle: s['handle']!,
                url: s['url']!,
              )),
        ],
      ),
    );
  }

  Widget _socialTile({
    required String platform,
    required String handle,
    required String url,
  }) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.tryParse(url);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(platform,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 1),
                Text(handle,
                    style: const TextStyle(
                        color: AppTheme.textTertiary, fontSize: 11)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppTheme.textTertiary, size: 13),
          ],
        ),
      ),
    );
  }


  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textTertiary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDivider() => Container(
        height: 1,
        color: AppTheme.border,
        margin: const EdgeInsets.symmetric(horizontal: 0),
      );

  Widget _dividerThin() => Container(
        height: 1,
        color: AppTheme.border.withOpacity(0.5),
        margin: const EdgeInsets.symmetric(horizontal: 16),
      );
}