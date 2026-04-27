// Generates app icon PNGs using only dart:io and dart:typed_data.
// No external packages required.
//
// Produces:
//   assets/icons/app_icon.png            - 1024x1024 sage green (#6B9080) square
//   assets/icons/app_icon_foreground.png  - 1024x1024 white calendar on transparent

import 'dart:io';
import 'dart:typed_data';

// ──────────────────────────────────────────────────────────────────────
// CRC-32 (used by PNG chunks)
// ──────────────────────────────────────────────────────────────────────

final List<int> _crcTable = _makeCrcTable();

List<int> _makeCrcTable() {
  final table = List<int>.filled(256, 0);
  for (var n = 0; n < 256; n++) {
    var c = n;
    for (var k = 0; k < 8; k++) {
      if ((c & 1) != 0) {
        c = 0xEDB88320 ^ (c >> 1);
      } else {
        c = c >> 1;
      }
    }
    table[n] = c;
  }
  return table;
}

int _crc32(List<int> bytes) {
  var crc = 0xFFFFFFFF;
  for (final b in bytes) {
    crc = _crcTable[(crc ^ b) & 0xFF] ^ (crc >> 8);
  }
  return crc ^ 0xFFFFFFFF;
}

// ──────────────────────────────────────────────────────────────────────
// PNG helpers
// ──────────────────────────────────────────────────────────────────────

Uint8List _uint32BE(int v) =>
    Uint8List.fromList([(v >> 24) & 0xFF, (v >> 16) & 0xFF, (v >> 8) & 0xFF, v & 0xFF]);

Uint8List _makeChunk(String type, List<int> data) {
  final typeBytes = type.codeUnits;
  final crcInput = [...typeBytes, ...data];
  final crc = _crc32(crcInput);
  return Uint8List.fromList([
    ..._uint32BE(data.length),
    ...typeBytes,
    ...data,
    ..._uint32BE(crc),
  ]);
}

/// Build a minimal valid PNG from raw RGBA pixel rows.
/// [rows] is height-length list; each element is width*4 bytes (RGBA).
Uint8List buildPng(int width, int height, List<Uint8List> rows) {
  // PNG signature
  final sig = <int>[137, 80, 78, 71, 13, 10, 26, 10];

  // IHDR
  final ihdr = BytesBuilder();
  ihdr.add(_uint32BE(width));
  ihdr.add(_uint32BE(height));
  ihdr.add([8]); // bit depth
  ihdr.add([6]); // color type RGBA
  ihdr.add([0]); // compression
  ihdr.add([0]); // filter
  ihdr.add([0]); // interlace
  final ihdrChunk = _makeChunk('IHDR', ihdr.toBytes());

  // IDAT – we build uncompressed raw data then zlib-compress via ZLibCodec
  // Each row is prefixed with filter byte 0 (None).
  final rawBuilder = BytesBuilder();
  for (var y = 0; y < height; y++) {
    rawBuilder.addByte(0); // filter None
    rawBuilder.add(rows[y]);
  }
  final raw = rawBuilder.toBytes();
  final compressed = ZLibCodec(level: 6).encode(raw);
  final idatChunk = _makeChunk('IDAT', compressed);

  // IEND
  final iendChunk = _makeChunk('IEND', []);

  final png = BytesBuilder();
  png.add(sig);
  png.add(ihdrChunk);
  png.add(idatChunk);
  png.add(iendChunk);
  return png.toBytes();
}

// ──────────────────────────────────────────────────────────────────────
// Drawing helpers
// ──────────────────────────────────────────────────────────────────────

/// Create a solid-color 1024x1024 image.
Uint8List solidImage(int r, int g, int b, int a, int size) {
  final row = Uint8List(size * 4);
  for (var x = 0; x < size; x++) {
    final o = x * 4;
    row[o] = r;
    row[o + 1] = g;
    row[o + 2] = b;
    row[o + 3] = a;
  }
  final rows = List<Uint8List>.generate(size, (_) => Uint8List.fromList(row));
  return buildPng(size, size, rows);
}

