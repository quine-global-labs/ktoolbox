import 'package:flutter/material.dart';

import '../models/toolbox_container.dart';
import '../services/toolbox_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, ToolboxService? service})
      : service = service ?? const ToolboxService();

  final ToolboxService service;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ToolboxService _service = widget.service;
  late Future<List<ToolboxContainer>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.listContainers();
  }

  void _refresh() {
    setState(() {
      _future = _service.listContainers();
    });
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString())),
    );
  }

  Future<void> _enter(ToolboxContainer container) async {
    try {
      await _service.enterContainer(container.name);
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _remove(ToolboxContainer container) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove container?'),
        content: Text('This will delete "${container.name}" permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _service.removeContainer(container.name, force: true);
      _refresh();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _create() async {
    final result = await showDialog<_CreateResult>(
      context: context,
      builder: (context) => const _CreateContainerDialog(),
    );
    if (result == null) return;

    try {
      await _service.createContainer(name: result.name, image: result.image);
      _refresh();
    } catch (e) {
      _showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ktoolbox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<ToolboxContainer>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final containers = snapshot.data ?? [];
          if (containers.isEmpty) {
            return const Center(
              child: Text('No Toolbox containers yet. Tap + to create one.'),
            );
          }
          return ListView.builder(
            itemCount: containers.length,
            itemBuilder: (context, index) {
              final container = containers[index];
              return ListTile(
                leading: Icon(
                  Icons.circle,
                  size: 12,
                  color: container.isRunning ? Colors.green : Colors.grey,
                ),
                title: Text(container.name),
                subtitle: Text(container.image),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.terminal),
                      tooltip: 'Enter',
                      onPressed: () => _enter(container),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Remove',
                      onPressed: () => _remove(container),
                    ),
                  ],
                ),
                onTap: () => _enter(container),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _create,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CreateResult {
  final String name;
  final String? image;
  _CreateResult(this.name, this.image);
}

class _CreateContainerDialog extends StatefulWidget {
  const _CreateContainerDialog();

  @override
  State<_CreateContainerDialog> createState() => _CreateContainerDialogState();
}

class _CreateContainerDialogState extends State<_CreateContainerDialog> {
  final _nameController = TextEditingController();
  final _imageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Toolbox container'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name (optional)',
              hintText: 'fedora-toolbox-42',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _imageController,
            decoration: const InputDecoration(
              labelText: 'Image (optional)',
              hintText: 'registry.fedoraproject.org/fedora-toolbox:42',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              _CreateResult(
                _nameController.text,
                _imageController.text.isEmpty ? null : _imageController.text,
              ),
            );
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
