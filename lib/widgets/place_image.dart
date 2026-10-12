import 'package:flutter/material.dart';
import '../models/bangkok_places.dart';

class PlaceImage extends StatelessWidget {
  final BangkokPlace place;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final bool showBadge;
  final VoidCallback? onTap;

  const PlaceImage({
    super.key,
    required this.place,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.showBadge = false,
    this.onTap,
  });

  static String getDefaultImageUrlForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'temples':
        return 'https://images.unsplash.com/photo-1528181304800-259b08848526?auto=format&fit=crop&w=1200&q=80';
      case 'shopping':
        return 'https://images.unsplash.com/photo-1567449303078-57ad995bd301?auto=format&fit=crop&w=1200&q=80';
      case 'street food':
      case 'food':
        return 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?auto=format&fit=crop&w=1200&q=80';
      case 'parks':
        return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80';
      case 'culture':
      default:
        return 'https://images.unsplash.com/photo-1508009603885-50cf7c579365?auto=format&fit=crop&w=1200&q=80';
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);
    final primaryUrl = place.imageUrl.trim().isNotEmpty
        ? place.imageUrl.trim()
        : getDefaultImageUrlForCategory(place.category);

    Widget imageContent = Image.network(
      primaryUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: place.color.withValues(alpha: 0.12),
            borderRadius: radius,
          ),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
                color: place.color,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        final fallbackUrl = getDefaultImageUrlForCategory(place.category);
        if (primaryUrl != fallbackUrl) {
          return Image.network(
            fallbackUrl,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) => _buildFallback(radius),
          );
        }
        return _buildFallback(radius);
      },
    );

    Widget result = ClipRRect(
      borderRadius: radius,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          imageContent,
          if (showBadge)
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Icon(place.icon, size: 12, color: Colors.white),
              ),
            ),
        ],
      ),
    );

    if (onTap != null) {
      result = GestureDetector(
        onTap: onTap,
        child: result,
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: result,
    );
  }

  Widget _buildFallback(BorderRadius radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          colors: [
            place.color.withValues(alpha: 0.28),
            place.color.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          place.icon,
          color: place.color,
          size: (height != null && height! < 60) ? 24 : 32,
        ),
      ),
    );
  }
}