/// Alpha-blend foreground over a pixel.
void _blendPixel(Uint8List row, int x, int r, int g, int b, int a) {
  final o = x * 4;
  if (a == 255) {
    row[o] = r;
    row[o + 1] = g;
    row[o + 2] = b;
    row[o + 3] = 255;
    return;
  }
  if (a == 0) return;
  final fa = a / 255.0;
  final ba = row[o + 3] / 255.0;
  final oa = fa + ba * (1 - fa);
  if (oa == 0) return;
  row[o] = ((r * fa + row[o] * ba * (1 - fa)) / oa).round();
  row[o + 1] = ((g * fa + row[o + 1] * ba * (1 - fa)) / oa).round();
  row[o + 2] = ((b * fa + row[o + 2] * ba * (1 - fa)) / oa).round();
  row[o + 3] = (oa * 255).round();
}

/// Fill an axis-aligned rectangle.
void fillRect(List<Uint8List> rows, int size, int x1, int y1, int x2, int y2,
    int r, int g, int b, int a) {
  for (var y = y1.clamp(0, size); y < y2.clamp(0, size); y++) {
    for (var x = x1.clamp(0, size); x < x2.clamp(0, size); x++) {
      _blendPixel(rows[y], x, r, g, b, a);
    }
  }
}

/// Fill a rounded rectangle (with circular quarter-corner clipping).
void fillRoundedRect(List<Uint8List> rows, int size, int x1, int y1, int x2,
    int y2, int radius, int r, int g, int b, int a) {
  for (var y = y1.clamp(0, size); y < y2.clamp(0, size); y++) {
    for (var x = x1.clamp(0, size); x < x2.clamp(0, size); x++) {
      // Check corners
      bool inside = true;
      // Top-left
      if (x < x1 + radius && y < y1 + radius) {
        final dx = x - (x1 + radius);
        final dy = y - (y1 + radius);
        if (dx * dx + dy * dy > radius * radius) inside = false;
      }
      // Top-right
      if (x >= x2 - radius && y < y1 + radius) {
        final dx = x - (x2 - radius - 1);
        final dy = y - (y1 + radius);
        if (dx * dx + dy * dy > radius * radius) inside = false;
      }
      // Bottom-left
      if (x < x1 + radius && y >= y2 - radius) {
        final dx = x - (x1 + radius);
        final dy = y - (y2 - radius - 1);
        if (dx * dx + dy * dy > radius * radius) inside = false;
      }
      // Bottom-right
      if (x >= x2 - radius && y >= y2 - radius) {
        final dx = x - (x2 - radius - 1);
        final dy = y - (y2 - radius - 1);
        if (dx * dx + dy * dy > radius * radius) inside = false;
      }
      if (inside) {
        _blendPixel(rows[y], x, r, g, b, a);
      }
    }
  }
}

// ──────────────────────────────────────────────────────────────────────
// Icon generation
// ──────────────────────────────────────────────────────────────────────

Uint8List generateAppIcon(int size) {
  // Sage green rounded square
  final row = Uint8List(size * 4); // all transparent
  final rows = List<Uint8List>.generate(size, (_) => Uint8List.fromList(row));

  // Background: sage green rounded rect filling the whole canvas
  final radius = (size * 0.18).round(); // ~18% corner radius (iOS-style)
  fillRoundedRect(rows, size, 0, 0, size, size, radius, 0x6B, 0x90, 0x80, 255);

  // Draw a small white calendar icon in the center for visual interest
  _drawCalendarIcon(rows, size, 255, 255, 255, 230);

  return buildPng(size, size, rows);
}

Uint8List generateForegroundIcon(int size) {
  // Transparent background with white calendar icon
  final row = Uint8List(size * 4); // all transparent
  final rows = List<Uint8List>.generate(size, (_) => Uint8List.fromList(row));

  _drawCalendarIcon(rows, size, 255, 255, 255, 255);

  return buildPng(size, size, rows);
}

