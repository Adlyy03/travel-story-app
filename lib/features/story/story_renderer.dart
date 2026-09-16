import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../../core/services/route_smoother.dart';
import 'domain/story_model.dart';
import 'domain/story_template.dart';

class StoryDesign {
  static const double canvasWidth = 1080;
  static const double canvasHeight = 1920;

  static const Color textWhite = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color accent = Color(0xFFFF5722); // Vibrant Orange
  static const Color accentCyan = Color(0xFF00F5D4); // Neon Cyan

  static const double margin = 64;
}

class StoryRenderer {
  Future<Uint8List> render(StoryModel story) async {
    switch (story.template) {
      case StoryTemplate.minimal:
        return await _renderMinimal(story);
      case StoryTemplate.cinematic:
        return await _renderCinematic(story);
      case StoryTemplate.strava:
        return await _renderStrava(story);
      case StoryTemplate.journal:
        return await _renderJournal(story);
      case StoryTemplate.glass:
        return await _renderGlass(story);
    }
  }

  // ---------------------------------------------------------------------------
  // Glass Template (existing logic, moved to named method)
  // ---------------------------------------------------------------------------
  Future<Uint8List> _renderGlass(StoryModel story) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, StoryDesign.canvasWidth, StoryDesign.canvasHeight),
    );

    // 1. Background
    if (story.backgroundImagePath != null &&
        File(story.backgroundImagePath!).existsSync()) {
      await _drawBackgroundImage(canvas, story.backgroundImagePath!);
    } else {
      _drawModernGradientBackground(canvas);
    }

    // 2. Legibility Gradients
    _drawTopGradient(canvas);
    _drawBottomGradient(canvas);

    // 3. Header Badge
    _drawHeaderBadge(canvas, story);

    // 4. Hero Polyline Route
    if (story.showRoute && story.routePoints.isNotEmpty) {
      await _drawDetailedPolyline(canvas, story.routePoints);
    }

    // 5. Bottom Stats Card
    if (story.showStatistics) {
      _drawBottomCard(canvas, story);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      StoryDesign.canvasWidth.toInt(),
      StoryDesign.canvasHeight.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // ---------------------------------------------------------------------------
  // Minimal Template: white/light bg, black typography, route center
  // ---------------------------------------------------------------------------
  Future<Uint8List> _renderMinimal(StoryModel story) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, StoryDesign.canvasWidth, StoryDesign.canvasHeight),
    );

    // White/off-white background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, StoryDesign.canvasWidth, StoryDesign.canvasHeight),
      Paint()..color = const Color(0xFFF8F9FA),
    );

    // Thin accent top bar
    canvas.drawRect(
      Rect.fromLTWH(0, 0, StoryDesign.canvasWidth, 8),
      Paint()..color = StoryDesign.accent,
    );

    const inkColor = Color(0xFF0F172A);
    const mutedColor = Color(0xFF64748B);
    const margin = StoryDesign.margin;

    // Date small
    final dateStr = DateFormat('EEEE · d MMMM yyyy').format(story.date).toUpperCase();
    _drawText(canvas, dateStr, margin, 80, 18, mutedColor, letterSpacing: 1.5);

    // Big title
    _drawTextWrapped(canvas, story.title, margin, 130, 72, inkColor, bold: true,
        maxWidth: StoryDesign.canvasWidth - margin * 2, maxLines: 2);

    // Route pill
    if (story.route.isNotEmpty) {
      _drawText(canvas, story.route, margin, 310, 30, mutedColor);
    }

    // Divider line
    canvas.drawLine(
      Offset(margin, 380),
      Offset(StoryDesign.canvasWidth - margin, 380),
      Paint()..color = const Color(0xFFE2E8F0)..strokeWidth = 2,
    );

    // Route map in center (if showRoute)
    if (story.showRoute && story.routePoints.isNotEmpty) {
      await _drawMinimalPolyline(canvas, story.routePoints);
    }

    // Stats row near bottom
    if (story.showStatistics) {
      _drawMinimalStats(canvas, story);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      StoryDesign.canvasWidth.toInt(),
      StoryDesign.canvasHeight.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _drawMinimalPolyline(Canvas canvas, List<RoutePoint> rawPoints) async {
    if (rawPoints.length < 2) return;
    final rawLatLngs = rawPoints.map((p) => LatLng(p.lat, p.lng)).toList();
    final smoothed = await RouteSmoother.processRoute(rawLatLngs);
    if (smoothed.length < 2) return;

    double minLat = smoothed.first.latitude, maxLat = smoothed.first.latitude;
    double minLng = smoothed.first.longitude, maxLng = smoothed.first.longitude;
    for (final p in smoothed) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final latRange = maxLat - minLat;
    final lngRange = maxLng - minLng;
    if (latRange == 0 && lngRange == 0) return;

    const padH = 100.0;
    const padTop = 420.0;
    const padBottom = 560.0;
    final drawW = StoryDesign.canvasWidth - padH * 2;
    final drawH = StoryDesign.canvasHeight - padTop - padBottom;
    final midLat = (minLat + maxLat) / 2;
    final cosLat = math.cos(midLat * math.pi / 180);
    final latRangeInLngUnits = latRange == 0 ? lngRange * 0.001 : latRange / cosLat;
    final lngRangeAdj = lngRange == 0 ? latRangeInLngUnits * 0.001 : lngRange;
    const fitPad = 0.08;
    final scaleX = drawW * (1 - fitPad * 2) / lngRangeAdj;
    final scaleY = drawH * (1 - fitPad * 2) / latRangeInLngUnits;
    final scale = math.min(scaleX, scaleY);
    final scaledW = lngRangeAdj * scale;
    final scaledH = latRangeInLngUnits * scale;
    final originX = padH + (drawW - scaledW) / 2;
    final originY = padTop + (drawH - scaledH) / 2;

    Offset project(LatLng p) {
      final x = originX + ((p.longitude - minLng) / lngRangeAdj) * scaledW;
      final latNorm = latRange == 0 ? 0.5 : ((p.latitude - minLat) / latRange);
      final y = originY + scaledH - latNorm * scaledH;
      return Offset(x, y);
    }

    final projected = smoothed.map(project).toList();
    final routePath = Path();
    routePath.moveTo(projected.first.dx, projected.first.dy);
    for (int i = 1; i < projected.length; i++) {
      routePath.lineTo(projected[i].dx, projected[i].dy);
    }

    // Light shadow
    canvas.drawPath(routePath, Paint()
      ..color = const Color(0x33000000)..style = PaintingStyle.stroke
      ..strokeWidth = 8..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    // Clean dark route line
    canvas.drawPath(routePath, Paint()
      ..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke
      ..strokeWidth = 5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    // Accent highlight
    canvas.drawPath(routePath, Paint()
      ..color = StoryDesign.accent..style = PaintingStyle.stroke
      ..strokeWidth = 2..strokeCap = StrokeCap.round);

    final start = projected.first;
    canvas.drawCircle(start, 16, Paint()..color = const Color(0xFF10B981));
    canvas.drawCircle(start, 6, Paint()..color = Colors.white);
    final end = projected.last;
    canvas.drawCircle(end, 16, Paint()..color = StoryDesign.accent);
    canvas.drawCircle(end, 6, Paint()..color = Colors.white);
  }

  void _drawMinimalStats(Canvas canvas, StoryModel story) {
    const inkColor = Color(0xFF0F172A);
    const mutedColor = Color(0xFF64748B);
    const margin = StoryDesign.margin;
    const y = StoryDesign.canvasHeight - 320.0;

    // Divider
    canvas.drawLine(Offset(margin, y),
      Offset(StoryDesign.canvasWidth - margin, y),
      Paint()..color = const Color(0xFFE2E8F0)..strokeWidth = 2);

    final distStr = story.distanceMeters != null ? _formatDistance(story.distanceMeters!) : '—';
    final durStr = story.durationSeconds != null ? _formatDuration(story.durationSeconds!) : '—';
    final speedStr = story.averageSpeedKmh != null
        ? '${story.averageSpeedKmh!.toStringAsFixed(1)} km/h' : '—';
    final stopsStr = '${story.places.length} stop';

    final colW = (StoryDesign.canvasWidth - margin * 2) / 4;
    _drawMinimalStat(canvas, 'JARAK', distStr, margin, y + 30, colW, inkColor, mutedColor);
    _drawMinimalStat(canvas, 'DURASI', durStr, margin + colW, y + 30, colW, inkColor, mutedColor);
    _drawMinimalStat(canvas, 'AVG', speedStr, margin + colW * 2, y + 30, colW, inkColor, mutedColor);
    _drawMinimalStat(canvas, 'SINGGAH', stopsStr, margin + colW * 3, y + 30, colW, inkColor, mutedColor);
  }

  void _drawMinimalStat(Canvas canvas, String label, String value,
      double x, double y, double colW, Color ink, Color muted) {
    _drawText(canvas, label, x + 8, y, 14, muted, letterSpacing: 1.5);
    _drawText(canvas, value, x + 8, y + 28, 32, ink, bold: true);
  }

  // ---------------------------------------------------------------------------
  // Cinematic Template: large photo hero, editorial typography
  // ---------------------------------------------------------------------------
  Future<Uint8List> _renderCinematic(StoryModel story) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, StoryDesign.canvasWidth, StoryDesign.canvasHeight),
    );

    // Use first photo or background as hero, else dark gradient
    String? heroPath = story.backgroundImagePath;
    if (heroPath == null && story.photos.isNotEmpty) {
      heroPath = story.photos.first.path;
    }

    if (heroPath != null && File(heroPath).existsSync()) {
      await _drawBackgroundImage(canvas, heroPath);
    } else {
      _drawModernGradientBackground(canvas);
    }

    // Strong vignette
    _drawVignette(canvas);

    // Top date strip
    _drawText(canvas, DateFormat('d MMM yyyy').format(story.date).toUpperCase(),
      StoryDesign.margin, 90, 22, StoryDesign.textMuted, letterSpacing: 3);

    // Big cinematic title
    _drawTextWrapped(canvas, story.title,
      StoryDesign.margin, StoryDesign.canvasHeight - 680, 80, StoryDesign.textWhite,
      bold: true, maxWidth: StoryDesign.canvasWidth - StoryDesign.margin * 2, maxLines: 2);

    // Route sub-text
    if (story.route.isNotEmpty) {
      _drawText(canvas, story.route,
        StoryDesign.margin, StoryDesign.canvasHeight - 570, 36, StoryDesign.textMuted);
    }

    // Stats strip at bottom
    if (story.showStatistics) {
      _drawCinematicStatsStrip(canvas, story);
    }

    // Polyline overlay (thin, elegant)
    if (story.showRoute && story.routePoints.isNotEmpty) {
      await _drawDetailedPolyline(canvas, story.routePoints);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      StoryDesign.canvasWidth.toInt(), StoryDesign.canvasHeight.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _drawVignette(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, StoryDesign.canvasWidth, StoryDesign.canvasHeight);
    canvas.drawRect(rect, Paint()..color = const Color(0x55000000));
    // Bottom heavy vignette
    final bottomRect = Rect.fromLTWH(0, StoryDesign.canvasHeight * 0.4,
        StoryDesign.canvasWidth, StoryDesign.canvasHeight * 0.6);
    canvas.drawRect(bottomRect, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.transparent, const Color(0xCC000000)],
      ).createShader(bottomRect));
  }

  void _drawCinematicStatsStrip(Canvas canvas, StoryModel story) {
    const y = StoryDesign.canvasHeight - 200.0;
    final distStr = story.distanceMeters != null ? _formatDistance(story.distanceMeters!) : '—';
    final durStr = story.durationSeconds != null ? _formatDuration(story.durationSeconds!) : '—';
    final line = '$distStr  ·  $durStr';
    _drawText(canvas, line, StoryDesign.margin, y, 38, StoryDesign.textWhite, bold: true);
  }

  // ---------------------------------------------------------------------------
  // Strava Template: route as hero, sporty stats
  // ---------------------------------------------------------------------------
  Future<Uint8List> _renderStrava(StoryModel story) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, StoryDesign.canvasWidth, StoryDesign.canvasHeight),
    );

    // Very dark bg
    canvas.drawRect(
      Rect.fromLTWH(0, 0, StoryDesign.canvasWidth, StoryDesign.canvasHeight),
      Paint()..color = const Color(0xFF080D14),
    );

    // Grid pattern (sporty data viz feel)
    final gridPaint = Paint()..color = const Color(0x0CFFFFFF);
    for (double x = 0; x < StoryDesign.canvasWidth; x += 80) {
      canvas.drawLine(Offset(x, 0), Offset(x, StoryDesign.canvasHeight), gridPaint);
    }
    for (double y = 0; y < StoryDesign.canvasHeight; y += 80) {
      canvas.drawLine(Offset(0, y), Offset(StoryDesign.canvasWidth, y), gridPaint);
    }

    // Orange accent vertical bar left
    canvas.drawRect(Rect.fromLTWH(0, 0, 12, StoryDesign.canvasHeight),
      Paint()..color = StoryDesign.accent);

    // Title
    _drawText(canvas, story.title.toUpperCase(),
      80, 100, 48, StoryDesign.textWhite, bold: true, letterSpacing: 1.0);

    // Date
    _drawText(canvas, DateFormat('d MMM yyyy').format(story.date),
      80, 165, 26, StoryDesign.textMuted);

    // Big polyline — main hero
    if (story.showRoute && story.routePoints.isNotEmpty) {
      await _drawDetailedPolyline(canvas, story.routePoints);
    }

    // Strava-style stats block bottom
    if (story.showStatistics) {
      _drawStravaStatsBlock(canvas, story);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      StoryDesign.canvasWidth.toInt(), StoryDesign.canvasHeight.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _drawStravaStatsBlock(Canvas canvas, StoryModel story) {
    const blockY = StoryDesign.canvasHeight - 480.0;
    const margin = StoryDesign.margin;

    // Orange separator line
    canvas.drawLine(
      Offset(margin, blockY), Offset(StoryDesign.canvasWidth - margin, blockY),
      Paint()..color = StoryDesign.accent..strokeWidth = 3);

    final distStr = story.distanceMeters != null ? _formatDistance(story.distanceMeters!) : '—';
    final durStr = story.durationSeconds != null ? _formatDuration(story.durationSeconds!) : '—';
    final speedStr = story.averageSpeedKmh != null
        ? story.averageSpeedKmh!.toStringAsFixed(1) : '—';
    final elevStr = story.elevationGainMeters != null && story.elevationGainMeters! > 0
        ? '+${story.elevationGainMeters!.toStringAsFixed(0)}m' : '—';

    // 2x2 grid
    final colW = (StoryDesign.canvasWidth - margin * 2) / 2;
    _drawStravaStatEntry(canvas, 'JARAK', distStr, margin, blockY + 40, colW);
    _drawStravaStatEntry(canvas, 'DURASI', durStr, margin + colW, blockY + 40, colW);
    _drawStravaStatEntry(canvas, 'AVG km/h', speedStr, margin, blockY + 200, colW);
    _drawStravaStatEntry(canvas, 'ELEVASI', elevStr, margin + colW, blockY + 200, colW);
  }

  void _drawStravaStatEntry(Canvas canvas, String label, String value,
      double x, double y, double colW) {
    _drawText(canvas, label, x + 10, y, 16, StoryDesign.textMuted, letterSpacing: 2);
    _drawText(canvas, value, x + 10, y + 30, 64, StoryDesign.textWhite, bold: true);
  }

  // ---------------------------------------------------------------------------
  // Journal Template: warm parchment, personal narrative feel
  // ---------------------------------------------------------------------------
  Future<Uint8List> _renderJournal(StoryModel story) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, StoryDesign.canvasWidth, StoryDesign.canvasHeight),
    );

    // Warm parchment background
    final rect = Rect.fromLTWH(0, 0, StoryDesign.canvasWidth, StoryDesign.canvasHeight);
    canvas.drawRect(rect, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [const Color(0xFFFAF7F2), const Color(0xFFF0EAE0)],
      ).createShader(rect));

    // Subtle texture lines
    final linePaint = Paint()..color = const Color(0x1A8B7355)..strokeWidth = 1;
    for (double y = 120.0; y < StoryDesign.canvasHeight; y += 80) {
      canvas.drawLine(Offset(60, y), Offset(StoryDesign.canvasWidth - 60, y), linePaint);
    }

    // Left red margin line (like a notebook)
    canvas.drawLine(const Offset(120, 0), const Offset(120, StoryDesign.canvasHeight),
      Paint()..color = const Color(0xAAE57373)..strokeWidth = 2);

    const inkColor = Color(0xFF2D1B0E);
    const warmMuted = Color(0xFF8B7355);

    // "TRAVEL DIARY" header label
    _drawText(canvas, 'TRAVEL DIARY', 150, 80, 20, warmMuted, letterSpacing: 4);

    // Date in cursive-like style
    _drawText(canvas, DateFormat('EEEE, d MMMM yyyy').format(story.date),
      150, 130, 30, warmMuted);

    // Big title
    _drawTextWrapped(canvas, story.title, 150, 210, 68, inkColor,
      bold: true, maxWidth: StoryDesign.canvasWidth - 200, maxLines: 2);

    // Route
    if (story.route.isNotEmpty) {
      _drawText(canvas, '✈ ${story.route}', 150, 400, 32, warmMuted);
    }

    // Mini route map in polaroid frame
    if (story.showRoute && story.routePoints.isNotEmpty) {
      await _drawJournalPolyline(canvas, story.routePoints);
    }

    // Stats as handwritten-style entries
    if (story.showStatistics) {
      _drawJournalStats(canvas, story);
    }

    // Photo polaroid if available
    if (story.showPhotos && story.photos.isNotEmpty) {
      await _drawJournalPhotos(canvas, story.photos.take(2).toList());
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      StoryDesign.canvasWidth.toInt(), StoryDesign.canvasHeight.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _drawJournalPolyline(Canvas canvas, List<RoutePoint> rawPoints) async {
    if (rawPoints.length < 2) return;
    final rawLatLngs = rawPoints.map((p) => LatLng(p.lat, p.lng)).toList();
    final smoothed = await RouteSmoother.processRoute(rawLatLngs);
    if (smoothed.length < 2) return;

    // Polaroid frame
    const frameX = 150.0;
    const frameY = 480.0;
    const frameW = StoryDesign.canvasWidth - 300.0;
    const frameH = 600.0;
    const frameR = 8.0;

    // White polaroid background
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(frameX - 20, frameY - 20, frameW + 40, frameH + 40),
      const Radius.circular(frameR)),
      Paint()..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(frameX - 20, frameY - 20, frameW + 40, frameH + 40),
      const Radius.circular(frameR)),
      Paint()..color = const Color(0xFFE8E0D5));

    // Inner map area
    double minLat = smoothed.first.latitude, maxLat = smoothed.first.latitude;
    double minLng = smoothed.first.longitude, maxLng = smoothed.first.longitude;
    for (final p in smoothed) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final latRange = maxLat - minLat;
    final lngRange = maxLng - minLng;
    if (latRange == 0 && lngRange == 0) return;

    final midLat = (minLat + maxLat) / 2;
    final cosLat = math.cos(midLat * math.pi / 180);
    final latRangeAdj = latRange == 0 ? lngRange * 0.001 : latRange / cosLat;
    final lngRangeAdj = lngRange == 0 ? latRangeAdj * 0.001 : lngRange;
    const fitPad = 0.08;
    final scaleX = frameW * (1 - fitPad * 2) / lngRangeAdj;
    final scaleY = frameH * (1 - fitPad * 2) / latRangeAdj;
    final scale = math.min(scaleX, scaleY);
    final scaledW = lngRangeAdj * scale;
    final scaledH = latRangeAdj * scale;
    final originX = frameX + (frameW - scaledW) / 2;
    final originY = frameY + (frameH - scaledH) / 2;

    Offset project(LatLng p) {
      final x = originX + ((p.longitude - minLng) / lngRangeAdj) * scaledW;
      final latNorm = latRange == 0 ? 0.5 : ((p.latitude - minLat) / latRange);
      final y = originY + scaledH - latNorm * scaledH;
      return Offset(x, y);
    }

    final projected = smoothed.map(project).toList();
    final routePath = Path();
    routePath.moveTo(projected.first.dx, projected.first.dy);
    for (int i = 1; i < projected.length; i++) {
      routePath.lineTo(projected[i].dx, projected[i].dy);
    }

    canvas.drawPath(routePath, Paint()
      ..color = const Color(0xFFE57373)..style = PaintingStyle.stroke
      ..strokeWidth = 5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);

    final start = projected.first;
    canvas.drawCircle(start, 14, Paint()..color = const Color(0xFF43A047));
    canvas.drawCircle(start, 5, Paint()..color = Colors.white);
    final end = projected.last;
    canvas.drawCircle(end, 14, Paint()..color = const Color(0xFFE53935));
    canvas.drawCircle(end, 5, Paint()..color = Colors.white);
  }

  void _drawJournalStats(Canvas canvas, StoryModel story) {
    const inkColor = Color(0xFF2D1B0E);
    const warmMuted = Color(0xFF8B7355);
    const y = 1150.0;

    final distStr = story.distanceMeters != null ? _formatDistance(story.distanceMeters!) : '—';
    final durStr = story.durationSeconds != null ? _formatDuration(story.durationSeconds!) : '—';

    _drawText(canvas, '📍 Jarak: $distStr', 150, y, 34, inkColor);
    _drawText(canvas, '⏱ Durasi: $durStr', 150, y + 60, 34, inkColor);
    if (story.places.isNotEmpty) {
      _drawText(canvas, '🏁 ${story.places.length} pemberhentian', 150, y + 120, 34, warmMuted);
    }
    if (story.averageSpeedKmh != null) {
      _drawText(canvas, '🚀 ${story.averageSpeedKmh!.toStringAsFixed(1)} km/h rata-rata',
        150, y + 180, 34, warmMuted);
    }
  }

  Future<void> _drawJournalPhotos(Canvas canvas, List<dynamic> photos) async {
    const startY = 1350.0;
    const photoSize = 320.0;
    const gap = 20.0;
    const frameX = 150.0;

    for (int i = 0; i < photos.length && i < 2; i++) {
      final photo = photos[i];
      final x = frameX + i * (photoSize + gap);

      try {
        final bytes = await File(photo.path).readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes,
          targetWidth: photoSize.toInt(), targetHeight: photoSize.toInt());
        final frame = await codec.getNextFrame();
        final img = frame.image;

        // White polaroid frame
        canvas.drawRect(Rect.fromLTWH(x - 16, startY - 16, photoSize + 32, photoSize + 80),
          Paint()..color = Colors.white
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
        canvas.drawRect(Rect.fromLTWH(x - 16, startY - 16, photoSize + 32, photoSize + 80),
          Paint()..color = const Color(0xFFF5F0E8));

        // Photo
        canvas.drawImageRect(img,
          Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
          Rect.fromLTWH(x, startY, photoSize, photoSize),
          Paint());
      } catch (_) {
        // Skip missing photos silently
      }
    }
  }


  // ---------------------------------------------------------------------------
  // Backgrounds
  // ---------------------------------------------------------------------------

  Future<void> _drawBackgroundImage(Canvas canvas, String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: StoryDesign.canvasWidth.toInt(),
      targetHeight: StoryDesign.canvasHeight.toInt(),
    );
    final frame = await codec.getNextFrame();
    final bgImage = frame.image;

    final srcW = bgImage.width.toDouble();
    final srcH = bgImage.height.toDouble();
    final dstW = StoryDesign.canvasWidth;
    final dstH = StoryDesign.canvasHeight;

    final scale = math.max(dstW / srcW, dstH / srcH);
    final scaledW = srcW * scale;
    final scaledH = srcH * scale;
    final srcRect = Rect.fromLTWH(
      (scaledW - dstW) / 2 / scale,
      (scaledH - dstH) / 2 / scale,
      dstW / scale,
      dstH / scale,
    );

    canvas.drawImageRect(
      bgImage,
      srcRect,
      Rect.fromLTWH(0, 0, dstW, dstH),
      Paint()..filterQuality = FilterQuality.high,
    );

    // Subtle dark glass tint for contrast on bright photos
    canvas.drawRect(
      Rect.fromLTWH(0, 0, dstW, dstH),
      Paint()..color = const Color(0x3D000000),
    );
  }

  void _drawModernGradientBackground(Canvas canvas) {
    final rect =
        Rect.fromLTWH(0, 0, StoryDesign.canvasWidth, StoryDesign.canvasHeight);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF070B14),
          Color(0xFF0F172A),
          Color(0xFF0A0F1D),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);

    // Ambient Cyan Glow Top Left
    final cyanGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: const [
          Color(0x3300F5D4),
          Color(0x0000F5D4),
        ],
      ).createShader(Rect.fromCircle(center: const Offset(150, 250), radius: 500));
    canvas.drawCircle(const Offset(150, 250), 500, cyanGlowPaint);

    // Ambient Orange Glow Center Right
    final orangeGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: const [
          Color(0x26FF5722),
          Color(0x00FF5722),
        ],
      ).createShader(Rect.fromCircle(center: const Offset(850, 850), radius: 600));
    canvas.drawCircle(const Offset(850, 850), 600, orangeGlowPaint);

    // Subtle Dot Grid Matrix Pattern
    final dotPaint = Paint()..color = const Color(0x12FFFFFF);
    const gridSpacing = 60.0;
    for (double x = 40; x < StoryDesign.canvasWidth; x += gridSpacing) {
      for (double y = 40; y < StoryDesign.canvasHeight; y += gridSpacing) {
        canvas.drawCircle(Offset(x, y), 2, dotPaint);
      }
    }
  }

  void _drawTopGradient(Canvas canvas) {
    const gradientHeight = 400.0;
    final rect = Rect.fromLTWH(0, 0, StoryDesign.canvasWidth, gradientHeight);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x99000000), Colors.transparent],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawBottomGradient(Canvas canvas) {
    const gradientHeight = 900.0;
    final rect = Rect.fromLTWH(
      0,
      StoryDesign.canvasHeight - gradientHeight,
      StoryDesign.canvasWidth,
      gradientHeight,
    );
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Color(0x99070B14), Color(0xDD070B14)],
        stops: [0.0, 0.4, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  // ---------------------------------------------------------------------------
  // Header Badge
  // ---------------------------------------------------------------------------

  void _drawHeaderBadge(Canvas canvas, StoryModel story) {
    const topY = 100.0;

    const pillW = 320.0;
    const pillH = 64.0;
    const pillX = StoryDesign.margin;

    final RRect pillRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pillX, topY, pillW, pillH),
      const Radius.circular(32),
    );

    canvas.drawRRect(
      pillRRect,
      Paint()..color = const Color(0x26FFFFFF),
    );
    canvas.drawRRect(
      pillRRect,
      Paint()
        ..color = const Color(0x4DFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    _drawText(
      canvas,
      'TRAVEL STORY',
      pillX + 24,
      topY + 18,
      22,
      StoryDesign.textWhite,
      bold: true,
      letterSpacing: 2.0,
    );

    final dateStr = DateFormat('dd MMMM yyyy').format(story.date);
    _drawText(
      canvas,
      dateStr,
      StoryDesign.canvasWidth - StoryDesign.margin,
      topY + 18,
      26,
      StoryDesign.textMuted,
      align: TextAlign.right,
    );
  }

  // ---------------------------------------------------------------------------
  // Strava High-Contrast Polyline Route (Hero Central Focal Point Above Card)
  // ---------------------------------------------------------------------------

  Future<void> _drawDetailedPolyline(Canvas canvas, List<RoutePoint> rawPoints) async {
    if (rawPoints.length < 2) return;

    final rawLatLngs = rawPoints.map((p) => LatLng(p.lat, p.lng)).toList();
    final smoothedLatLngs = await RouteSmoother.processRoute(rawLatLngs);
    if (smoothedLatLngs.length < 2) return;

    double minLat = smoothedLatLngs.first.latitude;
    double maxLat = smoothedLatLngs.first.latitude;
    double minLng = smoothedLatLngs.first.longitude;
    double maxLng = smoothedLatLngs.first.longitude;

    for (final p in smoothedLatLngs) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final latRange = maxLat - minLat;
    final lngRange = maxLng - minLng;
    if (latRange == 0 && lngRange == 0) return;

    // Draw bounds positioned in UPPER/CENTER canvas area above Travel Log card
    const padH = 80.0;
    const padTop = 200.0;
    const padBottom = 580.0; // Clears space above Travel Log card (which starts at y = 1376)
    final drawW = StoryDesign.canvasWidth - padH * 2;
    final drawH = StoryDesign.canvasHeight - padTop - padBottom;

    final midLat = (minLat + maxLat) / 2;
    final cosLat = math.cos(midLat * math.pi / 180);

    final latRangeInLngUnits = latRange == 0 ? lngRange * 0.001 : latRange / cosLat;
    final lngRangeAdj = lngRange == 0 ? latRangeInLngUnits * 0.001 : lngRange;

    const fitPad = 0.06;
    final scaleX = drawW * (1 - fitPad * 2) / lngRangeAdj;
    final scaleY = drawH * (1 - fitPad * 2) / latRangeInLngUnits;
    final scale = math.min(scaleX, scaleY);

    final scaledRouteW = lngRangeAdj * scale;
    final scaledRouteH = latRangeInLngUnits * scale;

    final originX = padH + (drawW - scaledRouteW) / 2;
    final originY = padTop + (drawH - scaledRouteH) / 2;

    Offset project(LatLng p) {
      final x = originX + ((p.longitude - minLng) / lngRangeAdj) * scaledRouteW;
      final latNorm = latRange == 0 ? 0.5 : ((p.latitude - minLat) / latRange);
      final y = originY + scaledRouteH - latNorm * scaledRouteH;
      return Offset(x, y);
    }

    final projected = smoothedLatLngs.map(project).toList();

    // Direct line segments following exact road geometry
    final routePath = Path();
    routePath.moveTo(projected.first.dx, projected.first.dy);
    for (int i = 1; i < projected.length; i++) {
      routePath.lineTo(projected[i].dx, projected[i].dy);
    }

    // Layer 1: Soft Ambient Drop Shadow under polyline for legibility over bright/dark photos
    final shadowPaint = Paint()
      ..color = const Color(0x66000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, shadowPaint);

    // Layer 2: Clean Strava Signature Orange Polyline (#FC4C02)
    final linePaint = Paint()
      ..color = const Color(0xFFFC4C02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, linePaint);

    // Layer 3: Inner Bright Core Highlight Line
    final innerHighlightPaint = Paint()
      ..color = const Color(0xFFFF8855)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, innerHighlightPaint);

    // Layer 4: Start Pin (Emerald Green)
    final startPt = projected.first;
    canvas.drawCircle(startPt, 24, Paint()..color = const Color(0x4410B981));
    canvas.drawCircle(startPt, 14, Paint()..color = const Color(0xFF10B981));
    canvas.drawCircle(startPt, 5, Paint()..color = Colors.white);

    // Layer 5: Finish Pin (Strava Orange)
    final endPt = projected.last;
    canvas.drawCircle(endPt, 24, Paint()..color = const Color(0x44FC4C02));
    canvas.drawCircle(endPt, 14, Paint()..color = const Color(0xFFFC4C02));
    canvas.drawCircle(endPt, 5, Paint()..color = Colors.white);
  }

  // ---------------------------------------------------------------------------
  // Glassmorphism Bottom Card (Positioned in Lower Section Below Polyline)
  // ---------------------------------------------------------------------------

  void _drawBottomCard(Canvas canvas, StoryModel story) {
    const cardH = 480.0;
    final cardW = StoryDesign.canvasWidth - StoryDesign.margin * 2;
    final cardX = StoryDesign.margin;
    final cardY = StoryDesign.canvasHeight - cardH - 64; // Y = 1376
    final cardRect = Rect.fromLTWH(cardX, cardY, cardW, cardH);

    final RRect outerRRect = RRect.fromRectAndRadius(
      cardRect,
      const Radius.circular(32),
    );

    // Layer 0: Subtle ambient shadow
    final shadowRRect = RRect.fromRectAndRadius(
      cardRect.translate(0, 8),
      const Radius.circular(32),
    );
    canvas.drawRRect(
      shadowRRect,
      Paint()
        ..color = const Color(0x35000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );

    // Layer 1: Clear Glassmorphism Frosted Fill (~25% Opacity)
    canvas.drawRRect(
      outerRRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0x3B1E293B),
            Color(0x200F172A),
            Color(0x300F172A),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(cardRect),
    );

    // Layer 2: Subtle top-edge light reflection
    final innerGlowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cardX + 1, cardY + 1, cardW - 2, cardH * 0.3),
      const Radius.circular(32),
    );
    canvas.drawRRect(
      innerGlowRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0x30FFFFFF),
            Color(0x00FFFFFF),
          ],
        ).createShader(innerGlowRect.outerRect),
    );

    // Layer 3: Thin crisp glass white border
    canvas.drawRRect(
      outerRRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0x66FFFFFF),
            Color(0x22FFFFFF),
            Color(0x44FFFFFF),
            Color(0x11FFFFFF),
          ],
          stops: const [0.0, 0.35, 0.75, 1.0],
        ).createShader(cardRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    double contentY = cardY + 32;
    final innerX = cardX + 36;
    final contentW = cardW - 72;

    // ── Tag Pill: "TRAVEL LOG" + Date ──
    const pillW = 160.0;
    const pillH = 36.0;
    final pillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(innerX, contentY, pillW, pillH),
      const Radius.circular(18),
    );
    canvas.drawRRect(
      pillRect,
      Paint()..color = const Color(0x1A00F5D4),
    );
    canvas.drawRRect(
      pillRect,
      Paint()
        ..color = const Color(0x4D00F5D4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    _drawText(
      canvas,
      'TRAVEL LOG',
      innerX + pillW / 2,
      contentY + 8,
      14,
      const Color(0xFF00F5D4),
      bold: true,
      letterSpacing: 2.0,
      align: TextAlign.center,
    );

    final dateStr = DateFormat('dd MMM yyyy').format(story.date).toUpperCase();
    _drawText(
      canvas,
      dateStr,
      innerX + contentW,
      contentY + 8,
      16,
      const Color(0xFF94A3B8),
      letterSpacing: 1.5,
      align: TextAlign.right,
    );

    contentY += 48;

    // ── Main Title ──
    final titleText = story.title.isNotEmpty
        ? story.title
        : (story.route.isNotEmpty ? story.route : 'Petualangan Baru');
    _drawText(
      canvas,
      titleText,
      innerX,
      contentY,
      36,
      StoryDesign.textWhite,
      bold: true,
    );
    contentY += 50;

    // ── Separator ──
    final separatorPaint = Paint()
      ..shader = LinearGradient(
        colors: const [
          Color(0x00FFFFFF),
          Color(0x33FFFFFF),
          Color(0x1A00F5D4),
          Color(0x00FFFFFF),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(innerX, contentY, contentW, 1))
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(innerX, contentY),
      Offset(innerX + contentW, contentY),
      separatorPaint,
    );
    contentY += 24;

    // ── Stats: 2x2 Glass Sub-Cards ──
    final subCardW = (contentW - 16) / 2;
    const subCardH = 100.0;

    final distanceStr = story.distanceMeters != null
        ? _formatDistance(story.distanceMeters!)
        : '0 km';
    final durationStr = story.durationSeconds != null
        ? _formatDuration(story.durationSeconds!)
        : '0m';
    final elevationStr =
        story.elevationGainMeters != null && story.elevationGainMeters! > 0
            ? '+${story.elevationGainMeters!.toStringAsFixed(0)} m'
            : '0 m';
    final stopsStr = story.places.isNotEmpty
        ? '${story.places.length} lokasi'
        : '0 lokasi';

    // Row 1
    _drawGlassStatCard(canvas,
      x: innerX, y: contentY, w: subCardW, h: subCardH,
      label: 'JARAK', value: distanceStr,
      valueColor: const Color(0xFFFC4C02), valueSize: 34,
    );
    _drawGlassStatCard(canvas,
      x: innerX + subCardW + 16, y: contentY, w: subCardW, h: subCardH,
      label: 'DURASI', value: durationStr,
      valueColor: StoryDesign.textWhite, valueSize: 34,
    );

    contentY += subCardH + 12;

    // Row 2
    _drawGlassStatCard(canvas,
      x: innerX, y: contentY, w: subCardW, h: subCardH,
      label: 'ELEVASI', value: elevationStr,
      valueColor: const Color(0xFF00F5D4), valueSize: 30,
    );
    _drawGlassStatCard(canvas,
      x: innerX + subCardW + 16, y: contentY, w: subCardW, h: subCardH,
      label: 'SINGGAH', value: stopsStr,
      valueColor: StoryDesign.textWhite, valueSize: 30,
    );
  }

  void _drawGlassStatCard(
    Canvas canvas, {
    required double x,
    required double y,
    required double w,
    required double h,
    required String label,
    required String value,
    required Color valueColor,
    required double valueSize,
  }) {
    final rect = Rect.fromLTWH(x, y, w, h);
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(20));

    // Glass fill
    canvas.drawRRect(
      rRect,
      Paint()..color = const Color(0x1A1E293B),
    );
    // Glass border
    canvas.drawRRect(
      rRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0x33FFFFFF),
            Color(0x0DFFFFFF),
          ],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Label
    _drawText(
      canvas,
      label,
      x + 20,
      y + 16,
      13,
      const Color(0xFF94A3B8),
      bold: true,
      letterSpacing: 2.0,
    );
    // Value
    _drawText(
      canvas,
      value,
      x + 20,
      y + 44,
      valueSize,
      valueColor,
      bold: true,
    );
  }

  // ---------------------------------------------------------------------------
  // Formatters
  // ---------------------------------------------------------------------------

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}j ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  // ---------------------------------------------------------------------------
  // Text Helper
  // ---------------------------------------------------------------------------

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color color, {
    bool bold = false,
    double letterSpacing = 0,
    TextAlign align = TextAlign.left,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          letterSpacing: letterSpacing,
        ),
      ),
      textAlign: align,
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: StoryDesign.canvasWidth - StoryDesign.margin * 2);

    final offset = _alignOffset(x, y, tp, align);
    tp.paint(canvas, offset);
  }

  Offset _alignOffset(double x, double y, TextPainter tp, TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return Offset(x - tp.width / 2, y);
      case TextAlign.right:
        return Offset(x - tp.width, y);
      default:
        return Offset(x, y);
    }
  }

  /// Draws multi-line text with a max line count. Returns the total height rendered.
  double _drawTextWrapped(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color color, {
    bool bold = false,
    double letterSpacing = 0,
    double maxWidth = 952,
    int maxLines = 3,
  }) {
    final style = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.w600,
      letterSpacing: letterSpacing,
    );

    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: TextAlign.left,
      textDirection: ui.TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);

    tp.paint(canvas, Offset(x, y));
    return tp.height;
  }
}
