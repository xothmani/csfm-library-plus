import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DocumentModel {
  final String id;
  final String title;
  final String author;
  final String category; // 'book' | 'magazine' | 'dvd' | 'pedagogical'
  final int year;
  final String description;
  final String? coverUrl;
  final int totalCopies;
  final int availableCopies;
  final bool isAvailable;
  final List<String> tags;
  final DateTime createdAt;

  DocumentModel({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.year,
    required this.description,
    this.coverUrl,
    required this.totalCopies,
    required this.availableCopies,
    required this.isAvailable,
    required this.tags,
    required this.createdAt,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map, String docId) {
    return DocumentModel(
      id: docId,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      category: map['category'] ?? 'book',
      year: map['year'] ?? 2024,
      description: map['description'] ?? '',
      coverUrl: map['coverUrl'],
      totalCopies: map['totalCopies'] ?? 1,
      availableCopies: map['availableCopies'] ?? 0,
      isAvailable: map['isAvailable'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String get categoryEmoji {
    switch (category) {
      case 'book': return '📘';
      case 'magazine': return '🗞️';
      case 'dvd': return '💿';
      case 'pedagogical': return '📋';
      default: return '📗';
    }
  }

  String get categoryLabel {
    switch (category) {
      case 'book': return 'Livre';
      case 'magazine': return 'Magazine';
      case 'dvd': return 'DVD';
      case 'pedagogical': return 'Pédagogique';
      default: return 'Document';
    }
  }

  List<Color> get gradientColors {
    switch (category) {
      case 'book': return [const Color(0xFF1A2A4A), const Color(0xFF0D1A34)];
      case 'magazine': return [const Color(0xFF2A1A4A), const Color(0xFF1A0D34)];
      case 'dvd': return [const Color(0xFF0A2A2A), const Color(0xFF051A1A)];
      case 'pedagogical': return [const Color(0xFF0A2A1A), const Color(0xFF051A0D)];
      default: return [AppColors.surface, AppColors.surfaceElevated];
    }
  }
}
