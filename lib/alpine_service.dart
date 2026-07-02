import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

class AlpineService {
  static const platform = MethodChannel('kurdapk/shell');
  static const String _alpineUrl =
      'https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/aarch64/alpine-minirootfs-3.19.1-aarch64.tar.gz';

  static Future<String> get _baseDir async {
    final dir = await getApplicationSupportDirectory();
    return dir.path;
  }

  static Future<String> get _alpineRootPath async => '${await _baseDir}/alpine';
  static Future<String> get _tmpPath async => '${await _baseDir}/proot_tmp';

  static Future<bool> isInstalled() async {
    final root = Directory(await _alpineRootPath);
    final marker = File('${root.path}/etc/os-release');
    return marker.existsSync();
  }

  static Future<String> _prootPath() async {
    final dir = await platform.invokeMethod('getNativeLibraryDir');
    return '$dir/libproot.so';
  }

  /// دابەزاندن و دامەزراندنی Alpine. onProgress: (0.0 - 1.0)
  static Future<String> install({void Function(String status)? onProgress}) async {
    try {
      onProgress?.call('داگرتنی Alpine rootfs...');
      final response = await http.get(Uri.parse(_alpineUrl));
      if (response.statusCode != 200) {
        return 'هەڵە: نەتوانرا داگیرێت (کۆد ${response.statusCode})';
      }

      onProgress?.call('دەرهێنانی فایلەکان...');
      final rootPath = await _alpineRootPath;
      final rootDir = Directory(rootPath);
      if (await rootDir.exists()) await rootDir.delete(recursive: true);
      await rootDir.create(recursive: true);

      final gzBytes = GZipDecoder().decodeBytes(response.bodyBytes);
      final archive = TarDecoder().decodeBytes(gzBytes);

      int count = 0;
      for (final file in archive) {
        final outPath = '$rootPath/${file.name}';
        if (file.isFile) {
          final outFile = File(outPath);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
          if (file.mode != 0) {
            try {
              await Process.run('chmod', [file.mode.toRadixString(8), outPath]);
            } catch (_) {}
          }
        } else {
          await Directory(outPath).create(recursive: true);
        }
        count++;
        if (count % 200 == 0) onProgress?.call('دەرهێنان... ($count فایل)');
      }

      // resolv.conf بۆ DNS
      final resolvFile = File('$rootPath/etc/resolv.conf');
      await resolvFile.writeAsString('nameserver 8.8.8.8\n');

      final tmpDir = Directory(await _tmpPath);
      if (!await tmpDir.exists()) await tmpDir.create(recursive: true);

      // executable کردنی proot
      final prootPath = await _prootPath();
      try {
        await Process.run('chmod', ['755', prootPath]);
      } catch (_) {}

      onProgress?.call('تەواو بوو');
      return 'سەرکەوتوو';
    } catch (e) {
      return 'هەڵە: $e';
    }
  }

  /// ڕاکردنی کۆمەند لەناو Alpine بە proot
  static Future<String> runCommand(String cmd) async {
    try {
      final prootPath = await _prootPath();
      final rootPath = await _alpineRootPath;
      final tmpPath = await _tmpPath;

      const pathSetup =
          'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;';

      final result = await Process.run(
        prootPath,
        [
          '-r', rootPath,
          '-b', '/dev',
          '-b', '/proc',
          '--kill-on-exit',
          '/bin/sh', '-c', '$pathSetup $cmd',
        ],
        environment: {'PROOT_TMP_DIR': tmpPath, 'PROOT_NO_SECCOMP': '1'},
      );
      final out = (result.stdout?.toString() ?? '') + (result.stderr?.toString() ?? '');
      return out.isEmpty ? '(هیچ دەرچوویەک نەبوو)' : out;
    } catch (e) {
      return 'هەڵە: $e';
    }
  }
}
