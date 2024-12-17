import 'package:isar/isar.dart';

//run cmd to generate file: dart run build_runner build
part 'habit.g.dart';

@Collection()
class Habit{
  //habit Id
  Id id = Isar.autoIncrement;

  //habit name
  late String name; //late as initialized later on
  
  //completed days
  List<DateTime> completedDays = [
    //DateTime(year, month, day)

  ];


}