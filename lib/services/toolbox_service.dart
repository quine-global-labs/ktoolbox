import 'dart:convert';
import 'dart:io';

import '../models/toolbox_container.dart';

class ToolboxCommandException implements Exception {
  final String message;
  ToolboxCommandException(this.message);

  @override
  String toString() => message;
}

/// Terminal emulators tried, in order, to run `toolbox enter` interactively.
const _terminalCandidates = <List<String>>[
  ['ptyxis', '--'],
  ['konsole', '-e'],
  ['gnome-terminal', '--'],
  ['xterm', '-e'],
];

class ToolboxService {
  const ToolboxService();

  Future<List<ToolboxContainer>> listContainers() async {
    final result = await Process.run('podman', [
      'ps',
      '-a',
      '--filter',
      'label=com.github.containers.toolbox=true',
      '--format',
      'json',
    ]);

    if (result.exitCode != 0) {
      throw ToolboxCommandException(result.stderr.toString().trim());
    }

    final raw = result.stdout.toString().trim();
    if (raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map(ToolboxContainer.fromPodmanJson)
        .toList();
  }

  Future<void> createContainer({required String name, String? image}) async {
    final args = ['create', '--yes'];
    if (image != null && image.trim().isNotEmpty) {
      args.addAll(['--image', image.trim()]);
    }
    if (name.trim().isNotEmpty) {
      args.add(name.trim());
    }

    final result = await Process.run('toolbox', args);
    if (result.exitCode != 0) {
      throw ToolboxCommandException(result.stderr.toString().trim());
    }
  }

  Future<void> removeContainer(String name, {bool force = false}) async {
    final args = ['rm', if (force) '-f', name];
    final result = await Process.run('toolbox', args);
    if (result.exitCode != 0) {
      throw ToolboxCommandException(result.stderr.toString().trim());
    }
  }

  /// Opens a terminal emulator with a shell inside the given container.
  Future<void> enterContainer(String name) async {
    for (final candidate in _terminalCandidates) {
      final exe = candidate.first;
      if (await _isExecutableAvailable(exe)) {
        final args = [...candidate.sublist(1), 'toolbox', 'enter', name];
        await Process.start(exe, args, mode: ProcessStartMode.detached);
        return;
      }
    }
    throw ToolboxCommandException(
      'No supported terminal emulator found (tried ptyxis, konsole, gnome-terminal, xterm).',
    );
  }

  Future<bool> _isExecutableAvailable(String exe) async {
    final result = await Process.run('which', [exe]);
    return result.exitCode == 0;
  }
}
