
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/api_service.dart';
import '../../models/audit_log.dart';

final auditProvider = FutureProvider<List<AuditLog>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final dynamic raw = await api.get('reports/audit');
  if (raw is! List) throw Exception('Expected list of audit logs');
  return raw.map<AuditLog>((j) => AuditLog.fromJson(j as Map<String, dynamic>)).toList();
});

final frontendPaginationProvider = StateProvider<FrontendPagination>((ref) {
  return FrontendPagination(
    currentPage: 1,
    itemsPerPage: 15,
    totalItems: 0,
  );
});

class FrontendPagination {
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;

  FrontendPagination({
    required this.currentPage,
    required this.itemsPerPage,
    required this.totalItems,
  });

  int get totalPages => totalItems > 0 ? (totalItems / itemsPerPage).ceil() : 1;
  int get startIndex => (currentPage - 1) * itemsPerPage;
  int get endIndex {
    final calculatedEnd = currentPage * itemsPerPage;
    return calculatedEnd < totalItems ? calculatedEnd : totalItems;
  }

  FrontendPagination copyWith({
    int? currentPage,
    int? itemsPerPage,
    int? totalItems,
  }) {
    return FrontendPagination(
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
    );
  }
}

class AuditLogPage extends ConsumerWidget {
  const AuditLogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditAsync = ref.watch(auditProvider);
    final pagination = ref.watch(frontendPaginationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
      ),
      body: auditAsync.when(
        data: (allLogs) {
          // Update total items
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (pagination.totalItems != allLogs.length) {
              ref.read(frontendPaginationProvider.notifier).state =
                  pagination.copyWith(totalItems: allLogs.length);
            }
          });

          if (allLogs.isEmpty) {
            return const Center(
              child: Text('No audit logs found'),
            );
          }

          // Get paginated data (frontend pagination)
          final safeStart = pagination.startIndex.clamp(0, allLogs.length);
          final safeEnd = pagination.endIndex.clamp(0, allLogs.length);

          // Ensure start is less than end
          if (safeStart >= safeEnd) {
            return const Center(
              child: Text('No data to display'),
            );
          }

          final paginatedLogs = allLogs.sublist(safeStart, safeEnd);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with pagination info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  children: [
                    // Items per page dropdown
                    DropdownButton<int>(
                      value: pagination.itemsPerPage,
                      icon: const Icon(Icons.arrow_drop_down),
                      underline: Container(),
                      items: [10, 15, 20, 30, 50]
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value per page'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(frontendPaginationProvider.notifier).state =
                              pagination.copyWith(
                                itemsPerPage: value,
                                currentPage: 1,
                              );
                        }
                      },
                    ),
                    const Spacer(),
                    // Results info
                    Text(
                      'Showing ${safeStart + 1}-${safeEnd} of ${allLogs.length} logs',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Main content - fills screen
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 24,
                      horizontalMargin: 16,
                      headingRowHeight: 56,
                      dataRowHeight: 80,
                      columns: const [
                        DataColumn(
                          label: Text('Timestamp'),
                          numeric: false,
                        ),
                        DataColumn(
                          label: Text('User'),
                          numeric: false,
                        ),
                        DataColumn(
                          label: Text('Action'),
                          numeric: false,
                        ),
                        DataColumn(
                          label: Text('Entity'),
                          numeric: false,
                        ),
                        DataColumn(
                          label: Text('Changes'),
                          numeric: false,
                        ),
                      ],
                      rows: paginatedLogs.map((log) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Container(
                                width: 150,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  DateFormat('yyyy-MM-dd HH:mm').format(log.timestamp),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: 120,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  log.userName,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: 100,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getActionColor(log.action).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: _getActionColor(log.action).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    log.action,
                                    style: TextStyle(
                                      color: _getActionColor(log.action),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: 120,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  log.entity,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: 300,
                                height: 60, // Fixed height with scroll
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: log.changes.map((change) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          '• ${log.formatChange(change)}',
                                          style: const TextStyle(fontSize: 11),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // Custom pagination controls
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: _buildPaginationControls(ref, pagination, allLogs.length, context),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Error loading audit logs: $e',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(auditProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls(
      WidgetRef ref, FrontendPagination pagination, int totalItems, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // First page button
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed: pagination.currentPage > 1
              ? () {
            ref.read(frontendPaginationProvider.notifier).state =
                pagination.copyWith(currentPage: 1);
          }
              : null,
          tooltip: 'First page',
        ),

        // Previous page button
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: pagination.currentPage > 1
              ? () {
            ref.read(frontendPaginationProvider.notifier).state =
                pagination.copyWith(currentPage: pagination.currentPage - 1);
          }
              : null,
          tooltip: 'Previous page',
        ),

        // Current page info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Page ${pagination.currentPage} of ${pagination.totalPages}',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Next page button
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: pagination.currentPage < pagination.totalPages
              ? () {
            ref.read(frontendPaginationProvider.notifier).state =
                pagination.copyWith(currentPage: pagination.currentPage + 1);
          }
              : null,
          tooltip: 'Next page',
        ),

        // Last page button
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: pagination.currentPage < pagination.totalPages
              ? () {
            ref.read(frontendPaginationProvider.notifier).state =
                pagination.copyWith(currentPage: pagination.totalPages);
          }
              : null,
          tooltip: 'Last page',
        ),

        const SizedBox(width: 24),

        // Page jump input (optional)
        SizedBox(
          width: 100,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Go to page',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            onSubmitted: (value) {
              final page = int.tryParse(value);
              if (page != null &&
                  page >= 1 &&
                  page <= pagination.totalPages) {
                ref.read(frontendPaginationProvider.notifier).state =
                    pagination.copyWith(currentPage: page);
              }
            },
          ),
        ),
      ],
    );
  }

  Color _getActionColor(String action) {
    final upperAction = action.toUpperCase();
    if (upperAction.contains('CREATE')) return Colors.green;
    if (upperAction.contains('UPDATE')) return Colors.blue;
    if (upperAction.contains('DELETE') || upperAction.contains('DEACTIVATE')) {
      return Colors.red;
    }
    if (upperAction.contains('PAYMENT')) return Colors.purple;
    return Colors.grey.shade700;
  }
}