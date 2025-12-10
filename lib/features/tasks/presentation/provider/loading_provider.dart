import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to track if a create operation is in progress
final createLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider to track if an edit operation is in progress
final editLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider to track if a delete operation is in progress
final deleteLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider to track if a toggle operation is in progress
final toggleLoadingProvider = StateProvider<String?>((ref) => null); // stores todo id being toggled

/// Provider to track error messages
final errorMessageProvider = StateProvider<String?>((ref) => null);

/// Provider to track success messages
final successMessageProvider = StateProvider<String?>((ref) => null);
