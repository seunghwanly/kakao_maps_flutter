part of 'widgets.dart';

/// Drawer header widget with Kakao Maps branding
class KakaoDrawerHeader extends StatelessWidget {
  const KakaoDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Color(0xFFFEE500),
        border: Border(
          bottom: BorderSide(color: Color(0xCC2e2e30), width: 4),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 40, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kakao Maps',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Flutter SDK v2 Demo',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section widget for grouping drawer items
class KakaoDrawerSection extends StatelessWidget {
  const KakaoDrawerSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        ...children,
        const Divider(height: 1),
      ],
    );
  }
}

/// Tile widget for drawer items
class KakaoDrawerTile extends StatelessWidget {
  const KakaoDrawerTile({
    required this.title,
    required this.enabled,
    required this.onTap,
    super.key,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? Colors.black87 : Colors.grey,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(fontSize: 12),
            )
          : null,
      onTap: enabled ? onTap : null,
      enabled: enabled,
    );
  }
}
