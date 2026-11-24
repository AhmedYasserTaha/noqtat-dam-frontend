import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/hospital_model.dart';

class HospitalRemoteDataSource {
  HospitalRemoteDataSource(this.api);
  final ApiClient api;

  Future<List<HospitalModel>> inGovernorate(String governorateId) async => [
    for (final item in await api.getAll(
      ApiConstants.hospitals,
      query: {'governorateId': governorateId},
    ))
      HospitalModel.fromJson(item as Map<String, dynamic>),
  ];
}
