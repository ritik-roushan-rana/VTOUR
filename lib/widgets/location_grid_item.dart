import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import CachedNetworkImage
import '../models/location_model.dart'; // Ensure this import is correct
import '../utils/app_theme.dart'; // Ensure this import is correct

class LocationGridItem extends StatelessWidget {
  final Location location;
  final VoidCallback onTap;

  const LocationGridItem({
    super.key,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                  ),
                  // CORRECTED: Use CachedNetworkImage for network paths
                  child: (location.imagePath != null && (location.imagePath!.startsWith('http://') || location.imagePath!.startsWith('https://')))
                      ? CachedNetworkImage(
                          imageUrl: location.imagePath!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          errorWidget: (context, url, error) {
                            // Fallback for network image errors
                            return Container(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              child: const Icon(
                                Icons.broken_image,
                                size: 32,
                                color: AppTheme.textSecondary,
                              ),
                            );
                          },
                        )
                      : Container( // Fallback for null or non-HTTP paths (e.g., local placeholders)
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 32,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        // REMOVED: Dynamic category color
                        color: AppTheme.primaryColor, // Using a static color from AppTheme
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        // Use category string directly
                        location.category,
                        style: const TextStyle(
                          // REMOVED: Dynamic category color
                          color: Colors.white, // Using a static color
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          location.isAvailable ? Icons.check_circle : Icons.cancel,
                          color: location.isAvailable ? Colors.green : Colors.red,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location.isAvailable ? 'Open' : 'Closed',
                          style: TextStyle(
                            color: location.isAvailable ? Colors.green : Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
}
