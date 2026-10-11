import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../providers/property_providers.dart';
import '../../widgets/app_bar_controls.dart';
import '../../widgets/property_image.dart';

class AgentContactScreen extends ConsumerWidget {
  const AgentContactScreen({required this.propertyId, super.key});

  final String propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyAsync = ref.watch(propertyByIdProvider(propertyId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Agent'),
        leading: const AppBackButton(),
        actions: const [AppBarControls()],
      ),
      body: propertyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Could not load apartment details: $error')),
        data: (property) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (property != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 180,
                  child: PropertyImage(
                    imageUrl: property.imageUrls.first,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                property.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${property.community} - ${property.roomType}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.support_agent_outlined,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppConstants.agentName,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Verified housing support agent',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.verified, color: Colors.green),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _ContactRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: AppConstants.agentPhone,
                    ),
                    const SizedBox(height: 14),
                    _ContactRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: AppConstants.supportEmail,
                    ),
                    const SizedBox(height: 14),
                    const _ContactRow(
                      icon: Icons.schedule_outlined,
                      label: 'Office hours',
                      value: 'Monday - Friday, 8:00 AM - 5:00 PM',
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () =>
                            _openWhatsApp(context, property?.title),
                        icon: const Icon(Icons.chat_outlined),
                        label: const Text('Chat with Agent on WhatsApp'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'The agent can help verify availability, arrange a viewing, and connect you with the approved landlord.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWhatsApp(
    BuildContext context,
    String? propertyTitle,
  ) async {
    final apartment = propertyTitle ?? 'an apartment listing';
    final message = Uri.encodeComponent(
      'Hello ${AppConstants.agentName}, I am interested in $apartment on the MAU housing platform. Please share availability and viewing details.',
    );
    final uri = Uri.parse(
      'https://wa.me/${AppConstants.agentWhatsAppNumber}?text=$message',
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp could not be opened.')),
      );
    }
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
