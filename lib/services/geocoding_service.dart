import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/bangkok_places.dart';

class GeocodingService {
  GeocodingService._();

  /// Curated collection of famous Thai Sois (ซอย) and Villages (หมู่บ้าน/บ้าน)
  static final List<BangkokPlace> kSoiAndVillagePlaces = [
    // ── SOIS (ซอย) ────────────────────────────────────────────────────────
    BangkokPlace(
      id: 'soi_thong_lo',
      name: 'Soi Thong Lo (Sukhumvit 55)',
      thaiName: 'ซอยทองหล่อ (สุขุมวิท 55)',
      category: 'Street Food',
      region: 'Bangkok',
      province: 'Bangkok',
      icon: Icons.signpost_rounded,
      color: const Color(0xFF6366F1),
      location: const LatLng(13.7317, 100.5815),
      rating: 4.8,
      reviewCount: 32000,
      price: '฿฿',
      openHours: '24 Hours (Night dining & cafés)',
      district: 'Watthana',
      transitInfo: 'BTS Thong Lo Station (Exit 3)',
      description:
          'Bangkok’s trendiest avenue lined with chic brunch spots, Japanese izakayas, speakeasy bars, and vibrant street life.',
      highlights: ['Upscale Dining', 'Speakeasies', 'Japanese Izakayas', 'BTS Thong Lo'],
      navigationSteps: [
        'Head east along Sukhumvit Rd',
        'Turn into Sukhumvit Soi 55 (Thong Lo)',
        'Arrive at Thong Lo central commercial strip',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1200&q=80',
    ),
    BangkokPlace(
      id: 'soi_ekkamai',
      name: 'Soi Ekkamai (Sukhumvit 63)',
      thaiName: 'ซอยเอกมัย (สุขุมวิท 63)',
      category: 'Street Food',
      region: 'Bangkok',
      province: 'Bangkok',
      icon: Icons.signpost_rounded,
      color: const Color(0xFF8B5CF6),
      location: const LatLng(13.7258, 100.5855),
      rating: 4.7,
      reviewCount: 24500,
      price: '฿฿',
      openHours: '24 Hours',
      district: 'Watthana',
      transitInfo: 'BTS Ekkamai Station',
      description:
          'Hip lifestyle corridor famous for vintage boutiques, craft beer bars, Michelin beef noodles (Wattana Panich), and indie cafés.',
      highlights: ['Wattana Panich Beef Noodles', 'Craft Coffee', 'Vintage Shops', 'Nightlife'],
      navigationSteps: [
        'Follow Sukhumvit Rd past Gateway Ekkamai',
        'Turn left into Soi Ekkamai 63',
        'Arrive at Ekkamai central avenue',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1200&q=80',
    ),
    BangkokPlace(
      id: 'soi_ari',
      name: 'Soi Ari (Phahonyothin 7)',
      thaiName: 'ซอยอารีย์ (พหลโยธิน 7)',
      category: 'Street Food',
      region: 'Bangkok',
      province: 'Bangkok',
      icon: Icons.local_cafe_rounded,
      color: const Color(0xFFEC4899),
      location: const LatLng(13.7797, 100.5447),
      rating: 4.8,
      reviewCount: 28900,
      price: '฿฿',
      openHours: '08:00 - 23:00',
      district: 'Phaya Thai',
      transitInfo: 'BTS Ari Station (Exit 3)',
      description:
          'Charming tree-lined neighborhood celebrated as Bangkok’s café hopping epicenter, brimming with artisan bakeries, pasta bars, and leafy courtyards.',
      highlights: ['Café Hopping', 'Artisan Bakeries', 'Leafy Alleyways', 'BTS Ari'],
      navigationSteps: [
        'Head north on Phahonyothin Rd past Sanam Pao',
        'Turn into Soi Phahonyothin 7 (Soi Ari)',
        'Arrive at Ari Neighborhood Plaza',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=1200&q=80',
    ),
    BangkokPlace(
      id: 'soi_banthat_thong',
      name: 'Soi Banthat Thong (Chula Soi 12)',
      thaiName: 'ถนนบรรทัดทอง (จุฬา ซอย 12)',
      category: 'Street Food',
      region: 'Bangkok',
      province: 'Bangkok',
      icon: Icons.restaurant_rounded,
      color: const Color(0xFFEF4444),
      location: const LatLng(13.7423, 100.5235),
      rating: 4.9,
      reviewCount: 45000,
      price: '฿',
      openHours: '16:00 - 00:00 (Night Food Corridor)',
      district: 'Pathum Wan',
      transitInfo: 'MRT Sam Yan / BTS National Stadium',
      description:
          'The hottest new culinary street in Bangkok! Famous for viral dessert toasts (Nueng Nom Nao), crab fried rice, duck noodles, and street sweets.',
      highlights: ['Viral Milk & Toast Stalls', 'Michelin Street Food', 'Chula University Vibe', 'Midnight Desserts'],
      navigationSteps: [
        'Take Rama I Rd toward National Stadium',
        'Turn south into Banthat Thong Rd',
        'Arrive at Banthat Thong foodie corridor',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?auto=format&fit=crop&w=1200&q=80',
    ),
    BangkokPlace(
      id: 'soi_nana_sukhumvit',
      name: 'Soi Nana (Sukhumvit 4)',
      thaiName: 'ซอยนานา (สุขุมวิท 4)',
      category: 'Culture',
      region: 'Bangkok',
      province: 'Bangkok',
      icon: Icons.nightlife_rounded,
      color: const Color(0xFFF43F5E),
      location: const LatLng(13.7408, 100.5532),
      rating: 4.5,
      reviewCount: 38000,
      price: '฿฿',
      openHours: '18:00 - 02:00',
      district: 'Khlong Toei',
      transitInfo: 'BTS Nana Station',
      description:
          'Bustling cosmopolitan hub with Middle Eastern dining, authentic street food, and vibrant nightlife.',
      highlights: ['Arab Street Cuisine', 'Night Market Stalls', 'BTS Nana', 'Cosmopolitan Vibe'],
      navigationSteps: [
        'Follow Sukhumvit Rd toward Asok',
        'Turn into Sukhumvit Soi 4 (Nana)',
        'Arrive at Nana Center',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=1200&q=80',
    ),
    BangkokPlace(
      id: 'soi_convent_silom',
      name: 'Soi Convent (Silom)',
      thaiName: 'ซอยคอนแวนต์ (สีลม)',
      category: 'Street Food',
      region: 'Bangkok',
      province: 'Bangkok',
      icon: Icons.lunch_dining_rounded,
      color: const Color(0xFFF59E0B),
      location: const LatLng(13.7259, 100.5348),
      rating: 4.7,
      reviewCount: 19500,
      price: '฿',
      openHours: '06:00 - 22:00',
      district: 'Bang Rak / Silom',
      transitInfo: 'BTS Sala Daeng / MRT Si Lom',
      description:
          'Famous Silom alleyway packed with daytime street vendors serving Yen Ta Fo pink noodles, crispy pork rice, and evening wine bistros.',
      highlights: ['Yen Ta Fo Pink Noodles', 'Crispy Pork Belly', 'Silom Business Hub', 'BTS Sala Daeng'],
      navigationSteps: [
        'Take Silom Rd toward Sala Daeng',
        'Turn into Soi Convent',
        'Arrive at Soi Convent Food Strip',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80',
    ),
    BangkokPlace(
      id: 'soi_rambuttri',
      name: 'Soi Rambuttri (Banglamphu)',
      thaiName: 'ซอยรามบุตรี (บางลำพู)',
      category: 'Culture',
      region: 'Bangkok',
      province: 'Bangkok',
      icon: Icons.local_activity_rounded,
      color: const Color(0xFF10B981),
      location: const LatLng(13.7599, 100.4965),
      rating: 4.8,
      reviewCount: 26000,
      price: '฿',
      openHours: '24 Hours',
      district: 'Phra Nakhon',
      transitInfo: 'Chao Phraya Express: Phra Athit Pier (N13)',
      description:
          'The chilled-out, leafy sister street of Khao San Road with fairy lights, open-air cocktail bars, street massage, and live acoustic music.',
      highlights: ['Fairy-lit Trees', 'Acoustic Music Bars', 'Relaxed Night Vibe', 'Street Foot Massage'],
      navigationSteps: [
        'Take Phra Athit Rd along Chao Phraya river',
        'Turn into Soi Rambuttri walking street',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?auto=format&fit=crop&w=1200&q=80',
    ),

    // ── VILLAGES (หมู่บ้าน / ชุมชน) ──────────────────────────────────────────
    BangkokPlace(
      id: 'village_kudichin',
      name: 'Kudichin Historic Portuguese Village',
      thaiName: 'ชุมชนกุฎีจีน (หมู่บ้านโปรตุเกส ริมเจ้าพระยา)',
      category: 'Culture',
      region: 'Bangkok',
      province: 'Bangkok',
      icon: Icons.holiday_village_rounded,
      color: const Color(0xFF06B6D4),
      location: const LatLng(13.7388, 100.4938),
      rating: 4.8,
      reviewCount: 14200,
      price: 'Free',
      openHours: '09:00 - 18:00',
      district: 'Thonburi',
      transitInfo: 'Cross-river Ferry from Pak Khlong Talat (Flower Market) to Wat Kalayanamit',
      description:
          'A living 250-year-old riverside heritage community founded by Portuguese settlers in 1767. Famous for the Santa Cruz Church and traditional Khanom Farang Kudichin sponge cakes.',
      highlights: ['250-Year Heritage', 'Santa Cruz Church', 'Khanom Kudichin Cakes', 'River Boardwalks'],
      navigationSteps: [
        'Cross Memorial Bridge to Thonburi',
        'Follow Arun Amarin Rd into Kudichin Heritage Alleys',
        'Arrive at Santa Cruz Village Square',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1528181304800-259b08848526?auto=format&fit=crop&w=1200&q=80',
    ),
    BangkokPlace(
      id: 'village_ban_bat',
      name: 'Ban Bat Monk Bowl Handcraft Village',
      thaiName: 'ชุมชนบ้านบาตร (หมู่บ้านทำบาตรพระโบราณ)',
      category: 'Culture',
      region: 'Bangkok',
      province: 'Bangkok',
      icon: Icons.handyman_rounded,
      color: const Color(0xFFD97706),
      location: const LatLng(13.7516, 100.5052),
      rating: 4.7,
      reviewCount: 9800,
      price: 'Free',
      openHours: '09:00 - 17:00',
      district: 'Pom Prap Sattru Phai',
      transitInfo: 'MRT Sam Yot Station (10 min walk)',
      description:
          'The last remaining community in Thailand that hand-hammers traditional Buddhist monk alms bowls using techniques dating back to the Ayutthaya period.',
      highlights: ['Handmade Monk Bowls', 'Living Ayutthaya Tradition', 'Artisan Blacksmiths', 'Historic Alleyways'],
      navigationSteps: [
        'Take Bamrung Mueang Rd near Golden Mount',
        'Turn into Soi Ban Bat pedestrian lanes',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1596422846543-75c6fc197f07?auto=format&fit=crop&w=1200&q=80',
    ),
    BangkokPlace(
      id: 'village_koh_kret',
      name: 'Koh Kret Mon Pottery Village Island',
      thaiName: 'เกาะเกร็ด (หมู่บ้านเครื่องปั้นดินเผาชาวมอญ)',
      category: 'Culture',
      region: 'Central',
      province: 'Nonthaburi',
      icon: Icons.store_rounded,
      color: const Color(0xFFEA580C),
      location: const LatLng(13.9127, 100.4897),
      rating: 4.7,
      reviewCount: 22000,
      price: '฿2 (Ferry)',
      openHours: 'Sat - Sun: 09:00 - 17:30',
      district: 'Pak Kret',
      transitInfo: 'Ferry from Wat Sanam Neua Pier (Pak Kret)',
      description:
          'Car-free island in the Chao Phraya River settled by ethnic Mon people. Famous for terracotta pottery, Chitbeer craft brewery, and Thai sweets.',
      highlights: ['Car-free Island Cycling', 'Terracotta Pottery Kilns', 'Chitbeer Craft Beer', 'Mon Traditional Desserts'],
      navigationSteps: [
        'Drive north on Tiwanon Rd to Pak Kret Pier',
        'Take 2-minute cross-river ferry to Koh Kret Pier',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80',
    ),
    BangkokPlace(
      id: 'village_mae_kampong',
      name: 'Ban Mae Kampong Mountain Eco-Village',
      thaiName: 'หมู่บ้านแม่กำปอง (เชียงใหม่)',
      category: 'Parks',
      region: 'North',
      province: 'Chiang Mai',
      icon: Icons.cottage_rounded,
      color: const Color(0xFF10B981),
      location: const LatLng(18.8654, 99.3503),
      rating: 4.9,
      reviewCount: 34000,
      price: 'Free',
      openHours: '24 Hours',
      district: 'Mae On, Chiang Mai',
      transitInfo: 'Van / Scooter from Chiang Mai City (1 hr)',
      description:
          'Scenic misty mountain village nestled in a lush stream valley 1,300m high. Known for wooden stilt homestays, cold mountain tea, and coffee roasters.',
      highlights: ['Misty Mountain Valley', 'Wooden Stream Homestays', 'Arabica Coffee Cafés', 'Mae Kampong Waterfall'],
      navigationSteps: [
        'Drive east from Chiang Mai on Highway 1317 toward Mae On (50 km)',
        'Climb winding mountain pass to Ban Mae Kampong village center',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80',
    ),
    BangkokPlace(
      id: 'village_baan_kang_wat',
      name: 'Baan Kang Wat Artists Village',
      thaiName: 'บ้านข้างวัด (หมู่บ้านศิลปะ เชียงใหม่)',
      category: 'Culture',
      region: 'North',
      province: 'Chiang Mai',
      icon: Icons.palette_rounded,
      color: const Color(0xFFF59E0B),
      location: const LatLng(18.7766, 98.9488),
      rating: 4.8,
      reviewCount: 18500,
      price: 'Free',
      openHours: '10:00 - 18:00 (Closed Mondays)',
      district: 'Mueang Chiang Mai / Suthep',
      transitInfo: 'Scooter / Songthaew near Wat Umong',
      description:
          'Community craft village designed with amphitheater courtyards, ceramics studios, bookshops, handmade jewelry, and organic coffee.',
      highlights: ['Artisan Pottery Workshops', 'Central Green Courtyard', 'Indie Bookshops', 'Craft Markets'],
      navigationSteps: [
        'Drive west along Suthep Rd near Chiang Mai University',
        'Follow signs past Wat Umong to Baan Kang Wat',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80',
    ),
    BangkokPlace(
      id: 'village_bang_nam_phueng',
      name: 'Bang Nam Phueng Green Lung Village',
      thaiName: 'บางน้ำผึ้ง (คุ้งบางกระเจ้า สมุทรปราการ)',
      category: 'Parks',
      region: 'Bangkok',
      province: 'Samut Prakan',
      icon: Icons.forest_rounded,
      color: const Color(0xFF22C55E),
      location: const LatLng(13.6798, 100.5752),
      rating: 4.7,
      reviewCount: 19800,
      price: 'Free',
      openHours: 'Sat - Sun: 08:00 - 16:00 (Floating Market)',
      district: 'Phra Pradaeng (Bang Krachao)',
      transitInfo: 'Longtail ferry from Wat Bang Na Nok Pier (฿5)',
      description:
          'The "Green Lung of Bangkok" canal village inside the forested loop of the Chao Phraya River. Perfect for bicycle paths and mangrove canal markets.',
      highlights: ['Bicycle Elevated Boardwalks', 'Canal Floating Market', 'Firefly Sanctuary', 'Organic Farm Products'],
      navigationSteps: [
        'Take ferry from Bang Na pier or drive via Industrial Ring Road Bridge',
        'Enter Bang Nam Phueng village cycling track',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1587974928442-77dc3e0dba72?auto=format&fit=crop&w=1200&q=80',
    ),
  ];

  /// Queries OpenStreetMap Nominatim for ANY location, Soi, Village, Muban in Thailand!
  static Future<List<BangkokPlace>> searchEverywhereInThailand(
      String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final results = <BangkokPlace>[];

    // 1. Check local Thailand destinations + Sois & Villages
    final allLocal = [...kBangkokPlaces, ...kSoiAndVillagePlaces];
    final queryLower = cleanQuery.toLowerCase();

    for (final p in allLocal) {
      if (p.name.toLowerCase().contains(queryLower) ||
          p.thaiName.toLowerCase().contains(queryLower) ||
          p.province.toLowerCase().contains(queryLower) ||
          p.district.toLowerCase().contains(queryLower)) {
        if (!results.any((r) => r.id == p.id)) {
          results.add(p);
        }
      }
    }

    // 2. Query Nominatim for Sois, Villages, Mubans anywhere across all 77 provinces of Thailand
    try {
      final encoded = Uri.encodeComponent(cleanQuery);
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$encoded'
        '&countrycodes=th&format=json&addressdetails=1&limit=6',
      );

      final response = await http
          .get(
            url,
            headers: {'User-Agent': 'ThailandMappingApp/2.4'},
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final list = json.decode(response.body) as List<dynamic>?;
        if (list != null) {
          for (final item in list) {
            final lat = double.tryParse(item['lat']?.toString() ?? '');
            final lon = double.tryParse(item['lon']?.toString() ?? '');
            if (lat == null || lon == null) continue;

            final displayName = item['display_name'] as String? ?? cleanQuery;
            final address = item['address'] as Map<String, dynamic>?;
            final village = address?['village'] ??
                address?['hamlet'] ??
                address?['suburb'] ??
                address?['neighbourhood'] ??
                address?['road'];
            final province = address?['province'] ??
                address?['state'] ??
                address?['city'] ??
                'Thailand';
            final district = address?['county'] ??
                address?['district'] ??
                village ??
                province;

            final title = village != null
                ? '$village, $province'
                : displayName.split(',').take(2).join(', ');

            final isSoi = cleanQuery.toLowerCase().contains('soi') ||
                displayName.toLowerCase().contains('soi') ||
                displayName.contains('ซอย');
            final isVillage = cleanQuery.toLowerCase().contains('village') ||
                cleanQuery.toLowerCase().contains('ban') ||
                cleanQuery.contains('หมู่บ้าน') ||
                cleanQuery.contains('บ้าน');

            final place = BangkokPlace(
              id: 'osm_${item['osm_id'] ?? DateTime.now().millisecondsSinceEpoch}',
              name: title,
              thaiName: displayName.split(',').first,
              category: isSoi
                  ? 'Street Food'
                  : isVillage
                      ? 'Culture'
                      : 'Parks',
              region: 'Thailand',
              province: province.toString(),
              icon: isSoi
                  ? Icons.signpost_rounded
                  : isVillage
                      ? Icons.holiday_village_rounded
                      : Icons.place_rounded,
              color: isSoi
                  ? const Color(0xFF6366F1)
                  : isVillage
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
              location: LatLng(lat, lon),
              rating: 4.7,
              reviewCount: 1520,
              price: 'Free',
              openHours: '24 Hours',
              district: district.toString(),
              transitInfo: 'Road access via $province',
              description: 'Location in $province, Thailand. $displayName',
              highlights: ['Thailand Location', 'Road Access', 'Local Community'],
              navigationSteps: [
                'Head toward $province via connecting road',
                'Turn onto $district corridor',
                'Arrive at $title',
              ],
              imageUrl: isSoi
                  ? 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?auto=format&fit=crop&w=1200&q=80'
                  : isVillage
                      ? 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80'
                      : 'https://images.unsplash.com/photo-1508009603885-50cf7c579365?auto=format&fit=crop&w=1200&q=80',
            );

            if (!results.any((r) =>
                r.location.latitude == lat && r.location.longitude == lon)) {
              results.add(place);
            }
          }
        }
      }
    } catch (_) {
      // Continue with local matches if offline
    }

    return results;
  }
}
