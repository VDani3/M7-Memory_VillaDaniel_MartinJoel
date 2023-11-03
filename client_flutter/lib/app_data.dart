import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/io.dart';

// Access appData globaly with:
// AppData appData = Provider.of<AppData>(context);
// AppData appData = Provider.of<AppData>(context, listen: false)

enum ConnectionStatus {
  disconnected,
  disconnecting,
  connecting,
  connected,
}

class AppData with ChangeNotifier {
  String ip = "localhost";
  String port = "8888";
  String name = "Messi";

  IOWebSocketChannel? _socketClient;
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;

  String? mySocketId;
  List<String> clients = [];
  String selectedClient = "";
  int? selectedClientIndex;
  String messages = "";

  bool file_saving = false;
  bool file_loading = false;

  AppData() {
    _getLocalIpAddress();
  }

  void _getLocalIpAddress() async {
    try {
      final List<NetworkInterface> interfaces = await NetworkInterface.list(
          type: InternetAddressType.IPv4, includeLoopback: false);
      if (interfaces.isNotEmpty) {
        final NetworkInterface interface = interfaces.first;
        final InternetAddress address = interface.addresses.first;
        ip = address.address;
        notifyListeners();
      }
    } catch (e) {
      // ignore: avoid_print
      print("Can't get local IP address : $e");
    }
  }

  void connectToServer() async {
    connectionStatus = ConnectionStatus.connecting;
    notifyListeners();

    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 1));

    _socketClient = IOWebSocketChannel.connect("ws://$ip:$port");
    _socketClient?.sink.add('{"name": "${playersName[0]}"}');
    _socketClient!.stream.listen(
      (message) {
        final data = jsonDecode(message);

        switch (data['type']) {
          case 'id':
            playersId.add(data['me']);
            playersId.add(data['enemy']);
            meActivePlayer = data['can'];
            playersName.add(data['enemyName']);
            gameImages = setGameImages(data['cards']);
            break;
          case 'name':
            playersName.add(data['name']);
            break;
          default:
            messages += "Message from '${data['from']}': ${data['value']}\n";
            break;
        }
        if (connectionStatus != ConnectionStatus.connected && playersId != 2) {
          connectionStatus = ConnectionStatus.connected;
        }

        notifyListeners();
      },
      onError: (error) {
        connectionStatus = ConnectionStatus.disconnected;
        mySocketId = "";
        selectedClient = "";
        clients = [];
        messages = "";
        notifyListeners();
      },
      onDone: () {
        connectionStatus = ConnectionStatus.disconnected;
        mySocketId = "";
        selectedClient = "";
        clients = [];
        messages = "";
        notifyListeners();
      },
    );
  }

  disconnectFromServer() async {
    connectionStatus = ConnectionStatus.disconnecting;
    notifyListeners();

    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 1));

    _socketClient!.sink.close();
  }

  selectClient(int index) {
    if (selectedClientIndex != index) {
      selectedClientIndex = index;
      selectedClient = clients[index];
    } else {
      selectedClientIndex = null;
      selectedClient = "";
    }
    notifyListeners();
  }

  refreshClientsList() {
    final message = {
      'type': 'list',
    };
    _socketClient!.sink.add(jsonEncode(message));
  }

  send(String msg) {
    if (selectedClientIndex == null) {
      broadcastMessage(msg);
    } else {
      privateMessage(msg);
    }
  }

  broadcastMessage(String msg) {
    final message = {
      'type': 'broadcast',
      'value': msg,
    };
    _socketClient!.sink.add(jsonEncode(message));
  }

  privateMessage(String msg) {
    if (selectedClient == "") return;
    final message = {
      'type': 'private',
      'value': msg,
      'destination': selectedClient,
    };
    _socketClient!.sink.add(jsonEncode(message));
  }

  /*
  * Save file example:

    final myData = {
      'type': 'list',
      'clients': clients,
      'selectedClient': selectedClient,
      // i més camps que vulguis guardar
    };
    
    await saveFile('myData.json', myData);

  */

  Future<void> saveFile(String fileName, Map<String, dynamic> data) async {
    file_saving = true;
    notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      final jsonData = jsonEncode(data);
      await file.writeAsString(jsonData);
    } catch (e) {
      // ignore: avoid_print
      print("Error saving file: $e");
    } finally {
      file_saving = false;
      notifyListeners();
    }
  }

  /*
  * Read file example:
  
    final data = await readFile('myData.json');

  */

  Future<Map<String, dynamic>?> readFile(String fileName) async {
    file_loading = true;
    notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final data = jsonDecode(jsonData) as Map<String, dynamic>;
        return data;
      } else {
        // ignore: avoid_print
        print("File does not exist!");
        return null;
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error reading file: $e");
      return null;
    } finally {
      file_loading = false;
      notifyListeners();
    }
  }

  //Memory
  List<String> playersName = [];
  List<String> playersId = [];
  List<int> playersScore = [0, 0]; 
  int torn = 0;
  int waiting = 1;
  bool meActivePlayer = true;

  //Lista de imagenes
  List<String>? gameImages;    //Aqui se pondran las fotos actuales de cada casilla
  final List<String> cardFotos = [
    'assets/images/iniesta.png',
    'assets/images/villaIniesta.png',
    'assets/images/villaIniestaKobe.png',
    'assets/images/villaIniestaJapan.png',
    'assets/images/iniestaCopa.png',
    'assets/images/munyeco.png',
    'assets/images/villaKobe.png',
    'assets/images/villaSpain.png',
  ];
  //Para ver si las dos primeras clicadas son iguales o no
  List<Map<int, String>> pairCheck = [];
  final String interrogantePath = 'assets/images/hidden.png';
  final int cardCount = 8;

  void setName(String name, String name2) {
    playersName.add(name);
    playersName.add(name2);
    notifyListeners();
  }

  void changeRound() {
    int c = torn;
    torn = 0+waiting;
    waiting = 0+c;
  }

  List<String> setGameImages(List<int> indexCards) {
    List<String> result = new List.empty();

    for (int card in indexCards) {
      result.add(cardFotos[card]);
    }

    return result;
  }
}
