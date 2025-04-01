import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../widgets/swirling_gradient_painter.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final List<Map<String, dynamic>> _budgetOptions = [
    {'level': '0-50', 'emoji': '💸', 'description': r'Under $50', 'color': Colors.green},
    {'level': '50-100', 'emoji': '💵', 'description': r'$50-$100', 'color': Colors.yellow},
    {'level': '100-200', 'emoji': '💶', 'description': r'$100-$200', 'color': Colors.orange},
    {'level': '200-500', 'emoji': '💷', 'description': r'$200-$500', 'color': Colors.red},
    {'level': '500+', 'emoji': '💸', 'description': r'Over $500', 'color': Colors.purple},
  ];

  String? _selectedBudget;

  void _selectBudget(String budget) {
    setState(() {
      _selectedBudget = budget;
    });
    ref.read(preferencesProvider.notifier).updateBudgetLevel(budget);
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(preferencesProvider);
    final selectedBudget = preferences.budgetLevel;

    return Scaffold(
      body: CustomPaint(
        painter: SwirlingGradientPainter(),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Title and description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      'What\'s your budget range?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ).animate()
                     .fadeIn(duration: 600.ms)
                     .slideY(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 10),
                    
                    Text(
                      'Choose your preferred spending level',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ).animate()
                     .fadeIn(duration: 600.ms, delay: 200.ms)
                     .slideY(begin: -0.2, end: 0),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Budget options
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _budgetOptions.length,
                  itemBuilder: (context, index) {
                    final budget = _budgetOptions[index];
                    final isSelected = selectedBudget == budget['level'];
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: GestureDetector(
                        onTap: () => _selectBudget(budget['level']),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected 
                              ? budget['color'].withOpacity(0.9)
                              : Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Text(
                                budget['emoji'],
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      budget['level'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      budget['description'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: isSelected ? Colors.white.withOpacity(0.9) : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate()
                       .fadeIn(duration: 600.ms, delay: (100 * index).ms)
                       .slideY(begin: 0.2, end: 0),
                    );
                  },
                ),
              ),
              
              // Continue button
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: selectedBudget != null
                    ? () => context.go('/preferences/loading')
                    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5BB32A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Start Exploring',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ).animate()
                 .fadeIn(duration: 600.ms, delay: 400.ms)
                 .slideY(begin: 0.2, end: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 