import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../providers/documents_provider.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/common/app_search_bar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/catalogue/book_cards.dart';

const _categories = ['Tous', 'Livres', 'Magazines', 'DVD', 'Pédagogique'];

class CatalogueScreen extends ConsumerStatefulWidget {
  const CatalogueScreen({super.key});

  @override
  ConsumerState<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends ConsumerState<CatalogueScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allDocs = ref.watch(documentsProvider).value ?? [];
    final filtered = ref.watch(filteredDocumentsProvider);
    final selected = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Catalogue', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${allDocs.length} documents disponibles', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 16),
                  AppSearchBar(
                    controller: _ctrl,
                    onChanged: (v) => ref.read(searchQueryProvider.notifier).set(v),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // FILTER CHIPS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: _categories.map((cat) {
                  final active = cat == selected;
                  return GestureDetector(
                    onTap: () => ref.read(selectedCategoryProvider.notifier).set(cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? AppColors.accent : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: active ? AppColors.accent : AppColors.border),
                      ),
                      child: Text(cat, style: TextStyle(color: active ? Colors.white : AppColors.textSecondary, fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
                    ),
                  );
                }).toList(),
              ),
            ),

            // COUNT
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Text('${filtered.length} résultats', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ),

            // GRID
            Expanded(
              child: filtered.isEmpty
                  ? const EmptyState(emoji: '🔍', title: 'Aucun résultat', subtitle: 'Essayez un autre terme ou filtre')
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => BookGridCard(document: filtered[i]),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}
