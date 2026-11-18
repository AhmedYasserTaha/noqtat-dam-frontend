import 'package:damy/core/utils/egypt_locations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'offline data covers 27 governors with unique linked districts',
    () async {
      final data = await EgyptLocations.load();
      expect(data.governorates, hasLength(27));
      expect(data.districts, hasLength(365));
      final ids = data.governorates.map((g) => g.id).toSet();
      expect(ids, hasLength(27));
      expect(data.districts.map((d) => d.id).toSet(), hasLength(365));
      for (final district in data.districts) {
        expect(ids, contains(district.parentId));
        expect(district.arabicName, isNotEmpty);
        expect(district.englishName, isNotEmpty);
      }
      for (final governorate in data.governorates) {
        expect(data.districtsOf(governorate.id), isNotEmpty);
      }
      expect(
        data.districtsOf('EG12').map((d) => d.arabicName),
        contains('مركز المنصورة'),
      );
      expect(
        data.districtsOf('EG01').any((d) => d.arabicName == 'مركز المنصورة'),
        isFalse,
      );
    },
  );

  test('search tolerates common Arabic spelling variants', () {
    expect(
      normalizeLocationSearch('الإسكندريّة'),
      normalizeLocationSearch('الاسكندريه'),
    );
    expect(
      normalizeLocationSearch('بنى سويف'),
      normalizeLocationSearch('بني سويف'),
    );
  });
}
