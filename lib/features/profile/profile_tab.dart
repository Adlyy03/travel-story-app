import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../dev/seed_dummy_trip.dart';
import '../../shared/widgets/sync_status_badge.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: const [
          Center(child: SyncStatusBadge()),
          SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar placeholder
          Center(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 2),
                  ),
                  child: const Icon(Icons.person_outline, size: 40, color: AppColors.accent),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Traveler',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Simpan setiap langkah perjalananmu',
                  style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),

          // Settings section
          const _SectionLabel('Tentang'),
          _SettingItem(
            icon: Icons.info_outlined,
            label: 'Travel Story',
            trailing: const Text(
              'v1.0',
              style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
            ),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Travel Story',
                applicationVersion: 'v1.0',
                applicationIcon: const Icon(Icons.route, color: AppColors.accent, size: 40),
                children: const [
                  Text(
                    'Aplikasi perekam perjalanan personal otomatis dengan timeline, peta interaktif, dan generator story estetis.',
                    style: TextStyle(fontSize: 14, color: AppColors.inkSoft),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          const _SectionLabel('Developer'),
          _SettingItem(
            icon: Icons.science_outlined,
            label: 'Generate Dummy Trip (Bogor)',
            onTap: null,
            onTapAsync: (context) async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generating dummy trip...')),
              );
              await seedDummyTripBogor();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ Dummy trip created!')),
                );
              }
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.inkSoft,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.onTapAsync,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Future<void> Function(BuildContext)? onTapAsync;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap ?? (onTapAsync != null ? () => onTapAsync!(context) : null),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.ink),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 15, color: AppColors.ink),
                ),
              ),
              ?trailing,
              if ((onTap != null || onTapAsync != null) && trailing == null)
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}
