import 'package:hive/hive.dart';

Future<void> main() async {
  Hive.init('test');

  final hiveManager = HiveManager();

  final doStuff1 = DoStuffWithHive1(hiveManager);
  final doStuff2 = DoStuffWithHive2(hiveManager);

  final future1 = doStuff1.start();
  final future2 = doStuff2.start();

  print('App started!');

  await Future.wait([ future1, future2 ]);

  print('Stuff done!');
}


class DoStuffWithHive1 {

  DoStuffWithHive1(this.hiveManager);

  final HiveManager hiveManager;


  Future<void> start() async {
    try {
      final valuesFuture = hiveManager.observeValue()
          .take(5)
          .timeout(const Duration(seconds: 5))
          .toList();

      await hiveManager.changeValue("manager1-value1");
      await hiveManager.changeValue("manager1-value2");
      await hiveManager.changeValue("manager1-value3");
      await hiveManager.changeValue("manager1-value4");
      await hiveManager.changeValue("manager1-value5");

      final values = await valuesFuture;
      print('manager1 got ($values)');
    } catch (e) {
      print('manager1 error ($e)');
    }
  }

}


class DoStuffWithHive2 {

  DoStuffWithHive2(this.hiveManager);

  final HiveManager hiveManager;


  Future<void> start() async {
    try {
      final valuesFuture = hiveManager.observeValue()
          .take(5)
          .timeout(const Duration(seconds: 5))
          .toList();

      await hiveManager.changeValue("manager2-value1");
      await hiveManager.changeValue("manager2-value2");
      await hiveManager.changeValue("manager2-value3");
      await hiveManager.changeValue("manager2-value4");
      await hiveManager.changeValue("manager2-value5");

      final values = await valuesFuture;
      print('manager2 got ($values)');
    } catch (e) {
      print('manager2 error ($e)');
    }
  }

}


class HiveManager {

  static const String valueKey = 'key';

  Stream<String> observeValue() async* {
    final box = await Hive.openBox<String>('the_box');
    print('box[${box.hashCode}]');

    yield box.get(valueKey);
    await for(BoxEvent event in box.watch(key: valueKey)) {
      yield event.value;
    }
  }

  Future<void> changeValue(String value) async {
    final box = await Hive.openBox<String>('the_box');
    print('box[${box.hashCode}]');

    await box.put(valueKey, value);
  }

}