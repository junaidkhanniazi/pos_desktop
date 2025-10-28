import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';
import 'package:pos_desktop/presentation/widgets/app_input.dart';

class SidebarItem {
  final IconData icon;
  final String label;
  const SidebarItem({required this.icon, required this.label});
}

class BaseDashboardLayout extends StatefulWidget {
  final String title; // e.g. "Cashier", "Inventory Manager"
  final List<SidebarItem> items; // sidebar menu
  final List<Widget> pages; // screens for each item (same length)
  final Widget? footer; // optional footer widget

  const BaseDashboardLayout({
    super.key,
    required this.title,
    required this.items,
    required this.pages,
    this.footer,
  }) : assert(items.length == pages.length, 'items & pages length must match');

  @override
  State<BaseDashboardLayout> createState() => _BaseDashboardLayoutState();
}

class _BaseDashboardLayoutState extends State<BaseDashboardLayout> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 240,
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.08),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Text(
                  widget.title,
                  style: AppText.h2.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.separated(
                    itemCount: widget.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, i) {
                      final it = widget.items[i];
                      final isSel = selectedIndex == i;
                      final color = isSel
                          ? AppColors.primary
                          : AppColors.textMedium;
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => selectedIndex = i),
                        hoverColor: AppColors.primary.withOpacity(0.05),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(horizontal: 14),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppColors.primary.withOpacity(0.08)
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(it.icon, color: color, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                it.label,
                                style: AppText.body.copyWith(
                                  color: color,
                                  fontWeight: isSel
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (widget.footer != null) widget.footer!,
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Main Column
          Expanded(
            child: Column(
              children: [
                // Topbar
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.layoutDashboard,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "${widget.title} Dashboard",
                            style: AppText.h3.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 220,
                            child: AppInput(
                              controller: TextEditingController(),
                              hint: "Search...",
                              icon: LucideIcons.search,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            LucideIcons.bell,
                            color: AppColors.textMedium,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary,
                            child: Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Page
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      key: ValueKey(selectedIndex),
                      color: AppColors.background,
                      child: widget.pages[selectedIndex],
                    ),
                  ),
                ),

                // Footer
                Container(
                  height: 40,
                  alignment: Alignment.center,
                  color: AppColors.surface,
                  child: Text(
                    "© 2025 POS Desktop",
                    style: AppText.small.copyWith(color: AppColors.textLight),
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
