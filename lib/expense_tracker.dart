import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';


void main() {
  runApp(const ExpensoApp());
}



enum ExpenseCategory { food, transport, shopping, health, entertainment, other }

extension CategoryExtension on ExpenseCategory {
  String get label => switch (this) {
        ExpenseCategory.food => 'Food',
        ExpenseCategory.transport => 'Transport',
        ExpenseCategory.shopping => 'Shopping',
        ExpenseCategory.health => 'Health',
        ExpenseCategory.entertainment => 'Fun',
        ExpenseCategory.other => 'Other',
      };

  String get emoji => switch (this) {
        ExpenseCategory.food => '🍜',
        ExpenseCategory.transport => '🚆',
        ExpenseCategory.shopping => '🛍️',
        ExpenseCategory.health => '💊',
        ExpenseCategory.entertainment => '🎬',
        ExpenseCategory.other => '📦',
      };

  Color get color => switch (this) {
        ExpenseCategory.food => const Color(0xFFFF6B35),
        ExpenseCategory.transport => const Color(0xFF4ECDC4),
        ExpenseCategory.shopping => const Color(0xFFFFE66D),
        ExpenseCategory.health => const Color(0xFF95E1D3),
        ExpenseCategory.entertainment => const Color(0xFFF38181),
        ExpenseCategory.other => const Color(0xFFC4B5FD),
      };
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });
}


class AppColors {
  
  static const darkBg = Color(0xFF0D0D0D);
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkCard = Color(0xFF242424);
  static const darkBorder = Color(0xFF333333);
  static const darkText = Color(0xFFF5F5F5);
  static const darkSubtext = Color(0xFF888888);

  
  static const lightBg = Color(0xFFF7F4EF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFAF8F5);
  static const lightBorder = Color(0xFFE5E0D8);
  static const lightText = Color(0xFF0D0D0D);
  static const lightSubtext = Color(0xFF888888);

  
  static const accent = Color(0xFFFF6B35);
  static const accentGlow = Color(0x33FF6B35);
}



class ExpensoApp extends StatefulWidget {
  const ExpensoApp({super.key});

  @override
  State<ExpensoApp> createState() => _ExpensoAppState();
}

class _ExpensoAppState extends State<ExpensoApp> {
  bool _isDark = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expenso',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Courier',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: _isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      home: ExpenseHomePage(
        isDark: _isDark,
        onThemeToggle: () => setState(() => _isDark = !_isDark),
      ),
    );
  }
}



