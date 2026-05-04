import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ServiceCardData {
  final IconData icon;
  final String label;
  final Color color;

  const ServiceCardData({required this.icon, required this.label, required this.color});
}

class ServiceScrollSection extends StatefulWidget {
  final String title;
  final List<ServiceCardData> items;

  const ServiceScrollSection({super.key, required this.title, required this.items});

  @override
  State<ServiceScrollSection> createState() => _ServiceScrollSectionState();
}

class _ServiceScrollSectionState extends State<ServiceScrollSection> {
  late final ScrollController _scrollController;
  final _progress = ValueNotifier<double>(0.0);

  static const double _cardWidth = 100.0;
  static const double _cardSpacing = 12.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.maxScrollExtent > 0) {
      _progress.value = _scrollController.offset / _scrollController.position.maxScrollExtent;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(widget.title, style: Theme.of(context).textTheme.headlineMedium),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final viewportWidth = constraints.maxWidth;
            return AnimatedBuilder(
              animation: _scrollController,
              builder: (context, _) {
                final offset =
                    _scrollController.hasClients ? _scrollController.offset : 0.0;
                return SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    children: widget.items.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      final cardCenter =
                          idx * (_cardWidth + _cardSpacing) + _cardWidth / 2 - offset;
                      final distFromCenter = (cardCenter - viewportWidth / 2).abs();
                      final scale =
                          (1.0 - (distFromCenter / viewportWidth).clamp(0.0, 1.0) * 0.10)
                              .clamp(0.90, 1.0);

                      return Padding(
                        padding: EdgeInsets.only(
                          right: idx < widget.items.length - 1 ? _cardSpacing : 0,
                        ),
                        child: Transform.scale(
                          scale: scale,
                          child: _ServiceCard(data: item),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder<double>(
          valueListenable: _progress,
          builder: (context, value, _) {
            final t = AppTheme.of(context);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: t.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(t.primaryLight),
                  minHeight: 3,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceCardData data;

  const _ServiceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [data.color.withValues(alpha: 0.25), t.surface],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: data.color.withValues(alpha: 0.18)),
            ),
            child: Icon(data.icon, color: data.color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            data.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
