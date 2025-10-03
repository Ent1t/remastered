// lib/screen/learn_more_screen/mansaka_learn_more_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MansakaCulturalLearnMoreScreen extends StatelessWidget {
  const MansakaCulturalLearnMoreScreen({super.key});

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
                'assets/images/mansaka_lm.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF5D4E75),
                          Color(0xFF3F325A),
                          Color(0xFF2A1F3D),
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
                    'MANSAKA',
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
                    'Indigenous People of Davao de Oro',
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
          _buildSectionTitle('ABOUT THE MANSAKA'),
          const SizedBox(height: 16),
          _buildDescriptionCard(
            'The indigenous socio-political structure of the Mansaka tribe, established to promote order, maintain security and advance the development of their communities.',
          ),
          
          const SizedBox(height: 32),
          
          // Origins and Legend Section
          _buildSectionTitle('ORIGINS & LEGENDS'),
          const SizedBox(height: 16),
          _buildDescriptionCard(
            'The term Mansaka was derived from the words ‘man,’ meaning ‘first’ and ‘saka,’ meaning ‘to ascend. '
            'Mansaka meant ‘the first people to ascend the mountains or go upstream. '
            'Prior to being called as ‘Mansaka,’ their people had once been called as ‘utaw’ which meant an indigenous person with innate character and virtues.'
          ),
          
          const SizedBox(height: 32),
          
          // Cultural Practices Section
          _buildSectionTitle('CULTURAL PRACTICES'),
          const SizedBox(height: 16),
          
          _buildPracticeItem(
            icon: Icons.healing,
            title: 'Traditional Healing',
            description: 'the Balyan, who is either male or female, is an important part of the structure of the Mansaka tribe. They are spiritual healers known as intelligent persons and are respected by the members of the tribe. Their knowing the cause of a member of a Mansaka tribe’s illness and their corresponding traditional medications had them viewed as someone endowed with special wisdom.',
          ),
        
          const SizedBox(height: 16),
          
          _buildPracticeItem(
            icon: Icons.nature_people,
            title: 'Spiritual Rituals',
            description: 'The Kyalalaysan is a prominent leader of the Mansaka tribe, equal in stature to the highest spiritual leaders, and skilled in rituals with singing and chanting. ' 
                          'Usually from a family of Balyan, the current Kyalalaysan of Tagum, Aguido Sucnaan Sr., succeeded his grandfather, Pyagmatikadung Tangkunay. Past Kyalalaysan include Lantones, Manggang, Kalipayan, Uyop Uyopan, and Mailom.',
          ),
          
          const SizedBox(height: 16),
          
          _buildPracticeItem(
            icon: Icons.handyman,
            title: 'Craftsmanship',
            description: 'The Mansaka show craftsmanship in rituals through singing and chanting, a skill practiced by the Kyalalaysan and passed down from their ancestors',
          ),

          const SizedBox(height: 32),
          
          // Lifestyle Section
          _buildSectionTitle('TRADITIONAL LIFESTYLE'),
          const SizedBox(height: 16),
          _buildDescriptionCard(
            'They traditionally believe that the land is provided by Magbabaya, and considers their land as a very important possession which they inherited from their ancestors especially because they are dependent on the resources found within their domain.',
          ),
          
          const SizedBox(height: 32),
          
          // Modern Challenges Section
          _buildSectionTitle('PRESERVING CULTURE'),
          const SizedBox(height: 16),
          _buildDescriptionCard(
            'The tribe also considers it their responsibility to protect, defend and handle the land well enough to be able to bequeath it to the next generation. Maintained their sense of pride and remained true to their cause of protecting their identity and cultural heritage.',
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
            color: const Color(0xFFB19CD9),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFB19CD9),
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
          color: const Color(0xFFB19CD9).withOpacity(0.2),
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
          color: const Color(0xFFB19CD9).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFB19CD9).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFB19CD9),
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
                    color: Color(0xFFB19CD9),
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