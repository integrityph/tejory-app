import 'package:flutter/material.dart';
import 'package:tejory/objectbox/objectbox.dart';
import 'package:tejory/singleton.dart';
import 'package:tejory/ui/login.dart';
import 'package:tejory/ui/setup/page_animation.dart';
import 'package:tejory/updates/update.dart';

class UpdateUI extends StatefulWidget {
  final List<Update> updates;

  UpdateUI(this.updates);

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

  @override
  void initState() {
    super.initState();

    startUpdates();
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

  Future<void> startUpdates() async {
    for (int i=0; i<widget.updates.length; i++)
    {
      setState(() {
        updateIndex = i;
      });
      await widget.updates[i].start();
      await widget.updates[i].done();
    }

    FadeNavigator(context).navigateToReplace(Login(), customName: Navigator.defaultRouteName);
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
            _updateList(),
            _progressBar(),
          ],
        ),
      ),
    );
  }

  Widget _updateList() {
    return Column(
      children:
          widget.updates
              .map((Update update) => _updateListItem(update))
              .toList(),
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
    return StreamBuilder(stream: widget.updates[updateIndex].getProgressStream(), builder: (context, snapshot){
      if (snapshot.connectionState != ConnectionState.active || snapshot.data == null) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Pending..."),
            LinearProgressIndicator()
          ]
        );
      }
      return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(snapshot.data!.message),
            LinearProgressIndicator(value: snapshot.data!.progress)
          ]
        );
    });
  }
}
