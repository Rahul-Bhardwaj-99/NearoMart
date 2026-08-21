import 'package:flutter_test/flutter_test.dart';
import 'package:nearomart/app/routes/arguments/arguments.dart';

void main() {
  group('OrderArguments', () {
    test('fromId creates arguments with orderId', () {
      final args = OrderArguments.fromId('order-123');
      expect(args.orderId, 'order-123');
      expect(args.orderData, isNull);
    });

    test('fromData extracts orderId from _id', () {
      final args = OrderArguments.fromData({'_id': 'order-456', 'total': 100});
      expect(args.orderId, 'order-456');
      expect(args.orderData, isNotNull);
    });

    test('fromGetArguments handles OrderArguments instance', () {
      final original = OrderArguments.fromId('order-789');
      final args = OrderArguments.fromGetArguments(original);
      expect(args, same(original));
    });

    test('fromGetArguments handles String', () {
      final args = OrderArguments.fromGetArguments('order-abc');
      expect(args?.orderId, 'order-abc');
    });

    test('fromGetArguments handles Map', () {
      final args = OrderArguments.fromGetArguments({'_id': 'order-map'});
      expect(args?.orderId, 'order-map');
    });

    test('fromGetArguments returns null for invalid args', () {
      expect(OrderArguments.fromGetArguments(123), isNull);
      expect(OrderArguments.fromGetArguments(null), isNull);
    });

    test('toMap round-trips', () {
      final args = OrderArguments.fromId('order-xyz');
      final map = args.toMap();
      final restored = OrderArguments.fromGetArguments(map);
      expect(restored?.orderId, 'order-xyz');
    });
  });

  group('ChatArguments', () {
    test('fromData extracts chatId and related ids', () {
      final args = ChatArguments.fromData({
        '_id': 'chat-1',
        'profileId': 'profile-1',
        'orderId': 'order-1',
      });
      expect(args.chatId, 'chat-1');
      expect(args.profileId, 'profile-1');
      expect(args.orderId, 'order-1');
    });

    test('fromGetArguments handles String', () {
      final args = ChatArguments.fromGetArguments('chat-2');
      expect(args?.chatId, 'chat-2');
    });

    test('fromGetArguments returns null for invalid args', () {
      expect(ChatArguments.fromGetArguments(42), isNull);
    });
  });

  group('ShopArguments', () {
    test('fromData extracts shopId from _id or id', () {
      final args1 = ShopArguments.fromData({'_id': 'shop-1'});
      expect(args1.shopId, 'shop-1');
      final args2 = ShopArguments.fromData({'id': 'shop-2'});
      expect(args2.shopId, 'shop-2');
    });

    test('fromGetArguments handles String', () {
      final args = ShopArguments.fromGetArguments('shop-3');
      expect(args?.shopId, 'shop-3');
    });
  });

  group('AddressArguments', () {
    test('fromData extracts addressId', () {
      final args = AddressArguments.fromData({'_id': 'addr-1'});
      expect(args.addressId, 'addr-1');
      expect(args.isEditing, isFalse);
    });

    test('fromData with isEditing true', () {
      final args = AddressArguments.fromData({'_id': 'addr-2'}, isEditing: true);
      expect(args.isEditing, isTrue);
    });

    test('fromGetArguments handles String', () {
      final args = AddressArguments.fromGetArguments('addr-3');
      expect(args?.addressId, 'addr-3');
    });
  });

  group('ProductArguments', () {
    test('fromData extracts productId', () {
      final args = ProductArguments.fromData({'_id': 'prod-1'});
      expect(args.productId, 'prod-1');
    });

    test('fromGetArguments handles String', () {
      final args = ProductArguments.fromGetArguments('prod-2');
      expect(args?.productId, 'prod-2');
    });
  });

  group('EditProfileArguments', () {
    test('fromUserData extracts fields', () {
      final args = EditProfileArguments.fromUserData({
        'name': 'John',
        'phone': '123',
        'email': 'john@test.com',
        'profilePic': 'pic-url',
      });
      expect(args.name, 'John');
      expect(args.phone, '123');
      expect(args.email, 'john@test.com');
      expect(args.profilePic, 'pic-url');
    });

    test('fromGetArguments handles Map', () {
      final args = EditProfileArguments.fromGetArguments({'name': 'Jane'});
      expect(args?.name, 'Jane');
    });
  });

  group('RiderOrderArguments', () {
    test('fromId creates arguments with orderId', () {
      final args = RiderOrderArguments.fromId('rider-order-1');
      expect(args.orderId, 'rider-order-1');
    });

    test('fromData extracts orderId from _id', () {
      final args = RiderOrderArguments.fromData({'_id': 'rider-order-2'});
      expect(args.orderId, 'rider-order-2');
    });

    test('fromGetArguments handles String', () {
      final args = RiderOrderArguments.fromGetArguments('rider-order-3');
      expect(args?.orderId, 'rider-order-3');
    });

    test('fromGetArguments handles Map', () {
      final args = RiderOrderArguments.fromGetArguments({'_id': 'rider-order-4'});
      expect(args?.orderId, 'rider-order-4');
    });

    test('fromGetArguments returns null for invalid args', () {
      expect(RiderOrderArguments.fromGetArguments(99), isNull);
      expect(RiderOrderArguments.fromGetArguments(null), isNull);
    });
  });
}