import 'package:flutter/material.dart';
import 'package:tejory/ui/login.dart';
import 'package:tejory/ui/setup/page_animation.dart';
import 'package:tejory/updates/cpk_calculation.dart';
import 'package:tejory/updates/db_migration.dart';
import 'package:tejory/updates/update.dart';
import 'package:tejory/updates/update_assets.dart';

class UpdateUI extends StatefulWidget {
  // Add a list of active updates
  final List<Update> activeUpdates = [
    DBMigration(),
    CPKCalculation(),
    UpdateAssets(),
  ];

  UpdateUI();

  @override
  State<StatefulWidget> createState() => _UpdateUIState();
}

class _UpdateUIState extends State<UpdateUI> {
  final Map<UpdateStatus, IconData> statusIconMap = {
    UpdateStatus.pending: Icons.schedule,
    UpdateStatus.working: Icons.pending_outlined,
    UpdateStatus.successful: Icons.check_circle_outline,
    UpdateStatus.error: Icons.error_outline,
  };

  late Map<UpdateStatus, Color> statusIconColorMap;
  late Map<UpdateStatus, Color> statusTextColorMap;
  int updateIndex = 0;
  late Future<void> updatesReady;
  List<Update> updates = [];

  @override
  void initState() {
    super.initState();

    updatesReady = getRequiredUpdates();
    updatesReady.then((_) {
      startUpdates();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    statusIconColorMap = {
      UpdateStatus.pending: Theme.of(context).colorScheme.tertiary,
      UpdateStatus.working: Theme.of(context).colorScheme.primary,
      UpdateStatus.successful: Colors.green,
      UpdateStatus.error: Colors.red,
    };

    statusTextColorMap = {
      UpdateStatus.pending: Theme.of(context).colorScheme.tertiary,
      UpdateStatus.working: Theme.of(context).colorScheme.primary,
      UpdateStatus.successful: Theme.of(context).colorScheme.primary,
      UpdateStatus.error: Theme.of(context).colorScheme.primary,
    };
  }

  Future<void> getRequiredUpdates() async {
    for (int i = 0; i < widget.activeUpdates.length; i++) {
      print("${widget.activeUpdates[i].name()}: Update checking");
      if (await widget.activeUpdates[i].required()) {
        print("${widget.activeUpdates[i].name()}: Update required");
        setState(() {
          updates.add(widget.activeUpdates[i]);
        });
      } else {
        print("${widget.activeUpdates[i].name()}: Update not required");
      }
    }
  }

  Future<void> startUpdates() async {
    for (int i = 0; i < updates.length; i++) {
      setState(() {
        updateIndex = i;
      });
      await updates[i].start();
      await updates[i].done();
    }

    FadeNavigator(
      context,
    ).navigateToReplace(Login(), customName: Navigator.defaultRouteName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(right: 8.0, left: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            Text("Updating", style: TextStyle(fontSize: 24)),
            FutureBuilder(
              future: updatesReady,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Row(
                    spacing: 8,
                    children: [
                      Icon(
                        statusIconMap[UpdateStatus.working],
                        color: statusIconColorMap[UpdateStatus.working],
                      ),
                      Text(
                        "Building updates list",
                        style: TextStyle(
                          fontFamily: "monospace",
                          fontSize: 12,
                          color: statusTextColorMap[UpdateStatus.working],
                        ),
                      ),
                    ],
                  );
                }
                return _updateList();
              },
            ),
            FutureBuilder(
              future: updatesReady,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done || updates.isEmpty) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Initializing..."),
                      LinearProgressIndicator(),
                    ],
                  );
                }
                return _progressBar();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _updateList() {
    return Column(
      children:
          updates.map((Update update) => _updateListItem(update)).toList(),
    );
  }

  Widget _updateListItem(Update update) {
    final status = update.getStatus();
    return Row(
      spacing: 8,
      children: [
        Icon(statusIconMap[status], color: statusIconColorMap[status]),
        Text(
          update.name(),
          style: TextStyle(
            fontFamily: "monospace",
            fontSize: 12,
            color: statusTextColorMap[status],
          ),
        ),
      ],
    );
  }

  Widget _progressBar() {
    return StreamBuilder(
      stream: updates[updateIndex].getProgressStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active ||
            snapshot.data == null) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text("Initializing..."), LinearProgressIndicator()],
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(snapshot.data!.message),
            LinearProgressIndicator(value: snapshot.data!.progress),
          ],
        );
      },
    );
  }
}
