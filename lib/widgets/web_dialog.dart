import 'package:flutter/material.dart';

/// Dialog modern pengganti alert() / confirm() / prompt() dari JavaScript.
abstract final class WebDialog {
  // ── Alert ──────────────────────────────────────────────────────────────────

  static Future<void> alert(
    BuildContext context, {
    required String message,
    String? host,
  }) {
    return _show<void>(
      context,
      icon: Icons.info_outline_rounded,
      iconColor: const Color(0xFF2563EB),
      title: 'Pemberitahuan',
      message: message,
      host: host,
      actions: (pop) => [
        _PrimaryButton(label: 'OK', onTap: () => pop(null)),
      ],
    );
  }

  // ── Confirm ────────────────────────────────────────────────────────────────

  static Future<bool> confirm(
    BuildContext context, {
    required String message,
    String? host,
  }) async {
    final result = await _show<bool>(
      context,
      icon: Icons.help_outline_rounded,
      iconColor: const Color(0xFFD97706),
      title: 'Konfirmasi',
      message: message,
      host: host,
      actions: (pop) => [
        _OutlineButton(label: 'Batal', onTap: () => pop(false)),
        _PrimaryButton(label: 'OK', onTap: () => pop(true)),
      ],
    );
    return result ?? false;
  }

  // ── Prompt ─────────────────────────────────────────────────────────────────

  static Future<String?> prompt(
    BuildContext context, {
    required String message,
    String? defaultValue,
    String? host,
  }) {
    final controller = TextEditingController(text: defaultValue ?? '');
    return _show<String?>(
      context,
      icon: Icons.edit_outlined,
      iconColor: const Color(0xFF7C3AED),
      title: 'Input',
      message: message,
      host: host,
      extra: _PromptField(controller: controller),
      actions: (pop) => [
        _OutlineButton(label: 'Batal', onTap: () => pop(null)),
        _PrimaryButton(label: 'OK', onTap: () => pop(controller.text)),
      ],
    );
  }

  // ── Internal builder ───────────────────────────────────────────────────────

  static Future<T?> _show<T>(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    String? host,
    Widget? extra,
    required List<Widget> Function(void Function(T?) pop) actions,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'dialog',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: (_, anim, a2, child) {
        final curved =
            CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: ScaleTransition(scale: curved, child: child),
        );
      },
      pageBuilder: (ctx, a1, a2) {
        return _WebDialogContent<T>(
          icon: icon,
          iconColor: iconColor,
          title: title,
          message: message,
          host: host,
          extra: extra,
          actions: actions,
        );
      },
    );
  }
}

// ── Dialog body ────────────────────────────────────────────────────────────

class _WebDialogContent<T> extends StatelessWidget {
  const _WebDialogContent({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    this.host,
    this.extra,
    required this.actions,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String? host;
  final Widget? extra;
  final List<Widget> Function(void Function(T?) pop) actions;

  @override
  Widget build(BuildContext context) {
    void pop(T? v) => Navigator.of(context).pop(v);
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .18),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Icon area ──────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 28, bottom: 4),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: .08),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: .12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: iconColor, size: 28),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                          letterSpacing: -.3,
                        ),
                      ),
                      if (host != null && host!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            host!,
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // ── Message ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                      height: 1.55,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // ── Extra widget (prompt field) ────────────────────────
                if (extra != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: extra,
                  ),

                // ── Actions ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Row(
                    children: actions(pop)
                        .map((btn) => Expanded(child: btn))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Prompt text field ──────────────────────────────────────────────────────

class _PromptField extends StatelessWidget {
  const _PromptField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      autofocus: true,
      style: TextStyle(fontSize: 14, color: scheme.onSurface),
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: .4),
      ),
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
    );
  }
}

// ── Button styles ──────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(label),
    );
  }
}
