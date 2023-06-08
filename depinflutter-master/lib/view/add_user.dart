import 'package:depinflutter/view_model/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/user.dart';

class Adduser extends ConsumerStatefulWidget {
  const Adduser({Key? key}) : super(key: key);

  @override
  ConsumerState<Adduser> createState() => _AdduserState();
}

class _AdduserState extends ConsumerState<Adduser> {
  final idController = TextEditingController();
  final fNameController = TextEditingController();
  final lNameController = TextEditingController();
  final makrs = TextEditingController();
  final search = TextEditingController();

  List<String> modules = [
    "Flutter",
    "Web Dev",
    "IoT",
    "Design Thinking",
  ];
  String? selectedModules;

  @override
  Widget build(BuildContext context) {
    var data = ref.watch(userViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add User"),
      ),
      body: data.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16.0),
                  // ID
                  TextField(
                    controller: idController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'ID',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Fname
                  TextField(
                    controller: fNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'FName',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Lname
                  TextField(
                    controller: lNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'LName',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Dropdown
                  DropdownButtonFormField(
                    validator: (value) {
                      if (value == null) {
                        return 'Please select Module';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Modules',
                      border: OutlineInputBorder(),
                    ),
                    items: modules
                        .map(
                          (city) => DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedModules = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // Marks
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Marks',
                    ),
                    controller: makrs,
                  ),
                  const SizedBox(height: 16.0),
                  // Add User Button
                  ElevatedButton(
                    onPressed: () {
                      User user = User(
                        id: int.parse(idController.text.trim()),
                        fname: fNameController.text.trim(),
                        lname: lNameController.text.trim(),
                        moduleMarks: {
                          selectedModules!: double.parse(makrs.text.trim()),
                        },
                      );

                      // Check if user ID exists in the database
                      if (ref
                          .read(userViewModelProvider.notifier)
                          .userExists(user.id)) {
                        // Check if module exists in the database for the user
                        if (ref
                            .read(userViewModelProvider.notifier)
                            .moduleExists(user.id, selectedModules!)) {
                          // Update marks for the module
                          ref
                              .read(userViewModelProvider.notifier)
                              .updateUserMarks(user.id, selectedModules!,
                                  user.moduleMarks[selectedModules!]!);
                        } else {
                          // Add module and marks for the user
                          ref
                              .read(userViewModelProvider.notifier)
                              .addModuleAndMarks(user.id, selectedModules!,
                                  user.moduleMarks[selectedModules!]!);
                        }
                      } else {
                        // Add user to the database
                        ref.read(userViewModelProvider.notifier).addUsers(user);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added'),
                        ),
                      );
                    },
                    child: const Text('Add User'),
                  ),
                  const SizedBox(height: 8.0),

                  // Create a searchbar to search for users
                  TextField(
                    controller: search,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search',
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Create a button to search
                  ElevatedButton(
                    onPressed: () {
                      ref.read(userViewModelProvider.notifier).searchUser(
                            search.text.trim().toLowerCase(),
                          );
                    },
                    child: const Text('Search'),
                  ),
                  const SizedBox(height: 8.0),
                  (data.searchResults.length == 1)
                      ?
                      // Create a table to display searched user data
                      Column(
                          children: [
                            Text(
                              "${data.searchResults[0].fname} ${data.searchResults[0].lname} ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                              ),
                            ),
                            // Create a table to display searched user data using map
                            Table(
                              border: TableBorder.all(),
                              children: [
                                const TableRow(
                                  children: [
                                    Center(
                                      child: Text(
                                        "Module",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        "Marks",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ...data.searchResults[0].moduleMarks.entries
                                    .map(
                                      (e) => TableRow(children: [
                                        Center(child: Text(e.key)),
                                        Center(child: Text(e.value.toString())),
                                      ]),
                                    )
                                    .toList(),
                              ],
                            ),
                            Text(
                              "Total Marks: ${data.searchResults[0].moduleMarks.values.reduce(
                                (value, element) => value + element,
                              )}",
                            ),
                            Text(
                              "Result: ${data.searchResults[0].moduleMarks.length == 4 && !data.searchResults[0].moduleMarks.values.any((mark) => mark < 40) ? "Pass" : "Fail"}",
                            ),

                            Text(
                              "Percentage: ${data.searchResults[0].moduleMarks.length == 4 ? data.searchResults[0].moduleMarks.values.reduce(
                                    (value, element) => value + element,
                                  ) / data.searchResults[0].moduleMarks.length : "NA"}",
                            ),
                            Text(
                              "Division: ${data.searchResults[0].moduleMarks.length == 4 ? data.searchResults[0].moduleMarks.values.reduce(
                                    (value, element) => value + element,
                                  ) / data.searchResults[0].moduleMarks.length > 80 ? "First" : data.searchResults[0].moduleMarks.values.reduce(
                                    (value, element) => value + element,
                                  ) / data.searchResults[0].moduleMarks.length > 60 ? "Second" : data.searchResults[0].moduleMarks.values.reduce(
                                    (value, element) => value + element,
                                  ) / data.searchResults[0].moduleMarks.length > 50 ? "Third" : data.searchResults[0].moduleMarks.values.reduce(
                                    (value, element) => value + element,
                                  ) / data.searchResults[0].moduleMarks.length > 40 ? "Fourth" : "Fail" : "NA"}",
                            ),

                            const SizedBox(height: 20.0),
                          ],
                        )
                      : const Text("No user found"),
                ],
              ),
            ),
    );
  }
}
