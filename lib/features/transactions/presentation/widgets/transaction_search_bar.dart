import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TransactionSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const TransactionSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  @override
  State<TransactionSearchBar> createState() => _TransactionSearchBarState();
}

class _TransactionSearchBarState extends State<TransactionSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: t.searchFieldShellDecoration,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: TextField(
          controller: widget.controller,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Buscar por título (mín. 3 caracteres)...',
            hintStyle: TextStyle(color: t.textSecondary.withValues(alpha: 0.85)),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: t.textSecondary.withValues(alpha: 0.9),
            ),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: t.textSecondary.withValues(alpha: 0.9),
                    ),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onSearch();
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: t.primaryLight.withValues(alpha: 0.45)),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            helperText: widget.controller.text.isNotEmpty && widget.controller.text.length < 3
                ? 'Digite pelo menos 3 caracteres'
                : null,
            helperStyle: Theme.of(context).textTheme.bodySmall,
          ),
          onChanged: (value) {
            setState(() {});
            if (value.isEmpty || value.length >= 3) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (widget.controller.text == value) widget.onSearch();
              });
            }
          },
        ),
      ),
    );
  }
}
