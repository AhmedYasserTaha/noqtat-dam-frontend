import '../constants/api_constants.dart';
import '../utils/egypt_locations.dart';
import 'api_client.dart';

class LocationsApi {
  LocationsApi(this.api);
  final ApiClient api;

  Future<List<EgyptLocation>> governorates() =>
      _load(ApiConstants.governorates);

  Future<List<EgyptLocation>> districts(String governorateId) =>
      _load(ApiConstants.districts(governorateId));

  Future<List<EgyptLocation>> _load(String path) async {
    final rows = await api.getList(path);
    return rows.map((row) {
      final json = row as Map<String, dynamic>;
      return EgyptLocation(
        id: json['id'] as String,
        arabicName: json['ar'] as String,
        englishName: json['en'] as String,
        parentId: json['governorateId'] as String?,
      );
    }).toList();
  }
}
