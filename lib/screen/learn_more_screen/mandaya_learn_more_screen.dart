// lib/screen/learn_more_screen/mandaya_learn_more_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MandayaCulturalLearnMoreScreen extends StatelessWidget {
  const MandayaCulturalLearnMoreScreen({super.key});

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
                'assets/images/mandaya.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF4A5D23),
                          Color(0xFF2F3E15),
                          Color(0xFF1A2209),
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
                    'MANDAYA',
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
                    'Indigenous People of Davao Oriental',
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
          _buildSectionTitle('ABOUT THE MANDAYA'),
          const SizedBox(height: 16),
          _buildDescriptionCard(
            'One of Tagum’s dominant indigenous groups, the Mandaya tribe is a native community or Tipanud in the area. They also fosters a good relationship with those from the tribes of Kagan and Mansaka.',
          ),
          
          const SizedBox(height: 32),
          
          // Origins and Legend Section
          _buildSectionTitle('ORIGINS & LEGENDS'),
          const SizedBox(height: 16),
          _buildDescriptionCard(
            'The word Mandaya came from the words ‘man’ and ‘daya’ which means ‘people’ from the ‘upstream.’ '
            'Mandaya is said to have originated from the interpretation of an utterance of those who live downstream.',
          ),
          
          const SizedBox(height: 32),
          
          // Cultural Practices Section
          _buildSectionTitle('CULTURAL PRACTICES'),
          const SizedBox(height: 16),
          
          _buildPracticeItem(
            icon: Icons.healing,
            title: 'Traditional Healing',
            description: 'Traditional leaders of the Mandaya also include the Baylan who is the community’s spiritual healer who can foresee future happenings, such as calamities and disasters. As a priest or priestess, the Baylan performs rituals yet does not conduct wedding ceremonies.',
          ),
          
          const SizedBox(height: 16),
          
          _buildPracticeItem(
            icon: Icons.people,
            title: 'Spritual Rituals',
            description: 'The Mandaya tribe is headed by a Datu or Bia who, as the supreme leader, must be a teacher, mediator and adviser to the members of the community; a culture master who officiates traditional ceremonies like tribal weddings and such other celebrations; and a judge who implements and executes the delivery of their justice system.',
          ),
          
          const SizedBox(height: 16),
          
          _buildPracticeItem(
            icon: Icons.handyman,
            title: 'Craftmanship',
            description: 'The craftsmanship of the Mandaya is shown in the dagum, the traditional Mandaya blouse, which is part of their cultural attire',
          ),
          
          const SizedBox(height: 32),
          
          // Lifestyle Section
          _buildSectionTitle('TRADITIONAL LIFESTYLE'),
          const SizedBox(height: 16),
          _buildDescriptionCard(
            'The members of the Mandaya communities are among the original settlers of Tagum and they have been in possession of their land since before the 18th century. '
            'They lived simply, foraging their territory for means that would provide them with their sustenance and basic needs.',
          ),
          
          const SizedBox(height: 32),
          
          // Modern Challenges Section
          _buildSectionTitle('PRESERVING CULTURE'),
          const SizedBox(height: 16),
          _buildDescriptionCard(
            'The Mandaya tribe fosters good relationships with other tribes and preserves their traditional territories in the barangays of Mankilam, Cuambogan, Pagsabangan, Canocotan, and San Miguel.',
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
            color: const Color(0xFF7FB069),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF7FB069),
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
          color: const Color(0xFF7FB069).withOpacity(0.2),
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
          color: const Color(0xFF7FB069).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF7FB069).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF7FB069),
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
                    color: Color(0xFF7FB069),
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