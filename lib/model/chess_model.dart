import 'package:get/get.dart';
import 'package:sms_syncer/proto/message.pb.dart';

class ChessModel extends GetxController {
  int x = 19;
  int y = 19;
  late RxList<RxList<String>> chess;

  String? _lastIden;

  ChessModel() {
    chess = RxList.generate(x, (index) => RxList.generate(y, (i) => ''));
  }

  bool isMyChance(String iden) {
    if (_lastIden == null) {
      return iden == 'X';
    } else {
      return _lastIden != iden;
    }
  }

  bool press(DoRequest req, String iden) {
    if (chess[req.x][req.y].isNotEmpty || !isMyChance(iden)) {
      return false;
    }
    chess[req.x][req.y] = iden;
    print("${req.x}, ${req.y} : ${iden}");
    _lastIden = iden;
    return true;
  }

  bool checkNowPos(String cur, int x, int y) {
    var N = this.x;
    int cnt;
    int i, j;
    //0du
    cnt = 0;
    for (j = y + 1; j < N; j++) {
      if (chess[x][j] != cur) {
        break;
      } else {
        cnt++;
      }
    }
    for (j = y - 1; j >= 0; j--) {
      if (chess[x][j] != cur) {
        break;
      } else {
        cnt++;
      }
    }
    if (cnt == 4) {
      return true;
    }
    //90du
    cnt = 0;
    for (i = x + 1; i < N; i++) {
      if (chess[i][y] != cur)
        break;
      else
        cnt++;
    }
    for (i = x - 1; i >= 0; i--) {
      if (chess[i][y] != cur) {
        break;
      } else {
        cnt++;
      }
    }
    if (cnt == 4) {
      return true;
    }
    //45du
    cnt = 0;
    for (var i = x + 1, j = y + 1; i < N && j < N; i++, j++) {
      if (chess[i][j] != cur) {
        break;
      } else {
        cnt++;
      }
    }
    for (var i = x - 1, j = y - 1; i >= 0 && j >= 0; i--, j--) {
      if (chess[i][j] != cur) {
        break;
      } else {
        cnt++;
      }
    }
    if (cnt == 4) {
      return true;
    }
    //135du
    cnt = 0;
    for (var i = x - 1, j = y + 1; i >= 0 && j < N; i--, j++) {
      if (chess[i][j] != cur) {
        break;
      } else {
        cnt++;
      }
    }
    for (var i = x + 1, j = y - 1; i < N && j >= 0; i++, j--) {
      if (chess[i][j] != cur) {
        break;
      } else {
        cnt++;
      }
    }
    if (cnt == 4) {
      return true;
    }
    return false;
  }

  bool checkWin(String iden) {
    bool flag = false;
    for (var i = 0; i < x; i++){
      for (var j = 0; j < y; j++){
        if (chess[i][j] == iden){
          if(checkNowPos(iden, i, j)){
            return true;
          }
        }
      }
    }
    return false;
  }

  bool isFull() {
    for (var i = 0; i < x; i++) {
      for (var j = 0; j < y; j++) {
        if (chess[i][j].isEmpty) {
          return false;
        }
      }
    }
    return true;
  }
}
