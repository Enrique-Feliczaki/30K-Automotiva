import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/benefit_strip.dart';

void main() {
  testWidgets('Benefits remain side by side on a small phone with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: const Scaffold(
            body: Padding(padding: EdgeInsets.all(18), child: BenefitStrip()),
          ),
        ),
      ),
    );
    final shipping = tester.getCenter(
      find.byIcon(Icons.local_shipping_outlined),
    );
    final original = tester.getCenter(find.byIcon(Icons.verified_outlined));
    final support = tester.getCenter(find.byIcon(Icons.support_agent));
    expect(shipping.dy, original.dy);
    expect(original.dy, support.dy);
    expect(shipping.dx, lessThan(original.dx));
    expect(original.dx, lessThan(support.dx));
    expect(tester.takeException(), isNull);
  });
}
