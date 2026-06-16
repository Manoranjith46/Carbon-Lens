import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carbon_lens/main.dart';

void main() {
  testWidgets('CarbonLens app starts and shows splash', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CarbonLensApp(),
      ),
    );

    // Verify the splash screen shows
    expect(find.text('CarbonLens'), findsOneWidget);
    expect(find.text('See the impact behind your day.'), findsOneWidget);
  });
}
