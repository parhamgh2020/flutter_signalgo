import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';

Future<void> showSignInSheet(BuildContext context, WidgetRef ref) {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            final l10n = AppLocalizations.of(context);
            String? error;
            var isSubmitting = false;

            Future<void> submit() async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              setState(() => isSubmitting = true);
              final failure = await ref
                  .read(authControllerProvider.notifier)
                  .signIn(emailController.text.trim(), passwordController.text);
              if (!context.mounted) return;
              if (failure == null) {
                Navigator.of(context).pop();
              } else {
                setState(() {
                  isSubmitting = false;
                  error = failure.localizedMessage(l10n);
                });
              }
            }

            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.signIn, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: l10n.emailLabel),
                    validator: (v) => (v == null || !v.contains('@')) ? l10n.emailLabel : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: l10n.passwordLabel),
                    validator: (v) => (v == null || v.length < 4) ? l10n.passwordLabel : null,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: isSubmitting ? null : submit,
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.signIn),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.continueAsGuest),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
