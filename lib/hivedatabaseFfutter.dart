import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

class HiveDatabaseFlutter extends StatefulWidget {
  const HiveDatabaseFlutter({super.key});

  @override
  State<HiveDatabaseFlutter> createState() => _HiveDatabaseFlutterState();
}

class _HiveDatabaseFlutterState extends State<HiveDatabaseFlutter> {
  var peopleBox = Hive.box("MyBox");
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void dispose() {
    _ageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Function for add and update operaion
  void addOrUpdaate({String? key}) {
    if (key != null) {
      final person = peopleBox.get(key);
      if (person != null) {
        _nameController.text = person['name'] ?? "";
        _ageController.text = person['age']?.toString() ?? "";
      }
    } else {
      _nameController.clear();
    }
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 15,
              right: 15,
              top: 15,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Enter the Name",
                  ),
                ),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Enter the Age",
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text;
                    final age = int.tryParse(_ageController.text);
                    // Validate the Textfield
                    if (name.isEmpty || age == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please enter valid name and age",
                          ),
                        ),
                      );
                      return;
                    }
                    if(key == null){
                      final newkey = DateTime.now().millisecondsSinceEpoch.toString();
                      peopleBox.put(
                        newkey,
                        {"name":name, "age": age});
                    }else{
                      peopleBox.put(
                        key,
                        {"name":name, "age": age});
                    }
                    Navigator.pop(context);
                  },
                  child: Text(key == null ?"Add":"Update"),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          );
        });
  }
  // For Delete Operation
 void deleteOperation(String key) {
  final deletedItem = peopleBox.get(key); // Store deleted item before deletion
  peopleBox.delete(key);

  // Show SnackBar after deletion with Undo action
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "${deletedItem?['name'] ?? 'Item'} has been deleted.",
      ),
      action: SnackBarAction(
        label: "Undo",
        onPressed: () {
          // Restore the deleted item if "Undo" is pressed
          if (deletedItem != null) {
            peopleBox.put(key, deletedItem);
          }
        },
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("Flutter Hiver Database"),
        backgroundColor: Colors.blue[100],
      ),

      body: ValueListenableBuilder(
        valueListenable: peopleBox.listenable(),
        builder: (context, box, widget){
          if(box.isEmpty){
            return const Center(
              child: Text("No items added yet."),
            );
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index){
              final key = box.keyAt(index).toString();
              final items =  box.get(key); // index
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                color: Colors.white,
                elevation: 2,
                borderRadius: BorderRadius.circular(10),
                
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(items? ["name"] ?? "Unknown"),
                    subtitle: Text("age:${items? ["age"] ?? "Unknown"}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: ()=> addOrUpdaate(key: key),
                          icon: const Icon(Icons.edit,
                        ),
                        ),

                        IconButton(
                          onPressed: ()=> deleteOperation(key),
                          icon: const Icon(Icons.delete,
                        ),
                        ),
                        
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () => addOrUpdaate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
