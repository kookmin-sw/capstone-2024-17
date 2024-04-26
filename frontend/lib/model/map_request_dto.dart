class MapLocation {
  double latitude;
  double longitude;

  MapLocation({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class MapCircle {
  MapLocation center;
  double radius;

  MapCircle({required this.center, required this.radius});

  Map<String, dynamic> toJson() {
    return {
      'center': center.toJson(),
      'radius': radius,
    };
  }
}

class MapLocationRestriction {
  MapCircle circle;

  MapLocationRestriction({required this.circle});

  Map<String, dynamic> toJson() {
    return {
      'circle': circle.toJson(),
    };
  }
}

class MapJsonRequest {
  List<String> includedTypes;
  int maxResultCount;
  MapLocationRestriction locationRestriction;

  MapJsonRequest({
    required this.includedTypes,
    required this.maxResultCount,
    required this.locationRestriction,
  });

  Map<String, dynamic> toJson() {
    return {
      'includedTypes': includedTypes,
      'maxResultCount': maxResultCount,
      'locationRestriction': locationRestriction.toJson(),
    };
  }
}

class MapDTO {
  Map<String, dynamic> request(List<String> incTypes, int maxCount, double lat,
      double log, double rad) {
    var request = MapJsonRequest(
      includedTypes: incTypes,
      maxResultCount: maxCount,
      locationRestriction: MapLocationRestriction(
        circle: MapCircle(
          center: MapLocation(latitude: lat, longitude: log),
          radius: rad,
        ),
      ),
    );
    return request.toJson();
  }
}