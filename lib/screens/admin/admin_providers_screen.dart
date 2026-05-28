import 'package:batchit/services/api_client.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

class AdminProvidersScreen extends StatefulWidget {
  const AdminProvidersScreen({super.key});

  @override
  State<AdminProvidersScreen> createState() => _AdminProvidersScreenState();
}

class _AdminProvidersScreenState extends State<AdminProvidersScreen> {
  final ApiClient _api = ApiClient();
  List<Map<String, dynamic>> _providers = [];
  bool _isLoading = true;
  String _statusFilter = 'pending';

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.fixed,
        content: Text(message),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.get('/admin/providers/?status=$_statusFilter');
      final items = response is List ? response : [];
      setState(() {
        _providers = items.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Error loading providers: $e');
    }
  }

  Future<void> _verify(String providerId, String action) async {
    String? rejectionMessage;

    if (action == 'reject') {
      rejectionMessage = await showDialog<String>(
        context: context,
        builder: (ctx) {
          final controller = TextEditingController();
          return AlertDialog(
            title: const Text('Rejection reason'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Explain why this provider is rejected'),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    Navigator.pop(ctx, controller.text.trim());
                  }
                },
                child: const Text('Reject'),
              ),
            ],
          );
        },
      );
      if (rejectionMessage == null || !mounted) return;
    }

    try {
      await _api.post('/admin/providers/$providerId/verify/', body: {
        'action': action,
        if (rejectionMessage != null) 'rejection_message': rejectionMessage,
      });
      if (mounted) {
        _showMessage('Provider ${action == 'approve' ? 'approved' : 'rejected'}.');
        _load();
      }
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  Future<void> _downloadDocument({
    required String providerId,
    required int index,
    required String fileName,
  }) async {
    try {
      final bytes = await _api.getBytes('/providers/$providerId/documents/$index/download/');
      final safeName = fileName.isEmpty ? 'provider_document_${index + 1}' : fileName;
      final file = File('${Directory.systemTemp.path}${Platform.pathSeparator}$safeName');
      await file.writeAsBytes(bytes, flush: true);

      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done && mounted) {
        _showMessage('Saved to ${file.path}');
      }
    } catch (e) {
      _showMessage('Unable to download document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Verification'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _statusFilter,
            onSelected: (v) {
              _statusFilter = v;
              _load();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'pending', child: Text('Pending')),
              PopupMenuItem(value: 'verified', child: Text('Verified')),
              PopupMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Text(_statusFilter.toUpperCase(),
                      style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: AppScreenContainer(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _providers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 64, color: scheme.onSurfaceVariant),
                        const SizedBox(height: AppSpacing.sm),
                        Text('No $_statusFilter providers',
                            style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _providers.length,
                    itemBuilder: (_, i) => _ProviderCard(
                      data: _providers[i],
                        onDownloadDocument: (providerId, index, fileName) => _downloadDocument(
                          providerId: providerId,
                          index: index,
                          fileName: fileName,
                        ),
                      onApprove: _statusFilter == 'pending'
                          ? () => _verify(_providers[i]['id'] as String, 'approve')
                          : null,
                      onReject: _statusFilter == 'pending'
                          ? () => _verify(_providers[i]['id'] as String, 'reject')
                          : null,
                    ),
                  ),
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.data,
    this.onDownloadDocument,
    this.onApprove,
    this.onReject,
  });

  final Map<String, dynamic> data;
  final Future<void> Function(String providerId, int index, String fileName)? onDownloadDocument;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = data['status'] as String? ?? 'pending';
    final documentUrls = (data['document_urls'] as List<dynamic>?)
            ?.whereType<String>()
            .toList() ??
        const <String>[];
    final providerId = data['id'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    data['business_name'] as String? ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _StatusChip(status: status, scheme: scheme),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            _Info('Owner', data['owner_name'] as String? ?? ''),
            _Info('Email', data['owner_email'] as String? ?? ''),
            _Info('Phone', data['phone'] as String? ?? ''),
            _Info('Category', data['category'] as String? ?? ''),
            _Info('Address', data['address'] as String? ?? ''),
            _Info('Reg. Number', data['registration_number'] as String? ?? ''),
            const SizedBox(height: AppSpacing.xs),
            OutlinedButton.icon(
              onPressed: (documentUrls.isEmpty || onDownloadDocument == null)
                  ? null
                  : () {
                      showDialog<void>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Business Documents'),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: documentUrls.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (_, index) {
                                final uri = Uri.tryParse(documentUrls[index]);
                                final fileName = uri != null && uri.pathSegments.isNotEmpty
                                    ? uri.pathSegments.last
                                    : 'document_${index + 1}';
                                return OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                    onDownloadDocument!(providerId, index, fileName);
                                  },
                                  icon: const Icon(Icons.open_in_new_outlined, size: 18),
                                  label: Text('Open document ${index + 1}'),
                                );
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
              icon: const Icon(Icons.description_outlined),
              label: Text('View documents (${documentUrls.length})'),
            ),
            if (documentUrls.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'No documents uploaded yet.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
            if (data['rejection_message'] != null &&
                (data['rejection_message'] as String).isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: scheme.onErrorContainer),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        data['rejection_message'] as String,
                        style: TextStyle(color: scheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (onApprove != null || onReject != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (onApprove != null)
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onApprove,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Approve'),
                      ),
                    ),
                  if (onApprove != null && onReject != null)
                    const SizedBox(width: AppSpacing.sm),
                  if (onReject != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReject,
                        icon: Icon(Icons.close_rounded, color: scheme.error),
                        label: Text('Reject', style: TextStyle(color: scheme.error)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: scheme.error),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.scheme});
  final String status;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case 'verified':
        bg = Colors.green.shade100;
        fg = Colors.green.shade800;
        break;
      case 'rejected':
        bg = scheme.errorContainer;
        fg = scheme.onErrorContainer;
        break;
      default:
        bg = scheme.secondaryContainer;
        fg = scheme.onSecondaryContainer;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(),
          style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