void _drawCalendarIcon(List<Uint8List> rows, int size, int r, int g, int b, int a) {
  // Calendar body -- centered, about 50% of canvas
  final margin = (size * 0.25).round();
  final cx1 = margin;
  final cy1 = margin + (size * 0.06).round(); // offset down for tabs
  final cx2 = size - margin;
  final cy2 = size - margin;
  final cRadius = (size * 0.04).round();

  // Calendar body (rounded rect)
  fillRoundedRect(rows, size, cx1, cy1, cx2, cy2, cRadius, r, g, b, a);

  // Two small "tabs" at the top (the calendar binding rings)
  final tabW = (size * 0.05).round();
  final tabH = (size * 0.10).round();
  final tabY1 = margin - (size * 0.01).round();
  final tabY2 = tabY1 + tabH;
  final tabRadius = (tabW * 0.4).round();

  // Left tab
  final ltX = cx1 + ((cx2 - cx1) * 0.25).round() - tabW ~/ 2;
  fillRoundedRect(rows, size, ltX, tabY1, ltX + tabW, tabY2, tabRadius, r, g, b, a);

  // Right tab
  final rtX = cx1 + ((cx2 - cx1) * 0.75).round() - tabW ~/ 2;
  fillRoundedRect(rows, size, rtX, tabY1, rtX + tabW, tabY2, tabRadius, r, g, b, a);

  // Header bar (the colored strip at top of calendar) -- slightly darker / semi-transparent
  final headerY1 = cy1;
  final headerY2 = cy1 + ((cy2 - cy1) * 0.18).round();
  // Draw with reduced alpha to create a subtle band
  fillRect(rows, size, cx1, headerY1, cx2, headerY2, r, g, b, (a * 0.3).round());

  // Horizontal lines (planner lines) inside the calendar body
  final contentY1 = headerY2 + (size * 0.04).round();
  final contentY2 = cy2 - (size * 0.04).round();
  final lineH = (size * 0.012).round().clamp(1, 100);
  final numLines = 4;
  final lineSpacing = ((contentY2 - contentY1) / (numLines + 1)).round();
  final lineMargin = (size * 0.06).round();

  for (var i = 1; i <= numLines; i++) {
    final ly = contentY1 + lineSpacing * i;
    fillRect(rows, size, cx1 + lineMargin, ly, cx2 - lineMargin, ly + lineH,
        r, g, b, (a * 0.35).round());
  }

  // Small checkmark-like marks on the left side of lines (to suggest a planner/todo)
  final checkSize = (size * 0.025).round();
  for (var i = 1; i <= numLines; i++) {
    final ly = contentY1 + lineSpacing * i;
    final checkX = cx1 + lineMargin - (size * 0.04).round();
    final checkY = ly - checkSize ~/ 2;
    // Small filled square as a bullet/checkbox
    fillRect(rows, size, checkX, checkY, checkX + checkSize, checkY + checkSize,
        r, g, b, (a * 0.5).round());
  }
}

// ──────────────────────────────────────────────────────────────────────
// Main
// ──────────────────────────────────────────────────────────────────────

void main() {
  const size = 1024;

  // Resolve paths relative to project root
  final scriptFile = File(Platform.script.toFilePath());
  final projectRoot = scriptFile.parent.parent;
  final iconsDir = Directory('${projectRoot.path}/assets/icons');
  if (!iconsDir.existsSync()) {
    iconsDir.createSync(recursive: true);
  }

  // 1. App icon: sage green rounded square with white calendar
  print('Generating app_icon.png ($size x $size) ...');
  final appIcon = generateAppIcon(size);
  File('${iconsDir.path}/app_icon.png').writeAsBytesSync(appIcon);
  print('  -> ${iconsDir.path}/app_icon.png  (${appIcon.length} bytes)');

  // 2. Foreground icon: white calendar on transparent background
  print('Generating app_icon_foreground.png ($size x $size) ...');
  final fgIcon = generateForegroundIcon(size);
  File('${iconsDir.path}/app_icon_foreground.png').writeAsBytesSync(fgIcon);
  print('  -> ${iconsDir.path}/app_icon_foreground.png  (${fgIcon.length} bytes)');

  print('Done!');
}
