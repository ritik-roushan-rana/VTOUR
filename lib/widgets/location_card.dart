import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import CachedNetworkImage
import '../models/location_model.dart';
import '../utils/app_theme.dart';

class LocationCard extends StatelessWidget {
  final Location location;
  final VoidCallback onTap;

  const LocationCard({
    super.key,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                    ),
                    // CORRECTED: Use CachedNetworkImage for network paths
                    child: (location.imagePath.startsWith('http://') || location.imagePath.startsWith('https://'))
                        ? CachedNetworkImage(
                            imageUrl: location.imagePath,
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
                        : Container( // Fallback for non-HTTP paths (e.g., local placeholders)
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 32,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              location.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            location.isAvailable ? Icons.check_circle : Icons.cancel,
                            color: location.isAvailable ? Colors.green : Colors.red,
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        location.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}