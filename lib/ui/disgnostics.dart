import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tejory/box_models.g.dart';
import 'package:tejory/objectbox.g.dart';
import 'package:tejory/singleton.dart';

class Diagnostics extends StatefulWidget {
  const Diagnostics({super.key});

  @override
  State<Diagnostics> createState() => _DiagnosticState();
}

class _DiagnosticState extends State<Diagnostics> {
  late final Future<Map<String, String>> data;
  final Map<String, Map<String, String>> assetsMap = {};
  
  // This is a mock function. Replace with your actual data loading.
  Future<Map<String, String>> loadData() async {
    final version = await Singleton.getVersion();
    final os = Platform.operatingSystem;
    final osVersion = Platform.operatingSystemVersion;
    final timeStamp = DateTime.now().toUtc().toIso8601String();

    final assets = Models.coin.find();
    
    if (assets == null) {
      throw Exception("Unable to read assets from the database");
    }

    assetsMap.clear();

    String mapKey;
    String mapValue;
    for (final asset in assets) {
      final Map<String, String> assetDetails = {};
      final balance = Models.balance.getUnique(asset.id, 1);
      assetDetails["balance.coinBalance"] =
          balance?.coinBalance?.toString() ?? "NA";
      assetDetails["balance.lastBlockUpdate"] =
          balance?.lastBlockUpdate?.toString() ?? "NA";
      assetDetails["balance.lastUpdate"] =
          balance?.lastUpdate?.toUtc().toIso8601String() ?? "NA";
      final keys = Models.key.find(q: Key_.coin.equals(asset.id));
      if (keys == null) {
        throw Exception("Unable to read keys from the database");
      }

      for (final key in keys) {
        mapKey = key.path!;
        mapValue = "${key.pubKey} - ${key.chainCode}";
        assetDetails["key[${mapKey}]"] = mapValue;
      }

      final nextKeys = Models.nextKey.find(q: NextKey_.coin.equals(asset.id));
      if (nextKeys == null) {
        throw Exception("Unable to read keys from the database");
      }
      for (final nextKey in nextKeys) {
        mapKey = nextKey.path!;
        mapValue = "${nextKey.nextKey}";
        assetDetails["nextKey[${mapKey}]"] = mapValue;
      }

      assetsMap[asset.symbol!] = assetDetails;
    }

    final Map<String, String> diagnosticsData = {
      "App Version": version,
      "OS Version": "${os} (${osVersion})",
      "Data Generated At": timeStamp,
    };

    assetsMap.forEach((assetSymbol, detailsMap) {
      // Add a separator for readability
      diagnosticsData['--- $assetSymbol ---'] = '---';

      detailsMap.forEach((key, value) {
        // Create the new flattened key
        final newKey = '$assetSymbol - $key';
        diagnosticsData[newKey] = value;
      });
    });

    return diagnosticsData;
  }

  @override
  void initState() {
    super.initState();
    data = loadData();
  }

  // --- Start of the new build method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Diagnostics')),
      body: FutureBuilder<Map<String, String>>(
        future: data,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Failed to load diagnostics.\nError: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            );
          }

          // 3. Data Loaded Successfully
          if (snapshot.hasData) {
            final diagnostics = snapshot.data!;
            return Column(
              children: [
                // Warning Message
                _buildWarningCard(context),

                // Data List
                Expanded(
                  child: ListView.builder(
                    itemCount: diagnostics.length,
                    itemBuilder: (context, index) {
                      final key = diagnostics.keys.elementAt(index);
                      final value = diagnostics.values.elementAt(index);
                      return ListTile(
                        title: Text(key),
                        subtitle: Text(
                          value,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Copy Button
                _buildCopyButton(context, diagnostics),
              ],
            );
          }

          // Fallback empty state
          return const Center(child: Text('No diagnostic data available.'));
        },
      ),
    );
  }

  // Helper widget for the copy button
  Widget _buildCopyButton(
    BuildContext context,
    Map<String, String> diagnostics,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.copy),
          label: const Text('Copy to Clipboard'),
          onPressed: () {
            
            final Map<String, dynamic> diagnosticsReport = {
              "App Version": diagnostics["App Version"],
              "OS Version": diagnostics["OS Version"],
              "Data Generated At": diagnostics["Data Generated At"],
              "assets": assetsMap,
            };

            const jsonEncoder = JsonEncoder.withIndent('  '); // Use 2-space indentation
            final jsonString = jsonEncoder.convert(diagnosticsReport);

            // Copy to clipboard
            Clipboard.setData(ClipboardData(text: jsonString));

            // Show confirmation snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Diagnostic data copied to clipboard!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWarningCard(BuildContext context) {
    final theme = Theme.of(context);
    final warningColor = theme.colorScheme.error;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: warningColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headline
            Text(
              'DANGER: Read This Carefully',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Bullet Points
            _buildBulletPoint(context, 'NEVER share this screen with anyone.'),
            const SizedBox(height: 8),
            _buildBulletPoint(
              context,
              'Scammers WILL use this to steal your identity, impersonate you, and try to take your money.',
            ),
            const SizedBox(height: 8),
            _buildBulletPoint(
              context,
              'ONLY send this data to our official support email: ',
              email: 'support@tejory.io',
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to create a consistent bullet point row
  Widget _buildBulletPoint(BuildContext context, String text, {String? email}) {
    final theme = Theme.of(context);
    final onWarningColor = theme.colorScheme.onErrorContainer;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: onWarningColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: onWarningColor,
              ),
              children: [
                TextSpan(text: text),
                if (email != null)
                  TextSpan(
                    text: email,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
