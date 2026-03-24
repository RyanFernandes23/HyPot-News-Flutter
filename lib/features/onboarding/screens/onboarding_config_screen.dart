import 'package:flutter/material.dart';

class OnboardingConfigScreen extends StatefulWidget {
  const OnboardingConfigScreen({super.key});

  @override
  State<OnboardingConfigScreen> createState() => _OnboardingConfigScreenState();
}

class _OnboardingConfigScreenState extends State<OnboardingConfigScreen> {
  final Set<String> _selectedInterests = {'International', 'Regional'};

  final List<Map<String, dynamic>> _interests = [
    {'name': 'International', 'icon': Icons.public},
    {'name': 'Finance', 'icon': Icons.account_balance_wallet},
    {'name': 'Regional', 'icon': Icons.location_on},
    {'name': 'Good News', 'icon': Icons.sentiment_satisfied_alt},
    {'name': 'Hot Topics', 'icon': Icons.local_fire_department},
    {'name': 'Technology', 'icon': Icons.science},
  ];

  void _toggleInterest(String name) {
    setState(() {
      if (_selectedInterests.contains(name)) {
        _selectedInterests.remove(name);
      } else {
        _selectedInterests.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Good Morning, Alex',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F36),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Customize your daily news intake to start your day informed.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF697386),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Interests',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3E8FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Multiple Selection',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4F566B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: _interests.length,
                  itemBuilder: (context, index) {
                    final interest = _interests[index];
                    final name = interest['name'] as String;
                    final isSelected = _selectedInterests.contains(name);
                    final isRegional = name == 'Regional'; // Special case for pure blue background from image

                    return GestureDetector(
                      onTap: () => _toggleInterest(name),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected && isRegional ? const Color(0xFF1E66E1) : (isSelected ? Colors.white : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected && !isRegional
                              ? Border.all(color: const Color(0xFF1E66E1), width: 2)
                              : Border.all(color: Colors.transparent, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              interest['icon'] as IconData,
                              color: isSelected && isRegional ? Colors.white : (isSelected ? const Color(0xFF1E66E1) : const Color(0xFF4F566B)),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isSelected && isRegional ? Colors.white : (isSelected ? const Color(0xFF1E66E1) : const Color(0xFF4F566B)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Handle save and navigation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Saved: ${_selectedInterests.join(", ")}'),
                        backgroundColor: const Color(0xFF1E66E1),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E66E1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Configuration',
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
}
