/// ═══════════════════════════════════════════════════════════════
/// Export Service - AZAMOV Academy
/// Taraqqiyot ma'lumotlarini eksport qilish
/// ═══════════════════════════════════════════════════════════════

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  /// Take a screenshot of a widget and share it
  static Future<void> shareWidgetAsImage(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Widget topilmadi');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) throw Exception('Rasm yaratilmadi');

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/azamov_progress.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'AZAMOV Academy - Mening taraqqiyotim! 🚀',
      );
    } catch (e) {
      throw Exception('Eksport qilishda xatolik: $e');
    }
  }

  /// Share text report
  static Future<void> shareText(String text) async {
    await Share.share(text, subject: 'AZAMOV Academy Hisobot');
  }

  /// Format progress as text
  static String formatProgressReport({
    required String name,
    required int level,
    required int xp,
    required int streak,
    required int missionsDone,
    required int habitsDone,
    required int focusMinutes,
  }) {
    return '''
📊 AZAMOV Academy - Taraqqiyot Hisoboti
═══════════════════════════
👤 Foydalanuvchi: $name
⭐ Level: $level
🔥 XP: $xp
📅 Streak: $streak kun
🎯 Bajarilgan vazifalar: $missionsDone
✅ Bajarilgan odatlar: $habitsDone
⏱️ Fokus vaqti: $focusMinutes daqiqa
═══════════════════════════
🚀 AZAMOV Academy orqali o'zingizni rivojlantiring!
''';
  }
}
