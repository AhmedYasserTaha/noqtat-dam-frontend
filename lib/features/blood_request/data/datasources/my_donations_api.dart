import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../home_feed/domain/entities/home_data.dart' show PagedList;
import '../../domain/entities/blood_request.dart';
import '../models/blood_request_model.dart';

class MyDonation {
  const MyDonation({
    required this.request,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  final BloodRequest request;
  final PledgeStatus status;
  final DateTime createdAt, updatedAt;
  bool get closed =>
      request.status != RequestStatus.open ||
      (request.deadline?.isBefore(DateTime.now()) ?? false);
  String? get contactPhone =>
      status == PledgeStatus.cancelled ? null : request.contactPhone;
}

class MyDonationsApi {
  const MyDonationsApi(this.api);
  final ApiClient api;

  Future<PagedList<MyDonation>> list({
    PledgeStatus? status,
    String? cursor,
  }) async {
    final json = await api.get(
      ApiConstants.myPledges,
      query: {'status': status?.api ?? 'all', 'limit': 20, 'cursor': cursor},
    );
    return PagedList([
      for (final item in json['items'] as List)
        MyDonation(
          request: BloodRequestModel.fromJson(item['request'] as Json),
          status:
              PledgeStatus.fromApi(item['status'] as String?) ??
              (throw const ApiException(UnexpectedFailure())),
          createdAt: DateTime.parse(item['createdAt'] as String),
          updatedAt: DateTime.parse(item['updatedAt'] as String),
        ),
    ], json['hasMore'] == true ? json['nextCursor'] as String? : null);
  }

  Future<void> update(int requestId, PledgeStatus status) async {
    await api.patch(
      ApiConstants.requestPledge(requestId),
      body: {'status': status.api},
    );
  }
}
