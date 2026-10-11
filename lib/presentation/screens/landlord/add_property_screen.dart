import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/validators/input_validators.dart';
import '../../../domain/entities/property.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_providers.dart';
import '../../widgets/app_bar_controls.dart';
import '../../widgets/property_image.dart';

class AddPropertyScreen extends ConsumerStatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  ConsumerState<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<AddPropertyScreen> {
  static const _amenities = [
    'Water',
    'Electricity',
    'Internet',
    'Security',
    'Kitchen',
    'Bathroom',
    'Parking',
  ];

  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _community = TextEditingController();
  final _address = TextEditingController();
  final _rent = TextEditingController();
  final _rooms = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();

  final Set<String> _amenitiesSelected = {'Water', 'Electricity', 'Security'};
  String _roomType = 'Self-contained';
  String? _imageDataUri;
  String? _imageName;
  bool _available = true;
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [
      _title,
      _description,
      _community,
      _address,
      _rent,
      _rooms,
      _latitude,
      _longitude,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _required(_title, 'Property title', Icons.title),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              minLines: 3,
              maxLines: 5,
              validator: requiredField,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 250,
                  child: _required(
                    _community,
                    'Community',
                    Icons.location_city_outlined,
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: DropdownButtonFormField<String>(
                    initialValue: _roomType,
                    decoration: const InputDecoration(
                      labelText: 'Room type',
                      prefixIcon: Icon(Icons.bed_outlined),
                    ),
                    items:
                        const [
                              'Single room',
                              'Self-contained',
                              'Flat',
                              'Shared apartment',
                            ]
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                    onChanged: (value) =>
                        setState(() => _roomType = value ?? _roomType),
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: _number(_rent, 'Monthly rent (NGN)'),
                ),
                SizedBox(width: 250, child: _number(_rooms, 'Number of rooms')),
              ],
            ),
            const SizedBox(height: 12),
            _required(_address, 'Address', Icons.place_outlined),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_file_outlined),
                label: Text(_imageName ?? 'Choose image from device'),
              ),
            ),
            if (_imageName != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _imageName!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                SizedBox(
                  width: 250,
                  child: _optionalCoordinate(_latitude, 'Latitude'),
                ),
                SizedBox(
                  width: 250,
                  child: _optionalCoordinate(_longitude, 'Longitude'),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Currently available'),
              value: _available,
              onChanged: (value) => setState(() => _available = value),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                children: [
                  for (final amenity in _amenities)
                    FilterChip(
                      label: Text(amenity),
                      selected: _amenitiesSelected.contains(amenity),
                      onSelected: (selected) => setState(() {
                        selected
                            ? _amenitiesSelected.add(amenity)
                            : _amenitiesSelected.remove(amenity);
                      }),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Add property'),
        actions: const [AppBarControls()],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text(
              'Upload a new home',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Select a clear image directly from your device. URL entry is not used.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final preview = _ImagePreview(imageDataUri: _imageDataUri);
                if (constraints.maxWidth < 900) {
                  return Column(
                    children: [preview, const SizedBox(height: 16), form],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: form),
                    const SizedBox(width: 18),
                    Expanded(flex: 3, child: preview),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: const Text('Submit for approval'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final file = await FilePicker.pickFile(type: FileType.image);
    if (!mounted || file == null) return;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      _showMessage('The selected image could not be read.');
      return;
    }
    final extension = (file.extension ?? 'jpeg').toLowerCase();
    final mime = extension == 'jpg' ? 'jpeg' : extension;
    setState(() {
      _imageName = file.name;
      _imageDataUri = 'data:image/$mime;base64,${base64Encode(bytes)}';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageDataUri == null) {
      _showMessage('Choose a property image from your device first.');
      return;
    }
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;

    setState(() => _saving = true);
    final property = HousingProperty(
      id: 'property-${DateTime.now().microsecondsSinceEpoch}',
      landlordId: user.id,
      title: _title.text.trim(),
      description: _description.text.trim(),
      community: _community.text.trim(),
      address: _address.text.trim(),
      latitude:
          double.tryParse(_latitude.text.trim()) ??
          AppConstants.mauMainGateLatitude,
      longitude:
          double.tryParse(_longitude.text.trim()) ??
          AppConstants.mauMainGateLongitude,
      monthlyRent: int.parse(_rent.text.trim()),
      roomType: _roomType,
      numberOfRooms: int.parse(_rooms.text.trim()),
      amenities: {..._amenitiesSelected},
      imageUrls: [_imageDataUri!],
      available: _available,
      status: PropertyStatus.pending,
      averageRating: 0,
      reviewCount: 0,
      lovedBy: {},
      createdAt: DateTime.now(),
    );
    await ref.read(propertyRepositoryProvider).create(property);
    ref.invalidate(landlordPropertiesProvider(user.id));
    ref.invalidate(pendingPropertiesProvider);
    ref.invalidate(propertiesProvider);
    if (!mounted) return;
    setState(() => _saving = false);
    _showMessage('Listing submitted for admin approval.');
    context.go('/landlord');
  }

  Widget _required(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: requiredField,
    );
  }

  Widget _number(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.payments_outlined),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Required';
        final number = int.tryParse(value.trim());
        return number == null || number <= 0 ? 'Enter a valid number' : null;
      },
    );
  }

  Widget _optionalCoordinate(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.my_location_outlined),
      ),
      keyboardType: TextInputType.number,
      validator: (value) =>
          value == null ||
              value.trim().isEmpty ||
              double.tryParse(value.trim()) != null
          ? null
          : 'Enter a valid coordinate',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imageDataUri});

  final String? imageDataUri;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 11,
            child: imageDataUri == null
                ? ColoredBox(
                    color: scheme.surfaceContainerHighest,
                    child: const Center(
                      child: Icon(Icons.photo_camera_outlined, size: 44),
                    ),
                  )
                : PropertyImage(imageUrl: imageDataUri!),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Device image selected. It will be attached to the pending listing.',
            ),
          ),
        ],
      ),
    );
  }
}
