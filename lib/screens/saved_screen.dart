import 'package:flutter/material.dart';
import '../models/bangkok_places.dart';
import '../state/user_profile_provider.dart';
import '../widgets/widgets.dart';

class SavedScreen extends StatelessWidget {
  final ValueChanged<BangkokPlace>? onSelectPlaceOnMap;

  const SavedScreen({super.key, this.onSelectPlaceOnMap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final notifier = UserProfileScope.of(context);
    final savedIds = notifier.profile.savedPlaceIds;
    final savedPlaces =
        kBangkokPlaces.where((p) => savedIds.contains(p.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Bangkok Spots'),
        automaticallyImplyLeading: false,
      ),
      body: savedPlaces.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 64,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved places yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the bookmark icon on any Bangkok landmark\nor temple to save it here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: savedPlaces.length,
              itemBuilder: (ctx, i) {
                final place = savedPlaces[i];
                return Dismissible(
                  key: Key(place.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: cs.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.delete_rounded, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    notifier.toggleSavePlace(place.id);
                  },
                  child: GlassCard(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(16),
                    onTap: () {
                      if (onSelectPlaceOnMap != null) {
                        onSelectPlaceOnMap!(place);
                      }
                    },
                    child: Row(
                      children: [
                        PlaceImage(
                          place: place,
                          width: 52,
                          height: 52,
                          borderRadius: BorderRadius.circular(16),
                          showBadge: true,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                place.thaiName,
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 15, color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${place.rating}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    place.district,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.bookmark_rounded,
                            color: Color(0xFFF59E0B),
                          ),
                          onPressed: () => notifier.toggleSavePlace(place.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
