import 'package:flutter/material.dart';
import '../../core/services/sync_service.dart';

class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SyncState>(
      valueListenable: SyncService.instance.syncStateNotifier,
      builder: (context, state, child) {
        final config = _getBadgeConfig(state);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => SyncService.instance.triggerSync(),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: config.backgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: config.borderColor, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state == SyncState.syncing)
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(config.textColor),
                      ),
                    )
                  else
                    Icon(
                      config.icon,
                      size: 14,
                      color: config.textColor,
                    ),
                  const SizedBox(width: 5),
                  Text(
                    config.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: config.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _BadgeConfig _getBadgeConfig(SyncState state) {
    switch (state) {
      case SyncState.offline:
        return const _BadgeConfig(
          label: 'Offline (Local)',
          icon: Icons.wifi_off_rounded,
          backgroundColor: Color(0xFFFEF3C7),
          borderColor: Color(0xFFFCD34D),
          textColor: Color(0xFF92400E),
        );
      case SyncState.syncing:
        return const _BadgeConfig(
          label: 'Syncing...',
          icon: Icons.sync_rounded,
          backgroundColor: Color(0xFFEFF6FF),
          borderColor: Color(0xFF93C5FD),
          textColor: Color(0xFF1D4ED8),
        );
      case SyncState.synced:
        return const _BadgeConfig(
          label: 'Synced',
          icon: Icons.cloud_done_rounded,
          backgroundColor: Color(0xFFECFDF5),
          borderColor: Color(0xFF6EE7B7),
          textColor: Color(0xFF065F46),
        );
      case SyncState.failed:
        return const _BadgeConfig(
          label: 'Sync Failed (Retry)',
          icon: Icons.sync_problem_rounded,
          backgroundColor: Color(0xFFFEF2F2),
          borderColor: Color(0xFFFCA5A5),
          textColor: Color(0xFF991B1B),
        );
    }
  }
}

class _BadgeConfig {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const _BadgeConfig({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}
