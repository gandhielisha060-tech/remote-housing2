import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/report.dart';
import '../../../domain/entities/review.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_providers.dart';
import '../../providers/review_report_providers.dart';
import '../../widgets/app_bar_controls.dart';
import '../../widgets/property_image.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  const PropertyDetailScreen({required this.propertyId, super.key});

  final String propertyId;

  @override
  ConsumerState<PropertyDetailScreen> createState() =>
      _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  final _reviewController = TextEditingController();
  final _reportController = TextEditingController();
  ReportReason _reason = ReportReason.wrongInformation;
  double _rating = 4;

  @override
  void dispose() {
    _reviewController.dispose();
    _reportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsync = ref.watch(propertyByIdProvider(widget.propertyId));
    final reviewsAsync = ref.watch(propertyReviewsProvider(widget.propertyId));
    final user = ref.watch(authControllerProvider).user;
    final isAdmin = user?.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Property details'),
        leading: const AppBackButton(),
        actions: const [AppBarControls()],
      ),
      body: propertyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Could not load property: $error')),
        data: (property) {
          if (property == null) {
            return const Center(child: Text('Property not found'));
          }
          final distance = _distanceKm(
            AppConstants.mauMainGateLatitude,
            AppConstants.mauMainGateLongitude,
            property.latitude,
            property.longitude,
          );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: isAdmin ? 4.8 : 16 / 7,
                  child: PropertyImage(
                    imageUrl: property.imageUrls.first,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(property.description),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(
                              label: Text('NGN ${property.monthlyRent}/month'),
                            ),
                            Chip(label: Text('${property.numberOfRooms} room')),
                            Chip(
                              label: Text(
                                '${distance.toStringAsFixed(1)} km from MAU gate',
                              ),
                            ),
                            Chip(
                              label: Text(
                                property.available
                                    ? 'Available'
                                    : 'Unavailable',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: property.amenities
                              .map((amenity) => Chip(label: Text(amenity)))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  if (isAdmin)
                    FilledButton.icon(
                      onPressed: () =>
                          context.go('/landlords/${property.landlordId}'),
                      icon: const Icon(Icons.contact_page_outlined),
                      label: const Text('View landlord'),
                    ),
                  if (user?.role == UserRole.student)
                    OutlinedButton.icon(
                      onPressed: () =>
                          context.go('/agent-contact/${property.id}'),
                      icon: const Icon(Icons.support_agent_outlined),
                      label: const Text('Contact Agent'),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Reviews',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              reviewsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, stackTrace) =>
                    Text('Could not load reviews: $error'),
                data: (reviews) => Column(
                  children: [
                    for (final review in reviews)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          child: Icon(Icons.person_outline),
                        ),
                        title: Text(
                          '${review.studentName} - ${review.overallRating.toStringAsFixed(1)}',
                        ),
                        subtitle: Text(review.comment),
                      ),
                    if (reviews.isEmpty)
                      const ListTile(title: Text('No student reviews yet')),
                  ],
                ),
              ),
              if (user != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Submit review',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Slider(
                          value: _rating,
                          min: 1,
                          max: 5,
                          divisions: 8,
                          label: _rating.toStringAsFixed(1),
                          onChanged: (value) => setState(() => _rating = value),
                        ),
                        TextField(
                          controller: _reviewController,
                          decoration: const InputDecoration(
                            labelText: 'Comment',
                          ),
                          minLines: 2,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => _submitReview(user.id, user.name),
                          icon: const Icon(Icons.rate_review_outlined),
                          label: const Text('Submit review'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report listing',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        DropdownButton<ReportReason>(
                          value: _reason,
                          items: ReportReason.values.map((reason) {
                            return DropdownMenuItem(
                              value: reason,
                              child: Text(reason.label),
                            );
                          }).toList(),
                          onChanged: (reason) => setState(
                            () => _reason =
                                reason ?? ReportReason.wrongInformation,
                          ),
                        ),
                        TextField(
                          controller: _reportController,
                          decoration: const InputDecoration(
                            labelText: 'Details',
                          ),
                          minLines: 2,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => _submitReport(user.id),
                          icon: const Icon(Icons.flag_outlined),
                          label: const Text('Send report'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _submitReview(String userId, String studentName) async {
    final comment = _reviewController.text.trim();
    if (comment.isEmpty) return;
    try {
      await ref
          .read(reviewRepositoryProvider)
          .submitReview(
            PropertyReview(
              id: 'review-${DateTime.now().microsecondsSinceEpoch}',
              propertyId: widget.propertyId,
              studentId: userId,
              studentName: studentName,
              comment: comment,
              overallRating: _rating,
              waterRating: _rating,
              electricityRating: _rating,
              internetRating: _rating,
              securityRating: _rating,
              createdAt: DateTime.now(),
            ),
          );
      _reviewController.clear();
      ref.invalidate(propertyReviewsProvider(widget.propertyId));
      _showMessage('Review submitted');
    } on Object catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _submitReport(String userId) async {
    final details = _reportController.text.trim();
    if (details.isEmpty) return;
    await ref
        .read(reportRepositoryProvider)
        .submitReport(
          PropertyReport(
            id: 'report-${DateTime.now().microsecondsSinceEpoch}',
            propertyId: widget.propertyId,
            studentId: userId,
            reason: _reason,
            details: details,
            createdAt: DateTime.now(),
          ),
        );
    _reportController.clear();
    ref.invalidate(reportsProvider);
    _showMessage('Report sent to administrators');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;
  final dLat = _radians(lat2 - lat1);
  final dLon = _radians(lon2 - lon1);
  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_radians(lat1)) *
          math.cos(_radians(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

double _radians(double degrees) => degrees * math.pi / 180;
