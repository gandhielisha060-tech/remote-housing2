import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/property.dart';
import '../../../domain/entities/report.dart';
import '../../providers/property_providers.dart';
import '../../providers/review_report_providers.dart';
import '../../widgets/app_bar_controls.dart';
import '../../widgets/metric_tile.dart';
import '../../widgets/soc_widgets.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingPropertiesProvider);
    final reports = ref.watch(reportsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Admin control room'),
        actions: const [AppBarControls()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          GlassPanel(
            accent: scheme.secondary,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: scheme.secondary.withValues(alpha: 0.16),
                  child: Icon(
                    Icons.admin_panel_settings_outlined,
                    color: scheme.secondary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Moderation control room',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Review listing signals, reports, and platform trust.',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const StatusPill(
                  label: 'System monitored',
                  tone: StatusTone.secure,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              return GridView.count(
                crossAxisCount: compact ? 1 : 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: compact ? 5.2 : 2.7,
                children: [
                  MetricTile(
                    icon: Icons.pending_actions_outlined,
                    label: 'Pending listings',
                    value: pending.maybeWhen(
                      data: (items) => '${items.length}',
                      orElse: () => '...',
                    ),
                    accent: MetricAccent.orange,
                  ),
                  MetricTile(
                    icon: Icons.flag_outlined,
                    label: 'Open reports',
                    value: reports.maybeWhen(
                      data: (items) =>
                          '${items.where((report) => !report.resolved).length}',
                      orElse: () => '...',
                    ),
                    accent: MetricAccent.orange,
                  ),
                  const MetricTile(
                    icon: Icons.shield_outlined,
                    label: 'Trust score',
                    value: '98%',
                    accent: MetricAccent.green,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          const SectionTitle(
            title: 'Platform health',
            subtitle: 'Signals from the current moderation cycle.',
          ),
          const SizedBox(height: 12),
          GlassPanel(
            accent: scheme.primary,
            child: Row(
              children: [
                const ScoreMeter(score: 98),
                const Spacer(),
                QuickAction(
                  icon: Icons.analytics_outlined,
                  label: 'Review analytics',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Analytics workspace is ready for live data.',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionTitle(
            title: 'Listing approval queue',
            subtitle: 'Approve accurate homes before they reach students.',
          ),
          const SizedBox(height: 12),
          pending.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, stackTrace) =>
                Text('Could not load pending listings: $error'),
            data: (items) => Column(
              children: [
                for (final property in items)
                  GlassPanel(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    accent: scheme.secondary,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.home_work_outlined,
                        color: scheme.secondary,
                      ),
                      title: Text(property.title),
                      subtitle: Text(
                        '${property.community} - ${property.monthlyRent} NGN/month',
                      ),
                      onTap: () => context.go('/properties/${property.id}'),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            tooltip: 'Approve listing',
                            onPressed: () => _updateStatus(
                              ref,
                              property.id,
                              PropertyStatus.approved,
                            ),
                            icon: Icon(
                              Icons.check_circle_outline,
                              color: scheme.primary,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Reject listing',
                            onPressed: () => _updateStatus(
                              ref,
                              property.id,
                              PropertyStatus.rejected,
                            ),
                            icon: Icon(
                              Icons.cancel_outlined,
                              color: scheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (items.isEmpty)
                  const GlassPanel(
                    child: Center(child: Text('Approval queue is clear.')),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionTitle(
            title: 'Report center',
            subtitle: 'Student reports requiring administrator attention.',
          ),
          const SizedBox(height: 12),
          reports.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, stackTrace) =>
                Text('Could not load reports: $error'),
            data: (items) => Column(
              children: [
                for (final report in items)
                  GlassPanel(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    accent: report.resolved ? scheme.primary : scheme.error,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        report.resolved ? Icons.task_alt : Icons.flag_outlined,
                        color: report.resolved ? scheme.primary : scheme.error,
                      ),
                      title: Text(report.reason.label),
                      subtitle: Text(report.details),
                      trailing: report.resolved
                          ? const StatusPill(
                              label: 'Resolved',
                              tone: StatusTone.secure,
                            )
                          : TextButton(
                              onPressed: () async {
                                await ref
                                    .read(reportRepositoryProvider)
                                    .resolveReport(report.id);
                                ref.invalidate(reportsProvider);
                              },
                              child: const Text('Resolve'),
                            ),
                    ),
                  ),
                if (items.isEmpty)
                  const GlassPanel(
                    child: Center(child: Text('No open reports.')),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(
    WidgetRef ref,
    String propertyId,
    PropertyStatus status,
  ) async {
    await ref.read(propertyRepositoryProvider).updateStatus(propertyId, status);
    ref.invalidate(pendingPropertiesProvider);
    ref.invalidate(propertiesProvider);
  }
}
