import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:restauran_menu/core/services/app_log.dart';
import 'package:restauran_menu/core/services/shared_pref_services.dart';
import 'package:restauran_menu/features/admin/presentation/pages/admin_pengaturan_screen.dart';
import 'package:restauran_menu/features/kasir/presentation/widgets/kasir_print.dart';

import '../../../../core/themes/restaurant_colors.dart';

class PrintSetupScreen extends StatefulWidget {
  const PrintSetupScreen({super.key});

  @override
  State<PrintSetupScreen> createState() => _PrintSetupScreenState();
}

class _PrintSetupScreenState extends State<PrintSetupScreen> {
  late TextEditingController _macController;
  String _paperSize = '58';
  bool _testing = false;

  String _info = "Loading system info...";
  String _msj = '';
  final List<String> _options = [
    "Check Bluetooth Permission",
    "Check Bluetooth State",
    "Check Connection Status",
    "Refresh Platform Info",
  ];

  //final String _selectSize = "2";
  bool _progress = false;
  String _msjprogress = "";
  bool connected = false;
  List<BluetoothInfo> items = [];

  @override
  void initState() {
    super.initState();
    final prefs = SharedPrefServices.pref;
    _macController = TextEditingController(
      text: prefs.getString(SettingsKeys.printerMac) ?? '',
    );
    _paperSize = prefs.getString(SettingsKeys.paperSize) ?? '58';

    initPlatformState();
  }

