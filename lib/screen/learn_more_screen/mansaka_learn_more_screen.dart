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
                'assets/images/mansaka_learn_more.jpg',
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
            'The Mansaka people are indigenous to the mountainous regions of Davao de Oro (formerly Compostela Valley). They are known for their expertise in agriculture, traditional crafts, and their deep spiritual connection to their ancestral lands.',
          ),
          
          const SizedBox(height: 32),
          
          // Origins and Legend Section
          _buildSectionTitle('ORIGINS & HERITAGE'),
          const SizedBox(height: 16),
          _buildDescriptionCard(
            'The Mansaka are believed to be among the earliest inhabitants of the Davao region. Their name is thought to derive from "man" (people) and "saka" (to go up), referring to their traditional practice of moving to higher elevations during certain seasons.',
          ),
          
          const SizedBox(height: 32),
          
          // Cultural Practices Section
          _buildSectionTitle('CULTURAL PRACTICES'),
          const SizedBox(height: 16),
          
          _buildPracticeItem(
            icon: Icons.agriculture,
            title: 'Traditional Agriculture',
            description: 'The Mansaka are skilled farmers, practicing sustainable agriculture techniques passed down through generations, including rice terracing and crop rotation.',
          ),
          
          const SizedBox(height: 16),
          
          _buildPracticeItem(
            icon: Icons.handyman,
            title: 'Traditional Crafts',
            description: 'Known for their basketry, woodcarving, and metalwork, creating both functional items and ceremonial objects with intricate designs.',
          ),
          
          const SizedBox(height: 16),
          
          _buildPracticeItem(
            icon: Icons.nature_people,
            title: 'Ancestral Wisdom',
            description: 'Strong oral tradition preserving ancient knowledge about medicinal plants, weather patterns, and sustainable living practices.',
          ),
          
          const SizedBox(height: 32),
          
          // Lifestyle Section
          _buildSectionTitle('TRADITIONAL LIFESTYLE'),
          const SizedBox(height: 16),
          _buildDescriptionCard(
            'The Mansaka live in close-knit communities governed by traditional leaders and council of elders. Their social structure emphasizes cooperation, respect for nature, and the importance of maintaining harmony between the physical and spiritual worlds.',
          ),
          
          const SizedBox(height: 32),
          
          // Modern Challenges Section
          _buildSectionTitle('PRESERVING TRADITIONS'),
          const SizedBox(height: 16),
          _buildDescriptionCard(
            'While adapting to modern times, the Mansaka work to preserve their cultural identity through community education, traditional festivals, and the documentation of their indigenous knowledge systems for future generations.',
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