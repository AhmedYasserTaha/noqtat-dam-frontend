import '../../../../core/constants/api_constants.dart';
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
          ApiConstants.requests,
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
    final body = await api.get(
      ApiConstants.myRequests,
      query: {'tab': tab.api},
    );
    return parseList(body);
  }

  Future<BloodRequest> update(
    int id, {
    int? bagsCollected,
    RequestStatus? status,
    BloodRequestDraft? draft,
    BloodRequest? original,
  }) async {
    final body = {
      if (bagsCollected != null) 'bagsCollected': bagsCollected,
      if (status != null) 'status': status.name,
      if (draft != null) ...{
        'bloodType': draft.bloodType,
        'bagsNeeded': draft.bagsNeeded,
        'hospitalName': draft.hospitalName,
        if (draft.hospitalId != null) 'hospitalId': draft.hospitalId,
        'governorateId': draft.governorateId,
        'districtId': draft.districtId,
        'urgency': draft.urgency.api,
        'contactPhone': draft.contactPhone,
        'deadline': draft.deadline?.toUtc().toIso8601String(),
        'notes': draft.notes.trim(),
      },
    };
    if (original != null && draft != null) {
      final before = <String, Object?>{
        'bloodType': original.bloodType,
        'bagsNeeded': original.bagsNeeded,
        'hospitalName': original.hospitalName,
        'hospitalId': original.hospitalId,
        'governorateId': original.governorateId,
        'districtId': original.districtId,
        'urgency': original.urgency.api,
        'contactPhone': original.contactPhone,
        'deadline': original.deadline?.toUtc().toIso8601String(),
        'notes': original.notes?.trim() ?? '',
      };
      body.removeWhere(
        (key, value) => before.containsKey(key) && before[key] == value,
      );
      // A changed manual name must detach the hospital directory link. Otherwise
      // retain the ID when sending the name, as required by the backend contract.
      if (body.containsKey('hospitalName') && draft.hospitalId != null) {
        body['hospitalId'] = draft.hospitalId;
      }
      if (body.isEmpty) return original;
    }
    return BloodRequestModel.fromJson(
      await api.patch(ApiConstants.request(id), body: body),
    );
  }

  Future<List<DonorPledge>> pledges(int requestId) async => [
    for (final p in await api.getAll(ApiConstants.requestPledges(requestId)))
      DonorPledge(
        donorName: (p as Json)['donorName'] as String? ?? '',
        donorPhone: (p['donorPhone'] as String?)?.trim(),
        bloodType: p['bloodType'] as String? ?? '',
        status:
            PledgeStatus.fromApi(p['status'] as String?) ??
            PledgeStatus.onTheWay,
        updatedAt: DateTime.parse(p['updatedAt'] as String),
      ),
  ];

  Future<BloodRequestModel> pledge(int id) async => BloodRequestModel.fromJson(
    await api.post(ApiConstants.requestPledge(id)),
  );

  Future<BloodRequestModel> setPledge(int id, PledgeStatus status) async =>
      BloodRequestModel.fromJson(
        await api.patch(
          ApiConstants.requestPledge(id),
          body: {'status': status.api},
        ),
      );

  static List<BloodRequestModel> parseList(Json body) => [
    for (final item in body['items'] as List<dynamic>)
      BloodRequestModel.fromJson(item as Json),
  ];
}