  @override
  void dispose() {
    _macController.dispose();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    int porcentbatery = 0;
    try {
      platformVersion = await PrintBluetoothThermal.platformVersion;
      porcentbatery = await PrintBluetoothThermal.batteryLevel;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    final bool result = await PrintBluetoothThermal.bluetoothEnabled;
    debugPrint("bluetooth enabled: $result");
    if (result) {
      _msj = "Bluetooth enabled, search for devices to connect.";
    } else {
      _msj = "Bluetooth is disabled. Please turn it on.";
    }

    setState(() {
      _info = "$platformVersion ($porcentbatery% Battery)";
    });
  }

  Future<void> getBluetoots() async {
    setState(() {
      _progress = true;
      _msjprogress = "Searching...";
      items = [];
    });
    final List<BluetoothInfo> listResult =
        await PrintBluetoothThermal.pairedBluetooths;

    setState(() {
      _progress = false;
    });

    if (listResult.isEmpty) {
      _msj = "No paired devices found. Please link the printer in settings.";
    } else {
      _msj = "Select a printer from the list to connect.";
    }

    setState(() {
      items = listResult;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = SharedPrefServices.pref;
    await prefs.setString(SettingsKeys.printerMac, _macController.text.trim());
    await prefs.setString(SettingsKeys.paperSize, _paperSize);
    AppLog.instance.logInfo("Save Print Setting Success!");
  }

  Future<void> _checkConnection() async {
    final mac = _macController.text.trim();
    if (mac.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan MAC address printer')),
      );
      return;
    }
    try {
      await PrintBluetoothThermal.connect(macPrinterAddress: mac);
      AppLog.instance.logInfo('Koneksi berhasil');
      await PrintBluetoothThermal.disconnect;
    } catch (e, s) {
      AppLog.instance.logError('Gagal koneksi: $e', e, s);
    }
  }

  Future<void> connect(String mac) async {
    setState(() {
      _progress = true;
      _msjprogress = "Connecting...";
      connected = false;
    });
    final bool result = await PrintBluetoothThermal.connect(
      macPrinterAddress: mac,
    );
    debugPrint("state connected: $result");

    if (result) connected = true;
    setState(() {
      _progress = false;
    });
  }

  Future<void> disconnect() async {
    final bool status = await PrintBluetoothThermal.disconnect;
    setState(() {
      connected = false;
    });
    debugPrint("status disconnect: $status");
  }

  // Future<List<int>> _buildTestTicket() async {
  //   final profile = await CapabilityProfile.load();
  //   final generator = Generator(
  //     _paperSize == '58' ? PaperSize.mm58 : PaperSize.mm80,
  //     profile,
  //   );
  //   List<int> bytes = [];
  //   bytes += generator.text(
  //     'Test Print',
  //     styles: const PosStyles(align: PosAlign.center, bold: true),
  //   );
  //   bytes += generator.feed(2);
  //   bytes += generator.cut();
  //   return bytes;
  // }

  Future<void> _testPrint() async {
    setState(() => _testing = true);
    bool conexStatus = await PrintBluetoothThermal.connectionStatus;
    await _saveSettings();
    final mac = _macController.text.trim();
    try {
      if (!conexStatus && mac.isNotEmpty) {
        await PrintBluetoothThermal.connect(macPrinterAddress: mac);
      }

      final bytes = await KasirPrint().testTicket(optionprinttype: _paperSize);
      await PrintBluetoothThermal.writeBytes(bytes);
      await PrintBluetoothThermal.disconnect;
      AppLog.instance.logInfo('Test print berhasil');
    } catch (e, s) {
      AppLog.instance.logError('Test print gagal: $e', e, s);
    }
    setState(() => _testing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thermal Bluetooth Printer Setup'),
        backgroundColor: RestaurantColors.primaryBrown,
        actions: [
          PopupMenuButton(
            elevation: 4,
            tooltip: 'More Options',
            onSelected: (Object select) async {
              String sel = select as String;
              if (sel == "Check Bluetooth Permission") {
                bool status =
                    await PrintBluetoothThermal.isPermissionBluetoothGranted;
                setState(() {
                  _info = "Bluetooth Permission Granted: $status";
                });
              } else if (sel == "Check Bluetooth State") {
                bool state = await PrintBluetoothThermal.bluetoothEnabled;
                setState(() {
                  _info = "Bluetooth Enabled: $state";
                });
              } else if (sel == "Refresh Platform Info") {
                await initPlatformState();
              } else if (sel == "Check Connection Status") {
                final bool result =
                    await PrintBluetoothThermal.connectionStatus;
                connected = result;
                setState(() {
                  _info = "Connection Status: $result";
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return _options.map((String option) {
                return PopupMenuItem(value: option, child: Text(option));
              }).toList();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CARD 1: Status & Info
              Card(
                elevation: 0,
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Printer Status",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: connected
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : Colors.grey.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  connected ? Icons.check_circle : Icons.cancel,
                                  color: connected
                                      ? Colors.green
                                      : Colors.grey[700],
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  connected ? "CONNECTED" : "DISCONNECTED",
                                  style: TextStyle(
                                    color: connected
                                        ? Colors.green[800]
                                        : Colors.grey[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(
                        _msj,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Info: $_info",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // CARD 2: Printing Preferences (Width)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.settings_ethernet,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Paper Width:",
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),

                      DropdownButton<String>(
                        value: _paperSize,
                        underline: const SizedBox(), // Removes the default line
                        items: const [
                          DropdownMenuItem(value: '58', child: Text('58 mm')),
                          DropdownMenuItem(value: '80', child: Text('80 mm')),
                        ],
                        onChanged: (v) async {
                          setState(() => _paperSize = v ?? '58');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // CARD 3: Bluetooth Search & Devices List
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Available Printers",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          FilledButton.icon(
                            onPressed: _progress ? null : getBluetoots,
                            icon: _progress
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.search, size: 18),
                            label: Text(_progress ? _msjprogress : "Search"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // ✅ DESPUÉS (Solución correcta con Material)
                      SizedBox(
                        height: 200,
                        child: Material(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLowest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                              width: 0.5,
                            ),
                          ),
                          clipBehavior: Clip
                              .antiAlias, // Mantiene los bordes redondeados al hacer tap
                          child: items.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.print_disabled,
                                          size: 40,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "No paired devices found",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Link the printer in settings, then press Search.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(8),
                                  itemCount: items.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                      leading: CircleAvatar(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                        child: Icon(
                                          Icons.print,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        item.name.isNotEmpty
                                            ? item.name
                                            : "Unknown Device",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        "MAC: ${item.macAdress}",
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      trailing: const Icon(
                                        Icons.chevron_right,
                                        size: 18,
                                      ),
                                      onTap: () {
                                        _macController.text = item.macAdress;
                                        connect(item.macAdress);
                                      },
                                    );
                                  },
                                ),
                        ),
                      ),
                      if (connected) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: disconnect,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.power_settings_new,
                                  size: 18,
                                ),
                                label: const Text("Disconnect"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _testPrint,
                                icon: const Icon(Icons.receipt_long, size: 18),
                                label: const Text("Test Print"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'MAC Address Printer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _macController,
                decoration: const InputDecoration(
                  hintText: 'e.g. 00:11:22:33:44:55',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _checkConnection,
                    child: const Text('Cek Koneksi'),
                  ),
                  const SizedBox(width: 16),
                  // ElevatedButton(
                  //   onPressed: _testing ? null : _testPrint,
                  //   child: const Text('Test Print'),
                  // ),
                  // const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _testing ? null : _saveSettings,
                    child: const Text('Save Settings'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
