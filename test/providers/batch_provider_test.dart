// ============================================================================
// Tests for BatchProvider
// ============================================================================
import 'package:batchit/models/batch.dart';
import 'package:batchit/providers/batch_provider.dart';
import 'package:batchit/services/api_client.dart';
import 'package:batchit/services/batch_service.dart';
import 'package:batchit/services/provider_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBatchService extends Mock implements BatchService {}
class MockProviderService extends Mock implements ProviderService {}

Batch makeBatch({
  String id = 'b1',
  String productName = 'Rice',
  double bulkSizeKg = 100,
  double currentQuantityKg = 50,
  String status = 'open',
  String? providerId,
}) =>
    Batch(
      id: id,
      productName: productName,
      bulkSizeKg: bulkSizeKg,
      currentQuantityKg: currentQuantityKg,
      locationName: 'Mokolo',
      hubName: 'Hub A',
      status: status,
      providerId: providerId,
    );

void main() {
  late MockBatchService mockBatchService;
  late MockProviderService mockProviderService;
  late BatchProvider provider;

  setUp(() {
    mockBatchService = MockBatchService();
    mockProviderService = MockProviderService();
    provider = BatchProvider(mockBatchService, mockProviderService);
  });

  group('initial state', () {
    test('batches is empty', () => expect(provider.batches, isEmpty));
    test('myCreatedBatches is empty', () => expect(provider.myCreatedBatches, isEmpty));
    test('myJoinedBatches is empty', () => expect(provider.myJoinedBatches, isEmpty));
    test('isLoading is false', () => expect(provider.isLoading, false));
  });

  group('loadNearbyBatches', () {
    test('merges open and filled batches', () async {
      when(() => mockBatchService.fetchNearbyBatches(status: 'open'))
          .thenAnswer((_) async => [makeBatch(id: 'b1'), makeBatch(id: 'b2')]);
      when(() => mockBatchService.fetchNearbyBatches(status: 'filled'))
          .thenAnswer((_) async => [makeBatch(id: 'b3', status: 'filled')]);

      await provider.loadNearbyBatches();

      expect(provider.batches.length, 3);
      expect(provider.isLoading, false);
    });

    test('deduplicates batches that appear in both responses', () async {
      final shared = makeBatch(id: 'shared');
      when(() => mockBatchService.fetchNearbyBatches(status: 'open'))
          .thenAnswer((_) async => [shared]);
      when(() => mockBatchService.fetchNearbyBatches(status: 'filled'))
          .thenAnswer((_) async => [shared]);

      await provider.loadNearbyBatches();

      expect(provider.batches.length, 1);
    });

    test('sets isLoading true then false around the fetch', () async {
      final loadingStates = <bool>[];
      provider.addListener(() => loadingStates.add(provider.isLoading));

      when(() => mockBatchService.fetchNearbyBatches(status: 'open'))
          .thenAnswer((_) async => []);
      when(() => mockBatchService.fetchNearbyBatches(status: 'filled'))
          .thenAnswer((_) async => []);

      await provider.loadNearbyBatches();

      expect(loadingStates, containsAllInOrder([true, false]));
    });

    test('forwards latitude, longitude and radiusKm to the service', () async {
      when(() => mockBatchService.fetchNearbyBatches(
            status: 'open',
            latitude: 3.8,
            longitude: 11.5,
            radiusKm: 25.0,
          )).thenAnswer((_) async => [makeBatch(id: 'near1')]);
      when(() => mockBatchService.fetchNearbyBatches(
            status: 'filled',
            latitude: 3.8,
            longitude: 11.5,
            radiusKm: 25.0,
          )).thenAnswer((_) async => []);

      await provider.loadNearbyBatches(
        latitude: 3.8,
        longitude: 11.5,
        radiusKm: 25.0,
      );

      verify(() => mockBatchService.fetchNearbyBatches(
            status: 'open',
            latitude: 3.8,
            longitude: 11.5,
            radiusKm: 25.0,
          )).called(1);
      expect(provider.batches.length, 1);
      expect(provider.batches.first.id, 'near1');
    });

    test('omits location params when called without arguments', () async {
      when(() => mockBatchService.fetchNearbyBatches(status: 'open'))
          .thenAnswer((_) async => [makeBatch(id: 'any')]);
      when(() => mockBatchService.fetchNearbyBatches(status: 'filled'))
          .thenAnswer((_) async => []);

      await provider.loadNearbyBatches();

      verify(() => mockBatchService.fetchNearbyBatches(status: 'open')).called(1);
    });

    test('returns empty list and does not throw when service returns empty', () async {
      when(() => mockBatchService.fetchNearbyBatches(status: 'open'))
          .thenAnswer((_) async => []);
      when(() => mockBatchService.fetchNearbyBatches(status: 'filled'))
          .thenAnswer((_) async => []);

      await provider.loadNearbyBatches();

      expect(provider.batches, isEmpty);
      expect(provider.isLoading, false);
    });
  });

  group('loadMyCreatedBatches', () {
    test('populates myCreatedBatches', () async {
      when(() => mockBatchService.fetchMyCreatedBatches())
          .thenAnswer((_) async => [makeBatch(id: 'my1'), makeBatch(id: 'my2')]);

      await provider.loadMyCreatedBatches();

      expect(provider.myCreatedBatches.length, 2);
    });
  });

  group('loadMyJoinedBatches', () {
    test('populates myJoinedBatches', () async {
      when(() => mockBatchService.fetchMyJoinedBatches())
          .thenAnswer((_) async => [makeBatch(id: 'joined1')]);

      await provider.loadMyJoinedBatches();

      expect(provider.myJoinedBatches.length, 1);
    });
  });

  group('findById', () {
    test('returns null when no batches loaded', () {
      expect(provider.findById('unknown'), isNull);
    });

    test('finds batch in available list', () async {
      when(() => mockBatchService.fetchNearbyBatches(status: 'open'))
          .thenAnswer((_) async => [makeBatch(id: 'target')]);
      when(() => mockBatchService.fetchNearbyBatches(status: 'filled'))
          .thenAnswer((_) async => []);

      await provider.loadNearbyBatches();

      expect(provider.findById('target'), isNotNull);
      expect(provider.findById('target')!.id, 'target');
    });

    test('finds batch in myCreated list', () async {
      when(() => mockBatchService.fetchMyCreatedBatches())
          .thenAnswer((_) async => [makeBatch(id: 'created')]);

      await provider.loadMyCreatedBatches();

      expect(provider.findById('created'), isNotNull);
    });
  });

  group('deleteBatch', () {
    test('removes batch from all lists', () async {
      // Seed the lists
      when(() => mockBatchService.fetchNearbyBatches(status: 'open'))
          .thenAnswer((_) async => [makeBatch(id: 'del'), makeBatch(id: 'keep')]);
      when(() => mockBatchService.fetchNearbyBatches(status: 'filled'))
          .thenAnswer((_) async => []);
      await provider.loadNearbyBatches();

      when(() => mockBatchService.deleteBatch('del')).thenAnswer((_) async {});

      await provider.deleteBatch('del');

      expect(provider.batches.any((b) => b.id == 'del'), false);
      expect(provider.batches.any((b) => b.id == 'keep'), true);
    });
  });

  group('createBatch', () {
    test('prepends batch to available and created lists', () async {
      final newBatch = makeBatch(id: 'new1');
      when(
        () => mockBatchService.createBatch(
          productName: any(named: 'productName'),
          bulkSizeKg: any(named: 'bulkSizeKg'),
          location: any(named: 'location'),
          unit: any(named: 'unit'),
          providerId: any(named: 'providerId'),
          notes: any(named: 'notes'),
          image: any(named: 'image'),
        ),
      ).thenAnswer((_) async => newBatch);

      await provider.createBatch(
        productName: 'Rice',
        bulkSizeKg: 100,
        location: 'Mokolo',
      );

      expect(provider.batches.any((b) => b.id == 'new1'), true);
      expect(provider.myCreatedBatches.any((b) => b.id == 'new1'), true);
    });

    test('auto-follows provider when providerId given', () async {
      final newBatch = makeBatch(id: 'n2', providerId: 'prov-1');
      when(
        () => mockBatchService.createBatch(
          productName: any(named: 'productName'),
          bulkSizeKg: any(named: 'bulkSizeKg'),
          location: any(named: 'location'),
          unit: any(named: 'unit'),
          providerId: any(named: 'providerId'),
          notes: any(named: 'notes'),
          image: any(named: 'image'),
        ),
      ).thenAnswer((_) async => newBatch);
      when(() => mockProviderService.followProvider('prov-1'))
          .thenAnswer((_) async => true);

      await provider.createBatch(
        productName: 'Corn',
        bulkSizeKg: 50,
        location: 'Melen',
        providerId: 'prov-1',
      );

      verify(() => mockProviderService.followProvider('prov-1')).called(1);
    });
  });

  group('joinBatch', () {
    test('throws ApiException when batch is full', () async {
      final fullBatch = makeBatch(
        id: 'full',
        bulkSizeKg: 100,
        currentQuantityKg: 100,
        status: 'open',
      );
      when(() => mockBatchService.fetchBatchById('full'))
          .thenAnswer((_) async => fullBatch);

      expect(
        () => provider.joinBatch(batchId: 'full', quantityKg: 5),
        throwsA(isA<ApiException>()),
      );
    });

    test('throws ApiException when batch is closed', () async {
      final closedBatch = makeBatch(
        id: 'closed',
        status: 'filled',
        bulkSizeKg: 100,
        currentQuantityKg: 50,
      );
      when(() => mockBatchService.fetchBatchById('closed'))
          .thenAnswer((_) async => closedBatch);

      expect(
        () => provider.joinBatch(batchId: 'closed', quantityKg: 5),
        throwsA(isA<ApiException>()),
      );
    });

    test('throws ApiException when quantity exceeds remaining', () async {
      final batch = makeBatch(
        id: 'b10',
        bulkSizeKg: 100,
        currentQuantityKg: 90,
        status: 'open',
      );
      when(() => mockBatchService.fetchBatchById('b10'))
          .thenAnswer((_) async => batch);

      expect(
        () => provider.joinBatch(batchId: 'b10', quantityKg: 20), // only 10 left
        throwsA(isA<ApiException>()),
      );
    });

    test('succeeds and updates quantity optimistically', () async {
      final batch = makeBatch(
        id: 'bOk',
        bulkSizeKg: 100,
        currentQuantityKg: 50,
        status: 'open',
      );
      when(() => mockBatchService.fetchBatchById('bOk'))
          .thenAnswer((_) async => batch);
      when(() => mockBatchService.joinBatch('bOk', 10))
          .thenAnswer((_) async {});

      await provider.joinBatch(batchId: 'bOk', quantityKg: 10);

      final updated = provider.findById('bOk');
      expect(updated!.currentQuantityKg, 60);
    });
  });
}
