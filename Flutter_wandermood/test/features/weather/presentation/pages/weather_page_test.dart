import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wandermood/features/weather/application/weather_service.dart';
import 'package:wandermood/features/weather/domain/models/weather_data.dart';
import 'package:wandermood/features/weather/presentation/pages/weather_page.dart';

class MockWeatherService extends Mock implements WeatherService {}

void main() {
  late MockWeatherService mockWeatherService;

  setUp(() {
    mockWeatherService = MockWeatherService();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        weatherServiceProvider.overrideWithValue(mockWeatherService),
      ],
      child: const MaterialApp(
        home: WeatherPage(),
      ),
    );
  }

  testWidgets('toont laadindicator tijdens het laden', (tester) async {
    when(() => mockWeatherService.state).thenReturn(
      const AsyncLoading(),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('toont foutmelding bij fout', (tester) async {
    when(() => mockWeatherService.state).thenReturn(
      const AsyncError('Test fout'),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Fout bij het laden van weergegevens: Test fout'), findsOneWidget);
  });

  testWidgets('toont weerkaart en grafiek bij succesvol laden', (tester) async {
    final currentWeather = WeatherData(
      temperature: 20,
      conditions: 'Zonnig',
      humidity: 65,
      windSpeed: 5,
      precipitation: 0,
      timestamp: DateTime.now(),
    );

    final historicalWeather = [
      currentWeather,
      currentWeather.copyWith(
        temperature: 22,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    when(() => mockWeatherService.state).thenReturn(
      AsyncData((currentWeather, historicalWeather)),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(WeatherCard), findsOneWidget);
    expect(find.byType(WeatherHistoryChart), findsOneWidget);
    expect(find.text('Historisch Weer'), findsOneWidget);
  });

  testWidgets('ververst weergegevens bij tap op refresh knop', (tester) async {
    final currentWeather = WeatherData(
      temperature: 20,
      conditions: 'Zonnig',
      humidity: 65,
      windSpeed: 5,
      precipitation: 0,
      timestamp: DateTime.now(),
    );

    final historicalWeather = [currentWeather];

    when(() => mockWeatherService.state).thenReturn(
      AsyncData((currentWeather, historicalWeather)),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    verify(() => mockWeatherService.refreshWeather()).called(1);
  });
} 