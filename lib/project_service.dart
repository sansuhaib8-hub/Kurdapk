import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

class ProjectFile {
  final String name;
  final String path;
  final bool isDirectory;
  final List<ProjectFile> children;
  ProjectFile({required this.name, required this.path, required this.isDirectory, List<ProjectFile>? children})
      : children = children ?? [];
}

class ProjectService {
  static Future<Directory> get _projectsRoot async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/projects');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// دەگەڕێتەوە: مانای سەرکەوتن یان هەڵە بە دەق
  static Future<String> importFromGitHub(String repoUrl, {String branch = 'main'}) async {
    try {
      final cleaned = repoUrl.trim().replaceAll(RegExp(r'\.git$'), '').replaceAll(RegExp(r'/$'), '');
      final match = RegExp(r'github\.com/([^/]+)/([^/]+)').firstMatch(cleaned);
      if (match == null) return 'هەڵە: لینکی GitHub دروست نییە';

      final owner = match.group(1)!;
      final repo = match.group(2)!;
      final zipUrl = 'https://codeload.github.com/$owner/$repo/zip/refs/heads/$branch';

      final response = await http.get(Uri.parse(zipUrl));
      if (response.statusCode != 200) {
        final altBranch = branch == 'main' ? 'master' : 'main';
        final altUrl = 'https://codeload.github.com/$owner/$repo/zip/refs/heads/$altBranch';
        final altResponse = await http.get(Uri.parse(altUrl));
        if (altResponse.statusCode != 200) {
          return 'هەڵە: نەتوانرا داگیرێت (کۆد ${response.statusCode})';
        }
        return await _extractZip(altResponse.bodyBytes, repo);
      }
      return await _extractZip(response.bodyBytes, repo);
    } catch (e) {
      return 'هەڵە: $e';
    }
  }

  static Future<String> _extractZip(List<int> bytes, String repoName) async {
    final archive = ZipDecoder().decodeBytes(bytes);
    final root = await _projectsRoot;
    final targetDir = Directory('${root.path}/$repoName');
    if (await targetDir.exists()) {
      await targetDir.delete(recursive: true);
    }
    await targetDir.create(recursive: true);

    String? topFolder;
    for (final file in archive) {
      final parts = file.name.split('/');
      if (topFolder == null && parts.isNotEmpty) topFolder = parts.first;
      final relativePath = parts.skip(1).join('/');
      if (relativePath.isEmpty) continue;

      final outPath = '${targetDir.path}/$relativePath';
      if (file.isFile) {
        final outFile = File(outPath);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
      } else {
        await Directory(outPath).create(recursive: true);
      }
    }
    return 'سەرکەوتوو';
  }

  static Future<List<String>> listProjects() async {
    final root = await _projectsRoot;
    if (!await root.exists()) return [];
    return root
        .listSync()
        .whereType<Directory>()
        .map((d) => d.path.split('/').last)
        .toList();
  }

  static Future<ProjectFile> buildTree(String projectName) async {
    final root = await _projectsRoot;
    final projectDir = Directory('${root.path}/$projectName');
    return _buildNode(projectDir, projectName);
  }

  static ProjectFile _buildNode(Directory dir, String name) {
    final children = <ProjectFile>[];
    if (dir.existsSync()) {
      final entries = dir.listSync()..sort((a, b) {
        final aIsDir = a is Directory;
        final bIsDir = b is Directory;
        if (aIsDir != bIsDir) return aIsDir ? -1 : 1;
        return a.path.compareTo(b.path);
      });
      for (final entity in entries) {
        final entName = entity.path.split('/').last;
        if (entName.startsWith('.git')) continue;
        if (entity is Directory) {
          children.add(_buildNode(entity, entName));
        } else if (entity is File) {
          children.add(ProjectFile(name: entName, path: entity.path, isDirectory: false));
        }
      }
    }
    return ProjectFile(name: name, path: dir.path, isDirectory: true, children: children);
  }
}
