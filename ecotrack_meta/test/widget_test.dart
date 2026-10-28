import 'package:ecotrack_meta/datos/memoria_consumo_repository.dart';
import 'package:ecotrack_meta/variantes/b_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EcoTrack Meta smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      AppProvider(repositorio: MemoriaConsumoRepository()),
    );
    await tester.pumpAndSettle();
    expect(find.text('B · provider'), findsOneWidget);
  });
}
