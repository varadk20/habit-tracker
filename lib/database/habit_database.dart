import 'package:flutter/material.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  //initialize db
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingsSchema],
      directory: dir.path,
    );
  }

  //save first date of app Startup(for heatmap)
  static Future<void> saveFirstLaunchDate() async {
    final exisstingSettings = await isar.appSettings.where().findFirst();

    if (exisstingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  //get first date of app startup( for heatmap )
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  // C R U D

  //list of habits
  final List<Habit> currentHabits = [];

  // create - to add new habit
  Future<void> addHabit(String habitName) async {
    //create new
    final newHabit = Habit()..name = habitName;

    //save to db
    await isar.writeTxn(() => isar.habits.put(newHabit));

    //re-read from db
    readHabits();
  }

  // read saved habits from db
  Future<void> readHabits() async {
    //fetch all habits from db
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    //give to current habits
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);

    //update UI
    notifyListeners();
  }

  // Update - check habit on and off
  Future<void> updatedHabitCompletion(int id, bool isCompleted) async {
    //find specific habit
    final habit = await isar.habits.get(id);

    //update completion status
    if (habit != null) {
      await isar.writeTxn(() async {
        //if habit completed-> add current date to completedDays List
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
          //today
          final today = DateTime.now();

          //add current date if not already in list
          habit.completedDays.add(DateTime(
            today.year,
            today.month,
            today.day,
          ));
        }

        //not completed remove current date from list
        else {
          //remove current date if habit marked as not complete
          habit.completedDays.removeWhere(
            (date) =>
                date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day,
          );
        }
        //save updated habits back to database
        await isar.habits.put(habit);
      });
    }
    //re-read from db
    readHabits();
  }

  //Update -> edit habit name
  Future<void> updateHabitName(int id, String newName) async {
    //find specific habit
    final habit = await isar.habits.get(id);

    //update habit name
    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = newName;

        //save updated habit to db
        await isar.habits.put(habit);
      });
    }
    //reread
    readHabits();
  }

  //Delete -> delete habit
  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });

    readHabits();
  }
}
