import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:your_budget_manager/core/security/pin_service.dart';
import 'package:your_budget_manager/core/security/secure_key_storage.dart';

@GenerateMocks([SecureKeyStorage])
import 'pin_service_test.mocks.dart';

void main() {
  late PinService pinService;
  late MockSecureKeyStorage mockStorage;
  final Map<String, String> fakeStorage = {};

  setUp(() {
    mockStorage = MockSecureKeyStorage();
    pinService = PinService(mockStorage);
    fakeStorage.clear();

    when(mockStorage.saveKey(any, any)).thenAnswer((invocation) async {
      final key = invocation.positionalArguments[0] as String;
      final value = invocation.positionalArguments[1] as String;
      fakeStorage[key] = value;
    });

    when(mockStorage.getKey(any)).thenAnswer((invocation) async {
      final key = invocation.positionalArguments[0] as String;
      return fakeStorage[key];
    });
    
    when(mockStorage.deleteKey(any)).thenAnswer((invocation) async {
      final key = invocation.positionalArguments[0] as String;
      fakeStorage.remove(key);
    });
  });

  test('hasPin returns false initially', () async {
    expect(await pinService.hasPin(), isFalse);
  });

  test('setPin and verifyPin', () async {
    await pinService.setPin('1234');
    expect(await pinService.hasPin(), isTrue);

    expect(await pinService.verifyPin('1234'), isTrue);
    expect(await pinService.verifyPin('4321'), isFalse);
  });

  test('removePin', () async {
    await pinService.setPin('1234');
    expect(await pinService.hasPin(), isTrue);

    await pinService.removePin();
    expect(await pinService.hasPin(), isFalse);
    expect(await pinService.verifyPin('1234'), isFalse);
  });
}
