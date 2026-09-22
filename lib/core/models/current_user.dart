import 'package:flutter/foundation.dart';

@immutable
class CurrentUser {
  const CurrentUser({required this.id, this.email, required this.isAnonymous});

  final String id;
  final String? email;
  final bool isAnonymous;
}
