import 'package:flutter/material.dart';

class EditInterestsScreen extends StatefulWidget {
  const EditInterestsScreen({super.key});

  @override
  State<EditInterestsScreen> createState() => _EditInterestsScreenState();
}

class _EditInterestsScreenState extends State<EditInterestsScreen> {
  final List<Map<String, dynamic>> _allInterests = [
    {'name': 'For You', 'icon': Icons.star, 'selected': true},
    {'name': 'Technology', 'icon': Icons.laptop, 'selected': true},
    {'name': 'Science', 'icon': Icons.science, 'selected': true},
    {'name': 'International', 'icon': Icons.public, 'selected': false},
    {'name': 'Finance', 'icon': Icons.payments, 'selected': false},
    {'name': 'Politics', 'icon': Icons.gavel, 'selected': false},
    {'name': 'Health', 'icon': Icons.health_and_safety, 'selected': false},
    {'name': 'Sports', 'icon': Icons.sports_basketball, 'selected': false},
    {'name': 'Entertainment', 'icon': Icons.movie, 'selected': false},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Interests',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What news interests you?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF697386),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: _allInterests.length,
                    itemBuilder: (context, index) {
                      final interest = _allInterests[index];
                      return _buildInterestCard(interest, index);
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Save Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestCard(Map<String, dynamic> interest, int index) {
    final bool isSelected = interest['selected'];
    
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: () {
        setState(() {
          _allInterests[index]['selected'] = !isSelected;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? (Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                : colorScheme.onSurface.withOpacity(0.1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              interest['icon'],
              size: 20,
              color: isSelected 
                  ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                  : colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                interest['name'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected 
                      ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                      : colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 16,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
          ],
        ),
      ),
    );
  }
}
