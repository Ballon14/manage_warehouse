import 'package:flutter_test/flutter_test.dart';
import 'package:manage_your_logistic/repositories/item_repository.dart';
import '../helpers/mock_item_repository.dart';
import '../helpers/mock_data.dart';

void main() {
  group('ItemRepository', () {
    late ItemRepository repository;

    setUp(() {
      repository = MockItemRepository();
    });

    tearDown(() {
      if (repository is MockItemRepository) {
        (repository as MockItemRepository).clear();
      }
    });

    group('getAll', () {
      test('should return empty list initially', () async {
        final stream = repository.getAll();
        final items = await stream.first;
        
        expect(items, isEmpty);
      });

      test('should return all items', () async {
        final mockRepo = repository as MockItemRepository;
        mockRepo.addItem(MockData.testItem1);
        mockRepo.addItem(MockData.testItem2);

        final stream = repository.getAll();
        final items = await stream.first;

        expect(items.length, 2);
        expect(items[0].id, MockData.testItem1.id);
        expect(items[1].id, MockData.testItem2.id);
      });
    });

    group('getById', () {
      test('should return null when item not found', () async {
        final item = await repository.getById('non-existent');
        
        expect(item, isNull);
      });

      test('should return item when found', () async {
        await repository.create(MockData.testItem1);
        final item = await repository.getById(MockData.testItem1.id);

        expect(item, isNotNull);
        expect(item!.id, MockData.testItem1.id);
        expect(item.name, MockData.testItem1.name);
      });
    });

    group('create', () {
      test('should add new item', () async {
        await repository.create(MockData.testItem1);
        
        final item = await repository.getById(MockData.testItem1.id);
        expect(item, isNotNull);
        expect(item!.name, MockData.testItem1.name);
      });

      test('should increment item count', () async {
        await repository.create(MockData.testItem1);
        await repository.create(MockData.testItem2);

        final mockRepo = repository as MockItemRepository;
        expect(mockRepo.itemCount, 2);
      });
    });

    group('update', () {
      test('should update existing item', () async {
        await repository.create(MockData.testItem1);
        
        final updatedItem = MockData.testItem1.copyWith(
          name: 'Updated Name',
        );
        await repository.update(updatedItem);

        final item = await repository.getById(MockData.testItem1.id);
        expect(item!.name, 'Updated Name');
      });

      test('should not affect other items', () async {
        await repository.create(MockData.testItem1);
        await repository.create(MockData.testItem2);

        final updatedItem = MockData.testItem1.copyWith(
          name: 'Updated Name',
        );
        await repository.update(updatedItem);

        final item2 = await repository.getById(MockData.testItem2.id);
        expect(item2!.name, MockData.testItem2.name);
      });
    });

    group('delete', () {
      test('should remove item', () async {
        await repository.create(MockData.testItem1);
        await repository.delete(MockData.testItem1.id);

        final item = await repository.getById(MockData.testItem1.id);
        expect(item, isNull);
      });

      test('should decrease item count', () async {
        await repository.create(MockData.testItem1);
        await repository.create(MockData.testItem2);
        await repository.delete(MockData.testItem1.id);

        final mockRepo = repository as MockItemRepository;
        expect(mockRepo.itemCount, 1);
      });
    });

    group('search', () {
      setUp(() async {
        await repository.create(MockData.testItem1);
        await repository.create(MockData.testItem2);
      });

      test('should find items by name', () async {
        final results = await repository.search('Test Item 1');
        
        expect(results.length, 1);
        expect(results.first.name, MockData.testItem1.name);
      });

      test('should find items by SKU', () async {
        final results = await repository.search('SKU-002');
        
        expect(results.length, 1);
        expect(results.first.sku, MockData.testItem2.sku);
      });

      test('should be case insensitive', () async {
        final results = await repository.search('test item');
        
        expect(results.length, 2);
      });

      test('should return empty list when no match', () async {
        final results = await repository.search('non-existent');
        
        expect(results, isEmpty);
      });
    });

    group('getByBarcode', () {
      test('should return null when barcode not found', () async {
        final item = await repository.getByBarcode('non-existent');
        
        expect(item, isNull);
      });

      test('should return item when barcode found', () async {
        await repository.create(MockData.testItem1);
        final item = await repository.getByBarcode(MockData.testItem1.barcode!);

        expect(item, isNotNull);
        expect(item!.id, MockData.testItem1.id);
      });
    });

    group('getBySku', () {
      test('should return null when SKU not found', () async {
        final item = await repository.getBySku('non-existent');
        
        expect(item, isNull);
      });

      test('should return item when SKU found', () async {
        await repository.create(MockData.testItem1);
        final item = await repository.getBySku(MockData.testItem1.sku);

        expect(item, isNotNull);
        expect(item!.id, MockData.testItem1.id);
      });
    });

    group('skuExists', () {
      test('should return false when SKU does not exist', () async {
        final exists = await repository.skuExists('non-existent');
        
        expect(exists, false);
      });

      test('should return true when SKU exists', () async {
        await repository.create(MockData.testItem1);
        final exists = await repository.skuExists(MockData.testItem1.sku);

        expect(exists, true);
      });
    });

    group('barcodeExists', () {
      test('should return false when barcode does not exist', () async {
        final exists = await repository.barcodeExists('non-existent');
        
        expect(exists, false);
      });

      test('should return true when barcode exists', () async {
        await repository.create(MockData.testItem1);
        final exists = await repository.barcodeExists(MockData.testItem1.barcode!);

        expect(exists, true);
      });
    });
  });
}
