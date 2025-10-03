import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KaganCulturalLearnMoreScreen extends StatelessWidget {
  const KaganCulturalLearnMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a1a),
              Color(0xFF0d0d0d),
              Colors.black,
            ],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(context),
              const SizedBox(height: 24),
              _buildContentSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          // Background Image
          Container(
            height: 300,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Image.asset(
                'assets/images/kagan_lm.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF8B4513),
                          Color(0xFF654321),
                          Color(0xFF2F1B14),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Dark Overlay
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.7),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),
          
          // Content Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Title
                  const Text(
                    'KAGAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Indigenous People of Mindanao',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Introduction Section
          _buildSectionTitle('ABOUT THE KAGAN'),
          const SizedBox(height: 16),
          _buildDescriptionCard(
            'The Kagan tribe has occupied their ancestral domain since time immemorial and has been considering the lands encompassed therein as their life – the value of their existence. Kagan community is governed by a Pyagmatikadung / Datu who has his Council of Elders formed to eventually attend to the general affairs of said community',
          ),
          
          const SizedBox(height: 32),
          
          // Origins and Legend Section
          _buildSectionTitle('ORIGINS & LEGEND'),
          const SizedBox(height: 16),
          _buildDescriptionCard(
            'The Kagan elders narrated that the word “Kagan” comes from the root word Ka’ag, which means “to inform or to warn. ' 
            'According to Datu Belardo Bungad, the name Ka’ag was not ascribed by other people, rather it is their people who called themselves as such.  '
            'Another ascription based on an oral tradition recounted a person from Tagasug saying “Kyalagan ko na” which meant “I have found it.”',
          ),
          
          const SizedBox(height: 32),
          
          // Cultural Practices Section
          _buildSectionTitle('CULTURAL PRACTICES'),
          const SizedBox(height: 16),
          
          _buildPracticeItem(
            icon: Icons.spa,
            title: 'Traditional Healing',
            description: 'The Kagan are known for their extensive knowledge of medicinal plants and traditional healing practices passed down through generations.',
          ),
          
          const SizedBox(height: 16),
          
          _buildPracticeItem(
            icon: Icons.auto_awesome,
            title: 'Spiritual Rituals',
            description: 'The sacred place of the Kagan tribe of Madaum called as Banakon where they used to offer rituals like Panuwak Buka." '
                         'A ritual called as Panuwak Buka conducted at Banakon (Barret Beach) in Barangay Madaum performed by Datu Belardo Bungad to prevent calamities and bad things from happening in the community.',
          ),
          
          const SizedBox(height: 16),
          
          _buildPracticeItem(
            icon: Icons.palette,
            title: 'Craftsmanship',
            description: 'Aside from marking their territories with bodies of water, the Kagan also used huge trees such as Durian and Baluno as well as the Bamboo grass as their marker.',
          ),
          
          const SizedBox(height: 32),
          
          // Lifestyle Section
          _buildSectionTitle('TRADITIONAL LIFESTYLE'),
          const SizedBox(height: 16),
          _buildDescriptionCard(
            'The Kagan community invoked the concept of self-delineation in identifying their traditional landmarks.'
            'Kagan ancestors in Madaum consider Hijo River as an important part of their lives as this is where trade and other economic activities occur.'
          ),
          
          const SizedBox(height: 32),
          
          // Modern Challenges Section
          _buildSectionTitle('PRESERVING CULTURE'),
          const SizedBox(height: 16),
          _buildDescriptionCard(
            'The Kagan tribe is similar to Mansaka and Mandaya as these indigenous tribes also valued the conduct of rituals, and referred to their God as Tagallang na Magbabaya.',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFD4A574),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFD4A574),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4A574).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        description,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.6,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildPracticeItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4A574).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFD4A574).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFD4A574),
              size: 24,
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
                    color: Color(0xFFD4A574),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}