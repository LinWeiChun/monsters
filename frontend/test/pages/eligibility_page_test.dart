import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/pages/eligibility_page.dart';

void main() {
  test('uses date-only 12/13/17/18 boundaries', () {
    final today = DateTime(2026, 8, 2);
    expect(
      eligibilityAgeBand(DateTime(2013, 8, 3), today),
      EligibilityAgeBand.underage,
    );
    expect(
      eligibilityAgeBand(DateTime(2013, 8, 2), today),
      EligibilityAgeBand.minor,
    );
    expect(
      eligibilityAgeBand(DateTime(2008, 8, 3), today),
      EligibilityAgeBand.minor,
    );
    expect(
      eligibilityAgeBand(DateTime(2008, 8, 2), today),
      EligibilityAgeBand.adult,
    );
  });
}
