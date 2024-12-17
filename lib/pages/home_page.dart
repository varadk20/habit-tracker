import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/util/habit_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    //read existing habits on app startup
    Provider.of<HabitDatabase>(context, listen: false).readHabits();

    super.initState();
  }

  //text controller
  final TextEditingController textController = TextEditingController();

  //create new habit
  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Input Habit',
          ),
        ),
        actions: [
          //save button
          MaterialButton(
            onPressed: () {
              //get new habit
              String newHabitName = textController.text;

              //save to db
              context.read<HabitDatabase>().addHabit(newHabitName);

              //pop box
              Navigator.pop(context);

              //clear controller
              textController.clear();
            },
            child: const Text('Save'),
          ),

          //cancel button
          MaterialButton(
            onPressed: () {
              //pop bx
              Navigator.pop(context);

              //clear controller
              textController.clear();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // check habit on and off
  void checkHabitOnOff(bool? value, Habit habit) {
    //update habit completion status
    if (value != null) {
      context.read<HabitDatabase>().updatedHabitCompletion(habit.id, value);
    }
  }

  //edit habit box
  void editHabitBox(Habit habit) {
    //set controller text to habit's current name
    textController.text = habit.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          //save button
          MaterialButton(
            onPressed: () {
              //get new habit name
              String newHabitName = textController.text;

              //save to db
              context
                  .read<HabitDatabase>()
                  .updateHabitName(habit.id, newHabitName);

              //pop box
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),

          //cancel button
          MaterialButton(
            onPressed: () {
              //pop bx
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  //delete habit box
  void deleteHabitBox(Habit habit) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Do you want to delete?'),
              actions: [
                //delete button
                MaterialButton(
                  onPressed: () {
                    //save to db
                    context.read<HabitDatabase>().deleteHabit(habit.id);

                    //pop box
                    Navigator.pop(context);

                    //clear controller
                    textController.clear();
                  },
                  child: const Text('Delete'),
                ),

                //cancel button
                MaterialButton(
                  onPressed: () {
                    //pop bx
                    Navigator.pop(context);

                    //clear controller
                    textController.clear();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        child: const Icon(
          Icons.add,
        ),
      ),
      body: ListView(
        children: [
          //heatmap
          _buildHeatMap(),

          //habit list
          _buildHabitList(),
        ],
      ),
    );
  }

  //build heat map
  Widget _buildHeatMap() {
    final habitDatabase = context.watch<HabitDatabase>();

    //current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    // return heatmap
    return FutureBuilder<DateTime?>(
      future: habitDatabase.getFirstLaunchDate(),
      builder: (context, snapshot) {
        //when data available buld heat mat
        if (snapshot.hasData) {
          return MyHeatMap(
            startDate: snapshot.data!,
            datasets: prepHeatMapDataset(currentHabits),
          );
        }

        //handle when no data returned
        else {
          return Container();
        }
      },
    );
  }

  //build habit list
  Widget _buildHabitList() {
    //habit db
    final habitDatabase = context.watch<HabitDatabase>();

    //current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    //return list of habits UI
    return ListView.builder(
        itemCount: currentHabits.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        
        itemBuilder: (context, index) {
          //get individual habit
          final habit = currentHabits[index];

          //check if habit completed today
          bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

          // return habit tile UI
          return MyHabitTile(
            isCompleted: isCompletedToday,
            text: habit.name,
            onChanged: (value) => checkHabitOnOff(value, habit),
            editHabit: (context) => editHabitBox(habit),
            deleteHabit: (context) => deleteHabitBox(habit),
          );
        });
  }
}
