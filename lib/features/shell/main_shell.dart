import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import '../../core/services/location_service.dart';
import '../../core/services/tracking_service.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/trip.dart';
import '../home/home_tab.dart';
import '../memories/memories_tab.dart';
import '../profile/profile_tab.dart';
import '../trip/live_trip_sheet.dart';
import '../trips/trips_tab.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _tabs = <Widget>[
    HomeTab(),
    TripsTab(),
    MemoriesTab(),
    ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    TrackingService.instance.getActiveTrip();
    _setupWidgetLaunchListener();
  }

  void _setupWidgetLaunchListener() {
    HomeWidget.initiallyLaunchedFromHomeWidget().then((Uri? uri) {
      if (uri != null && mounted) {
        LiveTripSheet.show(context);
      }
    });

    HomeWidget.widgetClicked.listen((Uri? uri) {
      if (mounted) {
        LiveTripSheet.show(context);
      }
    });
  }

  Future<void> _handleCenterStartTrip() async {
    final active = TrackingService.instance.activeTrip;
    if (active != null) {
      LiveTripSheet.show(context);
    } else {
      final locService = LocationService();
      final perm = await locService.checkPermission();
      if (perm != LocationPermissionStatus.granted) {
        final req = await locService.requestPermission();
        if (req != LocationPermissionStatus.granted) return;
      }
      await TrackingService.instance.startTrip();
      if (mounted) {
        LiveTripSheet.show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _AnimatedPageStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: _MinimalNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        onStartTripTap: _handleCenterStartTrip,
      ),
    );
  }
}

/// Smooth cross-fade and slight elevation slide page stack that keeps page state alive.
class _AnimatedPageStack extends StatelessWidget {
  const _AnimatedPageStack({
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: List.generate(children.length, (i) {
        final isCurrent = i == index;
        return IgnorePointer(
          ignoring: !isCurrent,
          child: AnimatedOpacity(
            opacity: isCurrent ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: AnimatedSlide(
              offset: isCurrent ? Offset.zero : const Offset(0, 0.02),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              child: children[i],
            ),
          ),
        );
      }),
    );
  }
}

class _MinimalNavBar extends StatelessWidget {
  const _MinimalNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.onStartTripTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onStartTripTap;

  static int _tabToSlot(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 3;
      case 3:
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final slotWidth = totalWidth / 5;
              final slotIndex = _tabToSlot(currentIndex);

              const indicatorWidth = 32.0;
              const indicatorHeight = 3.0;
              final indicatorLeft =
                  slotIndex * slotWidth + (slotWidth - indicatorWidth) / 2;

              return Stack(
                children: [
                  // Smooth sliding indicator pill at top of active tab
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    top: 0,
                    left: indicatorLeft,
                    width: indicatorWidth,
                    height: indicatorHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.35),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Navigation bar items
                  Row(
                    children: [
                      _NavItem(
                        icon: Icons.dashboard_outlined,
                        activeIcon: Icons.dashboard,
                        label: 'Dashboard',
                        selected: currentIndex == 0,
                        onTap: () => onTap(0),
                      ),
                      _NavItem(
                        icon: Icons.history_outlined,
                        activeIcon: Icons.history,
                        label: 'Riwayat',
                        selected: currentIndex == 1,
                        onTap: () => onTap(1),
                      ),
                      _CenterNavActionItem(
                        label: 'Mulai',
                        onTap: onStartTripTap,
                      ),
                      _NavItem(
                        icon: Icons.auto_awesome_outlined,
                        activeIcon: Icons.auto_awesome,
                        label: 'Stories',
                        selected: currentIndex == 2,
                        onTap: () => onTap(2),
                      ),
                      _NavItem(
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                        label: 'Profile',
                        selected: currentIndex == 3,
                        onTap: () => onTap(3),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CenterNavActionItem extends StatefulWidget {
  const _CenterNavActionItem({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  State<_CenterNavActionItem> createState() => _CenterNavActionItemState();
}

class _CenterNavActionItemState extends State<_CenterNavActionItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder<Trip?>(
        valueListenable: TrackingService.instance.activeTripNotifier,
        builder: (context, activeTrip, child) {
          final isLive = activeTrip != null;
          final isPaused = activeTrip?.status == TripStatus.paused;
          final buttonColor = isPaused
              ? const Color(0xFFF59E0B)
              : AppColors.accent;

          final iconData = isPaused
              ? Icons.pause_circle_filled
              : (isLive ? Icons.sensors : Icons.play_arrow_rounded);

          final labelText =
              isPaused ? 'Istirahat' : (isLive ? 'Live Trip' : widget.label);

          return GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            behavior: HitTestBehavior.opaque,
            child: AnimatedScale(
              scale: _isPressed ? 0.92 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: buttonColor,
                          shape: BoxShape.circle,
                          boxShadow: isLive
                              ? [
                                  BoxShadow(
                                    color: buttonColor.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                        child: Icon(
                          iconData,
                          size: 20,
                          color: AppColors.surface,
                        ),
                      ),
                      if (isLive)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isPaused
                                  ? const Color(0xFFFCD34D)
                                  : Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    labelText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: buttonColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.accentSoft.withValues(alpha: 0.4),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.accentSoft.withValues(alpha: 0.65)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedScale(
                scale: selected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Icon(
                    selected ? activeIcon : icon,
                    key: ValueKey<bool>(selected),
                    size: 21,
                    color: selected ? AppColors.accent : AppColors.inkSoft,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.accent : AppColors.inkSoft,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
