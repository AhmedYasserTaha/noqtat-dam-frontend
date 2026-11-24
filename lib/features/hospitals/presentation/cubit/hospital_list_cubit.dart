import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/hospital.dart';
import '../../domain/usecases/get_hospitals.dart';

enum HospitalListStatus { idle, loading, loaded, failure }

class HospitalListState extends Equatable {
  const HospitalListState({
    this.status = HospitalListStatus.idle,
    this.hospitals = const [],
  });
  final HospitalListStatus status;
  final List<Hospital> hospitals;
  @override
  List<Object?> get props => [status, hospitals];
}

/// Loads the reviewed hospital directory for one governorate. A failure or an
/// empty directory is not an error for the user: the form falls back to typing
/// the hospital name.
class HospitalListCubit extends Cubit<HospitalListState> {
  HospitalListCubit(this._get) : super(const HospitalListState());
  final GetHospitals _get;
  String? _governorateId;

  Future<void> load(String? governorateId) async {
    _governorateId = governorateId;
    if (governorateId == null) {
      emit(const HospitalListState());
      return;
    }
    emit(const HospitalListState(status: HospitalListStatus.loading));
    final result = await _get(governorateId);
    if (isClosed || _governorateId != governorateId) return;
    result.fold(
      (_) => emit(const HospitalListState(status: HospitalListStatus.failure)),
      (list) => emit(
        HospitalListState(status: HospitalListStatus.loaded, hospitals: list),
      ),
    );
  }
}
