import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PropertyImage extends StatelessWidget {
  const PropertyImage({
    required this.imageUrl,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String imageUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('data:image/')) {
      try {
        final bytes = base64Decode(
          imageUrl.substring(imageUrl.indexOf(',') + 1),
        );
        return Image.memory(bytes, fit: fit);
      } on FormatException {
        return const Center(child: Icon(Icons.broken_image_outlined));
      }
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) =>
          const Center(child: Icon(Icons.broken_image_outlined)),
    );
  }
}
