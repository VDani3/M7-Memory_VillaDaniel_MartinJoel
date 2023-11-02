import 'package:client_flutter/widgets/scorePanel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'widget_selectable_list.dart';

class LayoutConnected extends StatefulWidget {
  const LayoutConnected({Key? key}) : super(key: key);

  @override
  State<LayoutConnected> createState() => _LayoutConnectedState();
}

class _LayoutConnectedState extends State<LayoutConnected> {
  final ScrollController _scrollController = ScrollController();
  final _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

  bool canPlay = true;
  AppData _game = AppData();

  @override
  void initState() {
    super.initState();
    _game.initializeGame();
  }

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);

    double screenWidth = MediaQuery.of(context).size.width;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Memory', 
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 50,),
          Row(
            children: [
              scorePanel(_game.playersName[0], _game.playersScore[0].toString(), _game.meActivePlayer),
              scorePanel(_game.playersName[1], _game.playersScore[1].toString(), !_game.meActivePlayer)
            ],
          ),
          SizedBox(
            height: screenWidth/2, 
            width: screenWidth/2,
            child: GridView.builder(
              itemCount: _game.gameImages!.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16
              ), 
              padding: EdgeInsets.all(16),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    boldCard(index, _game);
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      color: const Color.fromARGB(255, 138, 202, 255),
                      image: DecorationImage(
                        image: AssetImage(_game.gameImages![index]),
                        fit: BoxFit.cover
                      )
                    )
                    ),
                  );
              }
            ),
          )
        ]
      ),
    );
  }

  void boldCard(int index, AppData data) {
    if (canPlay && data.gameImages![index] == data.interrogantePath) {
      setState(() {
        data.gameImages![index] = data.cardFotos[index];
        data.pairCheck.add({index: data.cardFotos[index]});
      });
      if (data.pairCheck.length >= 2) {
          canPlay = false;
          if(data.pairCheck[0].values.first == data.pairCheck[1].values.first) {
            data.playersScore[data.torn] += 1;
            data.pairCheck.clear();
            canPlay = true;
          } else {
            Future.delayed(Duration(milliseconds: 600), () {
              setState(() {
                data.gameImages![data.pairCheck[0].keys.first] = data.interrogantePath;
                data.gameImages![data.pairCheck[1].keys.first] = data.interrogantePath;
                data.pairCheck.clear();
                data.changeRound();
                data.meActivePlayer = !data.meActivePlayer;
              });
              canPlay = true;
            });
          }
      }
    }
  }
  }
