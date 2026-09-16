import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../domain/story_model.dart';
import '../services/story_share_service.dart';
import '../../../core/theme/app_colors.dart';

/// 9:16 animated story player.
/// Sequence: Cover → Route Draw → Stats → Photos → Summary.
class StoryAnimatedPlayer extends StatefulWidget {
  const StoryAnimatedPlayer({super.key});

  @override
  State<StoryAnimatedPlayer> createState() => _StoryAnimatedPlayerState();
}

class _StoryAnimatedPlayerState extends State<StoryAnimatedPlayer>
    with SingleTickerProviderStateMixin {
  StoryModel? _story;
  bool _isSharing = false;
  bool _isPaused = false;

  late AnimationController _master;

  // 5 Scene bounds (normalized 0.0 - 1.0)
  static const double _s0Start = 0.00;
  static const double _s0End = 0.20;

  static const double _s1Start = 0.20;
  static const double _s1End = 0.46;

  static const double _s2Start = 0.46;
  static const double _s2End = 0.72;

  static const double _s3Start = 0.72;
  static const double _s3End = 0.88;

  static const double _s4Start = 0.88;
  static const double _s4End = 1.00;

  @override
  void initState() {
    super.initState();
    _master = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );

    _master.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isPaused = true);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_story == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is StoryModel) {
        _story = args;
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _master.forward();
        });
      }
    }
  }

  @override
  void dispose() {
    _master.dispose();
    super.dispose();
  }

  void _togglePause() {
    if (_master.isCompleted) {
      _master.reset();
      _master.forward();
      setState(() => _isPaused = false);
    } else if (_master.isAnimating) {
      _master.stop();
      setState(() => _isPaused = true);
    } else {
      _master.forward();
      setState(() => _isPaused = false);
    }
  }

  void _jumpToScene(int index) {
    const sceneStarts = [_s0Start, _s1Start, _s2Start, _s3Start, _s4Start];
    if (index >= 0 && index < sceneStarts.length) {
      _master.animateTo(
        sceneStarts[index],
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      if (_isPaused) {
        setState(() => _isPaused = false);
        _master.forward();
      }
    }
  }

  void _handleTapDown(TapDownDetails details, double width) {
    final dx = details.localPosition.dx;
    final progress = _master.value;

    if (dx < width * 0.28) {
      // Tap Left: go to previous scene
      if (progress > _s4Start) {
        _jumpToScene(3);
      } else if (progress > _s3Start) {
        _jumpToScene(2);
      } else if (progress > _s2Start) {
        _jumpToScene(1);
      } else if (progress > _s1Start) {
        _jumpToScene(0);
      } else {
        _master.reset();
        _master.forward();
      }
    } else if (dx > width * 0.72) {
      // Tap Right: go to next scene
      if (progress < _s1Start) {
        _jumpToScene(1);
      } else if (progress < _s2Start) {
        _jumpToScene(2);
      } else if (progress < _s3Start) {
        _jumpToScene(3);
      } else if (progress < _s4Start) {
        _jumpToScene(4);
      }
    } else {
      // Tap Center: toggle pause
      _togglePause();
    }
  }

  Future<void> _shareStory() async {
    if (_story == null || _isSharing) return;
    setState(() => _isSharing = true);
    try {
      await StoryShareService().shareStory(_story!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membagikan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  double _opacity(double t, double start, double fadeIn, double fadeOut, double end) {
    if (t < start || t > end) return 0.0;
    if (t < fadeIn) return (t - start) / (fadeIn - start);
    if (t <= fadeOut) return 1.0;
    return (1.0 - (t - fadeOut) / (end - fadeOut)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Story Video Player',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.white70),
            tooltip: 'Edit Story',
            onPressed: () {
              if (_story != null) {
                Navigator.pushReplacementNamed(context, '/story/editor', arguments: _story!);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.replay, color: Colors.white),
            tooltip: 'Putar Ulang',
            onPressed: () {
              _master.reset();
              _master.forward();
              setState(() => _isPaused = false);
            },
          ),
          if (_isSharing)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.white),
              tooltip: 'Bagikan',
              onPressed: _shareStory,
            ),
        ],
      ),
      body: _story == null
          ? const Center(
              child: Text('Tidak ada data story',
                  style: TextStyle(color: Colors.white54)))
          : LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: GestureDetector(
                      onTapDown: (d) => _handleTapDown(d, constraints.maxWidth),
                      behavior: HitTestBehavior.opaque,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AnimatedBuilder(
                            animation: _master,
                            builder: (context, _) => _buildVideoContent(_story!, _master.value),
                          ),

                          // Top Segmented Progress Bar (Instagram-style 5 segments)
                          Positioned(
                            top: 12,
                            left: 14,
                            right: 14,
                            child: AnimatedBuilder(
                              animation: _master,
                              builder: (context, _) => _buildSegmentedProgressBar(_master.value),
                            ),
                          ),

                          // Center Pause/Resume Indicator
                          if (_isPaused && !_master.isCompleted)
                            Center(
                              child: Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white30, width: 1.5),
                                ),
                                child: const Icon(Icons.play_arrow_rounded,
                                    color: Colors.white, size: 40),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSegmentedProgressBar(double t) {
    const segments = [
      [_s0Start, _s0End],
      [_s1Start, _s1End],
      [_s2Start, _s2End],
      [_s3Start, _s3End],
      [_s4Start, _s4End],
    ];

    return Row(
      children: List.generate(segments.length, (i) {
        final start = segments[i][0];
        final end = segments[i][1];

        double fill = 0.0;
        if (t >= end) {
          fill = 1.0;
        } else if (t > start) {
          fill = ((t - start) / (end - start)).clamp(0.0, 1.0);
        }

        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: i == 0 ? 0 : 3),
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fill,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildVideoContent(StoryModel story, double t) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF070B14), Color(0xFF0F172A), Color(0xFF0A0F1D)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Scene 0: Cover (0.00 - 0.20)
          if (t >= _s0Start && t <= _s0End)
            Opacity(
              opacity: _opacity(t, _s0Start, 0.03, 0.17, _s0End),
              child: _buildCoverScene(story, t),
            ),

          // Scene 1: Route Draw (0.20 - 0.46)
          if (t >= _s1Start && t <= _s1End)
            Opacity(
              opacity: _opacity(t, _s1Start, 0.23, 0.43, _s1End),
              child: _buildRouteScene(story, t),
            ),

          // Scene 2: Stats & Highlights (0.46 - 0.72)
          if (t >= _s2Start && t <= _s2End)
            Opacity(
              opacity: _opacity(t, _s2Start, 0.49, 0.69, _s2End),
              child: _buildStatsScene(story, t),
            ),

          // Scene 3: Momen Foto & Singgah (0.72 - 0.88)
          if (t >= _s3Start && t <= _s3End)
            Opacity(
              opacity: _opacity(t, _s3Start, 0.75, 0.85, _s3End),
              child: _buildPhotosScene(story, t),
            ),

          // Scene 4: Summary Finale Outro (0.88 - 1.00)
          if (t >= _s4Start)
            Opacity(
              opacity: _opacity(t, _s4Start, 0.91, 1.00, 1.00),
              child: _buildSummaryScene(story, t),
            ),
        ],
      ),
    );
  }

  Widget _buildCoverScene(StoryModel story, double t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 1.5),
              ),
              child: const Icon(Icons.auto_awesome, size: 44, color: AppColors.accent),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: const Text(
                'TRAVEL STORY EPISODE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              story.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.25,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              DateFormat('EEEE, d MMMM yyyy', 'id').format(story.date),
              style: const TextStyle(fontSize: 14, color: Colors.white60),
            ),
            if (story.route.isNotEmpty) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.route_outlined, size: 16, color: Color(0xFF00F5D4)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        story.route,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRouteScene(StoryModel story, double t) {
    // Progressive draw factor: 0.0 at 0.22, 1.0 at 0.42
    final drawFactor = ((t - 0.22) / (0.42 - 0.22)).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF00F5D4),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ANIMASI JALUR PERJALANAN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00F5D4),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: story.routePoints.length >= 2
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: CustomPaint(
                        painter: _AnimatedRoutePainter(
                          points: story.routePoints,
                          progress: drawFactor,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  )
                : Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.map_outlined, size: 56, color: Color(0xFF00F5D4)),
                          const SizedBox(height: 16),
                          Text(
                            story.route.isNotEmpty ? story.route : story.title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Jalur terekam lengkap pada trip ini',
                            style: TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          if (story.distanceMeters != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                'Total Jarak: ${_formatDistance(story.distanceMeters! * drawFactor)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsScene(StoryModel story, double t) {
    // Count progress: 0.0 at 0.49, 1.0 at 0.67
    final countFactor = Curves.easeOutCubic.transform(((t - 0.49) / (0.67 - 0.49)).clamp(0.0, 1.0));

    final dist = story.distanceMeters ?? 0.0;
    final dur = story.durationSeconds ?? 0;
    final speed = story.averageSpeedKmh ?? 0.0;
    final elev = story.elevationGainMeters ?? 0.0;

    final animDist = dist * countFactor;
    final animDur = (dur * countFactor).toInt();
    final animSpeed = speed * countFactor;
    final animElev = elev * countFactor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'STATISTIK & PENCAPAIAN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _StatHeroCard(
                label: 'TOTAL JARAK',
                value: _formatDistance(animDist),
                color: const Color(0xFF00F5D4),
                icon: Icons.straighten_rounded,
              ),
              const SizedBox(width: 12),
              _StatHeroCard(
                label: 'DURASI AKTIF',
                value: _formatDuration(animDur),
                color: Colors.white,
                icon: Icons.timer_outlined,
              ),
            ],
          ),
          const SizedBox(width: 0, height: 12),
          Row(
            children: [
              _StatHeroCard(
                label: 'KECEPATAN RATA-RATA',
                value: '${animSpeed.toStringAsFixed(1)} km/h',
                color: const Color(0xFFFFB703),
                icon: Icons.speed_rounded,
              ),
              const SizedBox(width: 12),
              _StatHeroCard(
                label: 'ELEVASI / SINGGAH',
                value: animElev > 0
                    ? '+${animElev.toStringAsFixed(0)}m'
                    : '${story.places.length} Lokasi',
                color: const Color(0xFFFF70A6),
                icon: Icons.terrain_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosScene(StoryModel story, double t) {
    final hasPhotos = story.photos.isNotEmpty;
    final photos = story.photos.take(3).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'MOMEN & SINGGAH PERJALANAN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          if (hasPhotos)
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: photos.length,
                itemBuilder: (ctx, i) {
                  final p = photos[i];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Image.file(
                        File(p.path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.white12,
                          child: const Icon(Icons.broken_image, color: Colors.white30),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.place_outlined, size: 48, color: AppColors.accent),
                      const SizedBox(height: 16),
                      Text(
                        '${story.places.length} Tempat Disinggahi',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        story.route.isNotEmpty ? story.route : 'Perjalanan tersimpan rapi',
                        style: const TextStyle(color: Colors.white60, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryScene(StoryModel story, double t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.5),
                    blurRadius: 16,
                  )
                ],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 20),
            const Text(
              'CERITA SELESAI',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              story.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatDistance(story.distanceMeters ?? 0)} · ${_formatDuration(story.durationSeconds ?? 0)}',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  _master.reset();
                  _master.forward();
                  setState(() => _isPaused = false);
                },
                icon: const Icon(Icons.replay_rounded, size: 20),
                label: const Text('Putar Ulang Video'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/story/editor', arguments: story);
                    },
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: const Text('Edit Template'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareStory,
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('Bagikan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDistance(double m) =>
      m >= 1000 ? '${(m / 1000).toStringAsFixed(1)} km' : '${m.toStringAsFixed(0)} m';

  String _formatDuration(int s) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }
}

class _StatHeroCard extends StatelessWidget {
  const _StatHeroCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white54,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// CustomPainter that draws a route progressively from start to finish.
class _AnimatedRoutePainter extends CustomPainter {
  _AnimatedRoutePainter({
    required this.points,
    required this.progress,
  });

  final List<RoutePoint> points;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    double minLat = points.first.lat;
    double maxLat = points.first.lat;
    double minLng = points.first.lng;
    double maxLng = points.first.lng;
    for (final p in points) {
      if (p.lat < minLat) minLat = p.lat;
      if (p.lat > maxLat) maxLat = p.lat;
      if (p.lng < minLng) minLng = p.lng;
      if (p.lng > maxLng) maxLng = p.lng;
    }
    final latRange = maxLat - minLat;
    final lngRange = maxLng - minLng;
    if (latRange == 0 && lngRange == 0) return;

    const pad = 28.0;
    final drawW = size.width - pad * 2;
    final drawH = size.height - pad * 2;

    Offset project(RoutePoint p) {
      final nx = lngRange == 0 ? 0.5 : (p.lng - minLng) / lngRange;
      final ny = latRange == 0 ? 0.5 : (p.lat - minLat) / latRange;
      return Offset(pad + nx * drawW, pad + (1 - ny) * drawH);
    }

    final projected = points.map(project).toList();
    final drawUpTo = (projected.length * progress).round().clamp(1, projected.length);
    final visiblePoints = projected.sublist(0, drawUpTo);

    if (visiblePoints.length < 2) return;

    final path = Path();
    path.moveTo(visiblePoints.first.dx, visiblePoints.first.dy);
    for (final pt in visiblePoints.skip(1)) {
      path.lineTo(pt.dx, pt.dy);
    }

    // Shadow
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Main route line (Cyan neon)
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF00F5D4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    // Inner Highlight
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Start pin
    final start = projected.first;
    canvas.drawCircle(start, 12, Paint()..color = const Color(0x4410B981));
    canvas.drawCircle(start, 7, Paint()..color = const Color(0xFF10B981));
    canvas.drawCircle(start, 3, Paint()..color = Colors.white);

    // End pin (drawn when reached)
    if (drawUpTo == projected.length) {
      final end = projected.last;
      canvas.drawCircle(end, 12, Paint()..color = const Color(0x44FF5722));
      canvas.drawCircle(end, 7, Paint()..color = const Color(0xFFFF5722));
      canvas.drawCircle(end, 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedRoutePainter old) =>
      old.progress != progress || old.points != points;
}

