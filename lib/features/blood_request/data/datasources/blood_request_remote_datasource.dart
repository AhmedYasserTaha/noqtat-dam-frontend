import '../../../../core/network/api_client.dart';
import '../../domain/entities/blood_request.dart';
import '../../domain/entities/donor_pledge.dart';
import '../models/blood_request_model.dart';

class BloodRequestRemoteDataSource {
  BloodRequestRemoteDataSource(this.api);
  final ApiClient api;

  Future<BloodRequestModel> create(BloodRequestDraft d) async =>
      BloodRequestModel.fromJson(
        await api.post(
          '/requests',
          body: {
            'bloodType': d.bloodType,
            'bagsNeeded': d.bagsNeeded,
            'hospitalName': d.hospitalName,
            'hospitalId': ?d.hospitalId,
            'governorateId': d.governorateId,
            'districtId': d.districtId,
            'urgency': d.urgency.api,
            'contactPhone': d.contactPhone,
            'deadline': ?d.deadline?.toUtc().toIso8601String(),
            if (d.notes.trim().isNotEmpty) 'notes': d.notes.trim(),
          },
        ),
      );

  Future<List<BloodRequestModel>> mine(RequestTab tab) async {
    final body = await api.get('/requests/mine', query: {'tab': tab.api});
    return parseList(body);
  }

  Future<BloodRequestModel> update(
    int id, {
    int? bagsCollected,
    RequestStatus? status,
  }) async => BloodRequestModel.fromJson(
    await api.patch(
      '/requests/$id',
      body: {
        if (bagsCollected != null) 'bagsCollected': bagsCollected,
        if (status != null) 'status': status.name,
      },
    ),
  );

  Future<List<DonorPledge>> pledges(int requestId) async => [
    for (final p in await api.getList('/requests/$requestId/pledges'))
      DonorPledge(
        donorId: p['donorId'] as int? ?? 0,
        confirmed: p['confirmed'] as bool? ?? false,
        donorName: (p as Json)['donorName'] as String? ?? '',
        bloodType: p['bloodType'] as String? ?? '',
        status:
            PledgeStatus.fromApi(p['status'] as String?) ??
            PledgeStatus.onTheWay,
        updatedAt: DateTime.parse(p['updatedAt'] as String),
      ),
  ];

  Future<BloodRequestModel> confirmDonation(int id, int donorId) async =>
      BloodRequestModel.fromJson(
        await api.post('/requests/$id/pledges/$donorId/confirm'),
      );

  Future<BloodRequestModel> pledge(int id) async =>
      BloodRequestModel.fromJson(await api.post('/requests/$id/pledge'));

  Future<BloodRequestModel> setPledge(int id, PledgeStatus status) async =>
      BloodRequestModel.fromJson(
        await api.patch('/requests/$id/pledge', body: {'status': status.api}),
      );

  static List<BloodRequestModel> parseList(Json body) => [
    for (final item in body['items'] as List<dynamic>)
      BloodRequestModel.fromJson(item as Json),
  ];
}