class ExpenseHomePage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onThemeToggle;

  const ExpenseHomePage({
    super.key,
    required this.isDark,
    required this.onThemeToggle,
  });

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage>
    with TickerProviderStateMixin {
  final List<Expense> _expenses = [
    Expense(
      id: '1',
      title: 'Ramen & Gyoza',
      amount: 18.50,
      category: ExpenseCategory.food,
      date: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Expense(
      id: '2',
      title: 'Metro Pass',
      amount: 32.00,
      category: ExpenseCategory.transport,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Expense(
      id: '3',
      title: 'Vintage Jacket',
      amount: 89.99,
      category: ExpenseCategory.shopping,
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Expense(
      id: '4',
      title: 'Cinema Ticket',
      amount: 14.00,
      category: ExpenseCategory.entertainment,
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Expense(
      id: '5',
      title: 'Vitamins',
      amount: 22.00,
      category: ExpenseCategory.health,
      date: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  late AnimationController _fabController;
  late AnimationController _headerController;

  Color get bg => widget.isDark ? AppColors.darkBg : AppColors.lightBg;
  Color get surface =>
      widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get card => widget.isDark ? AppColors.darkCard : AppColors.lightCard;
  Color get border =>
      widget.isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get text => widget.isDark ? AppColors.darkText : AppColors.lightText;
  Color get subtext => AppColors.darkSubtext;

  double get totalSpent =>
      _expenses.fold(0, (sum, e) => sum + e.amount);

  double get budget => 500.0;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  void _showAddExpenseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddExpenseSheet(
        isDark: widget.isDark,
        onAdd: (expense) {
          setState(() => _expenses.insert(0, expense));
        },
      ),
    );
  }

  void _deleteExpense(String id) {
    setState(() => _expenses.removeWhere((e) => e.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: widget.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: bg,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildBudgetCard(),
                _buildCategoryRow(),
                _buildExpenseListHeader(),
                Expanded(child: _buildExpenseList()),
              ],
            ),
          ),
          floatingActionButton: _buildFAB(),
        ),
      ),
    );
  }

  

 Widget _buildHeader() {
  final now = DateTime.now();
  final dateStr = DateFormat('EEE, dd MMM yyyy').format(now);

  return Padding(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App name
            Text(
              'EXPENSO ✦',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            // ── Welcome text
            Row(
              children: [
                Text(
                  'WELCOME BACK, ',
                  style: TextStyle(
                    color: subtext,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'ANN 🌸',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // ── Live date with calendar icon
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: AppColors.accent,
                          surface: AppColors.darkSurface,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  // filter or highlight by date if needed
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.accent,
                      size: 11,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        // ── Dark/Light Toggle
        _ThemeToggle(
          isDark: widget.isDark,
          onToggle: widget.onThemeToggle,
          borderColor: border,
          textColor: text,
        ),
      ],
    ),
  );
}
  

  Widget _buildBudgetCard() {
    final progress = (totalSpent / budget).clamp(0.0, 1.0);
    final remaining = budget - totalSpent;

    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, 30 * (1 - _headerController.value)),
        child: Opacity(opacity: _headerController.value, child: child),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentGlow,
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL SPENT',
                      style: TextStyle(
                        color: Color(0xAAFFFFFF),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\₹${totalSpent.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'LEFT',
                        style: TextStyle(
                          color: Color(0xCCFFFFFF),
                          fontSize: 9,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        '\₹${remaining.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% of budget used',
                  style: const TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Budget: \₹${budget.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  

  Widget _buildCategoryRow() {
    final Map<ExpenseCategory, double> catTotals = {};
    for (final e in _expenses) {
      catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount;
    }

    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        children: ExpenseCategory.values.map((cat) {
          final total = catTotals[cat] ?? 0;
          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: total > 0
                  ? cat.color.withOpacity(widget.isDark ? 0.15 : 0.1)
                  : card,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: total > 0 ? cat.color.withOpacity(0.5) : border,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(cat.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 2),
                Text(
                  total > 0 ? '\₹${total.toStringAsFixed(0)}' : cat.label,
                  style: TextStyle(
                    color: total > 0 ? cat.color : subtext,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  

  Widget _buildExpenseListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(
        children: [
          Text(
            'TRANSACTIONS',
            style: TextStyle(
              color: text,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              '${_expenses.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'SWIPE TO DELETE',
            style: TextStyle(
              color: subtext,
              fontSize: 9,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildExpenseList() {
    if (_expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('◈', style: TextStyle(color: subtext, fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'NO EXPENSES YET',
              style: TextStyle(
                color: subtext,
                fontSize: 12,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        final expense = _expenses[index];
        return _ExpenseCard(
          expense: expense,
          isDark: widget.isDark,
          cardColor: card,
          borderColor: border,
          textColor: text,
          subtextColor: subtext,
          onDelete: () => _deleteExpense(expense.id),
        );
      },
    );
  }


  Widget _buildFAB() {
    return GestureDetector(
      onTap: _showAddExpenseSheet,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: text,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Icons.add, color: bg, size: 28),
      ),
    );
  }
}



class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;
  final Color borderColor;
  final Color textColor;

  const _ThemeToggle({
    required this.isDark,
    required this.onToggle,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        width: 72,
        height: 36,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFE8E4DF),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor),
        ),
        child: Stack(
          children: [
            // Labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(
                    '☀',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white.withOpacity(0.2)
                          : AppColors.accent,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Text(
                    '☾',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.accent
                          : Colors.black.withOpacity(0.2),
                    ),
                  ),
                ),
              ],
            ),
            // Sliding knob
            AnimatedAlign(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              alignment:
                  isDark ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  final bool isDark;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final Color subtextColor;
  final VoidCallback onDelete;

  const _ExpenseCard({
    required this.expense,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.subtextColor,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inHours < 1) return 'Just now';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  return DateFormat('dd MMM, EEE').format(date);
}

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFF3B30),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Text(
          'DELETE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: expense.category.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
              ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: expense.category.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: expense.category.color.withOpacity(0.3),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          expense.category.emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 14),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense.title.toUpperCase(),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${expense.category.label} · ${_formatDate(expense.date)}',
                              style: TextStyle(
                                color: subtextColor,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '-\₹${expense.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: expense.category.color,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
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


class AddExpenseSheet extends StatefulWidget {
  final bool isDark;
  final Function(Expense) onAdd;

  const AddExpenseSheet({
    super.key,
    required this.isDark,
    required this.onAdd,
  });

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;

  Color get bg => widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get card => widget.isDark ? AppColors.darkCard : AppColors.lightCard;
  Color get border => widget.isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get text => widget.isDark ? AppColors.darkText : AppColors.lightText;
  Color get subtext => AppColors.darkSubtext;

  void _submit() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text);

    if (title.isEmpty || amount == null || amount <= 0) return;

    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: _selectedCategory,
      date: DateTime.now(),
    );

    widget.onAdd(expense);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          border: Border.all(color: border),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Center(
              child: Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'NEW TRANSACTION',
              style: TextStyle(
                color: text,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 20),

            
            _buildField(
              controller: _titleController,
              label: 'WHAT DID YOU SPEND ON?',
              hint: 'e.g. Coffee, Uber, Groceries',
            ),
            const SizedBox(height: 16),

            _buildField(
              controller: _amountController,
              label: 'AMOUNT',
              hint: '0.00',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefix: Text(
                '\₹ ',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 20),

            
            Text(
              'CATEGORY',
              style: TextStyle(
                color: subtext,
                fontSize: 10,
                letterSpacing: 3,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExpenseCategory.values.map((cat) {
                final selected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? cat.color
                          : cat.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: selected
                            ? cat.color
                            : cat.color.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${cat.emoji} ${cat.label}',
                      style: TextStyle(
                        color: selected ? Colors.white : cat.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            
            GestureDetector(
              onTap: _submit,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'ADD EXPENSE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    Widget? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: subtext,
            fontSize: 10,
            letterSpacing: 3,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              color: text,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: subtext, fontWeight: FontWeight.w400),
              prefixIcon: prefix != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16, top: 12),
                      child: prefix,
                    )
                  : null,
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
