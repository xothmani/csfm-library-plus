import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/document_model.dart';

// All documents stream
final documentsProvider = StreamProvider<List<DocumentModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('documents')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => DocumentModel.fromMap(d.data(), d.id)).toList());
});

// Search query — using Notifier (Riverpod 3)
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String v) => state = v;
}
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

// Selected category — using Notifier (Riverpod 3)
class CategoryNotifier extends Notifier<String> {
  @override
  String build() => 'Tous';
  void set(String v) => state = v;
}
final selectedCategoryProvider = NotifierProvider<CategoryNotifier, String>(CategoryNotifier.new);

// Filtered docs (by category + search)
final filteredDocumentsProvider = Provider<List<DocumentModel>>((ref) {
  final docs = ref.watch(documentsProvider).value ?? [];
  final query = ref.watch(searchQueryProvider);
  final category = ref.watch(selectedCategoryProvider);

  var filtered = docs;

  if (category != 'Tous') {
    final key = _labelToKey(category);
    filtered = filtered.where((d) => d.category == key).toList();
  }

  if (query.isNotEmpty) {
    final q = query.toLowerCase();
    filtered = filtered
        .where((d) =>
            d.title.toLowerCase().contains(q) ||
            d.author.toLowerCase().contains(q))
        .toList();
  }

  return filtered;
});

// Single document detail
final documentDetailProvider =
    FutureProvider.family<DocumentModel?, String>((ref, docId) async {
  final doc = await FirebaseFirestore.instance
      .collection('documents')
      .doc(docId)
      .get();
  if (doc.exists && doc.data() != null) {
    return DocumentModel.fromMap(doc.data()!, doc.id);
  }
  return null;
});

String _labelToKey(String label) {
  switch (label) {
    case 'Livres': return 'book';
    case 'Magazines': return 'magazine';
    case 'DVD': return 'dvd';
    case 'Pédagogique': return 'pedagogical';
    default: return label.toLowerCase();
  }
}
