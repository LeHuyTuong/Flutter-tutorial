import 'package:flutter/material.dart';

import 'game.dart';

// Điểm khởi động app. runApp() nhận widget gốc và gắn nó vào màn hình.
void main() {
  runApp(const MainApp());
}

// Widget gốc của app.
// StatelessWidget = widget không có state riêng: dựng ra sao thì đứng yên vậy,
// chỉ vẽ lại khi cha vẽ lại.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp cung cấp theme, navigation, hướng chữ... cho toàn app.
    return MaterialApp(
      // Scaffold là bộ khung màn hình chuẩn của Material: appBar + body.
      home: Scaffold(
        appBar: AppBar(
          // Mặc định title trong AppBar bị canh giữa trên iOS,
          // Align ép nó về sát trái cho đồng nhất mọi nền tảng.
          title: const Align(
            alignment: Alignment.centerLeft,
            child: Text('Birdle'),
          ),
        ),
        body: Center(child: GamePage()),
      ),
    );
  }
}

// Màn hình chơi game: vẽ lưới các ô chữ từ dữ liệu trong Game.
//
// StatefulWidget vì mỗi lượt đoán làm thay đổi dữ liệu (_game) và
// cần vẽ lại lưới ô — StatelessWidget không giữ được state qua các lần rebuild.
class GamePage extends StatefulWidget {
  GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // Đối tượng này nằm trong file game.dart.
  // Nó giữ toàn bộ luật chơi wordle (từ bí mật, danh sách lượt đoán,
  // chấm điểm từng chữ cái) và không thuộc phạm vi bài hướng dẫn này.
  //
  // Vì được khai báo trong State (không phải trong widget), _game sống xuyên
  // suốt vòng đời của State và không bị tạo lại mỗi lần build().
  final Game _game = Game();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      // Column xếp các hàng đoán theo chiều dọc; spacing chèn 5px giữa các hàng.
      child: Column(
        spacing: 5.0,
        children: [
          // Collection-for: duyệt từng lượt đoán trong game
          // (kể cả lượt chưa đoán — khi đó Word rỗng) và tạo một Row cho mỗi lượt.
          for (final guess in _game.guesses)
            Row(
              spacing: 5.0,
              // Mỗi Word gồm 5 Letter; mỗi Letter thành một ô Tile.
              // tile.char là ký tự, tile.type là kết quả chấm (hit/partial/miss/none).
              children: [for (final tile in guess) Tile(tile.char, tile.type)],
            ),
          GuessInput(
            onSubmitGuess: (guess) {
              // Phải validate trước khi gọi _game.guess(): Word.fromString()
              // ném ArgumentError nếu guess không đủ 5 ký tự (kể cả bên trong
              // isLegalGuess, nên phải tự check length trước), và
              // evaluateGuess() có assert(isLegalGuess) nếu từ không hợp lệ.
              // Không check trước thì gõ bừa (vd "hehe") sẽ làm app crash.
              if (guess.length != 5 || !_game.isLegalGuess(guess)) return;

              // setState báo cho Flutter biết state vừa đổi, cần build() lại.
              // Nếu gọi _game.guess(guess) mà không bọc setState, dữ liệu
              // vẫn đổi nhưng UI không hề hay biết để vẽ lại.
              setState(() {
                _game.guess(guess);
              });
            },
          ),
        ],
      ),
    );
  }
}

// Một ô vuông hiển thị 1 chữ cái, màu nền cho biết chữ đó đoán đúng tới đâu.
class Tile extends StatelessWidget {
  const Tile(this.letter, this.hitType, {super.key});

  // Ký tự hiển thị trong ô (chuỗi rỗng nếu chưa đoán).
  final String letter;

  // Kết quả chấm của ký tự này so với từ bí mật.
  final HitType hitType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        // switch expression (Dart 3): map thẳng enum -> màu.
        // hit     = đúng chữ, đúng vị trí  -> xanh lá
        // partial = đúng chữ, sai vị trí   -> vàng
        // miss    = chữ không có trong từ  -> xám
        // _       = none, ô chưa đoán      -> trắng
        color: switch (hitType) {
          HitType.hit => Colors.green,
          HitType.partial => Colors.yellow,
          HitType.miss => Colors.grey,
          _ => Colors.white,
        },
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          // Lấy style từ theme thay vì hard-code cỡ chữ,
          // để chữ tự đổi theo theme sáng/tối.
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

// Ô nhập liệu để người chơi gõ từ đoán: TextField + nút bấm gửi (IconButton).
//
// StatefulWidget vì mỗi lần GamePage rebuild (sau setState), Flutter cũng
// dựng lại GuessInput. Nếu _textEditingController/_focusNode nằm trong
// StatelessWidget, chúng bị tạo mới liên tục mỗi lần rebuild — ô nhập sẽ mất
// focus và các controller cũ không được dispose. Đưa chúng vào State object
// giúp chúng sống xuyên suốt vòng đời của widget, không bị tạo lại mỗi lần build.
class GuessInput extends StatefulWidget {
  const GuessInput({super.key, required this.onSubmitGuess});

  // Callback báo ngược lên widget cha khi người chơi submit một từ.
  // Con không tự xử lý luật chơi, chỉ "báo cáo" — cha quyết định làm gì.
  final void Function(String) onSubmitGuess;

  @override
  State<GuessInput> createState() => _GuessInputState();
}

class _GuessInputState extends State<GuessInput> {
  // Controller giữ và điều khiển nội dung của TextField.
  // Dùng nó để đọc text (_textEditingController.text) và xoá text (.clear()).
  final TextEditingController _textEditingController = TextEditingController();

  // FocusNode quản lý con trỏ nhập / bàn phím của TextField.
  // Dùng nó để chủ động xin lại focus sau khi đã submit.
  final FocusNode _focusNode = FocusNode();

  // dispose() được gọi khi State bị huỷ hẳn (widget bị gỡ khỏi cây).
  // Controller và FocusNode giữ tài nguyên native bên dưới, không dọn thì rò rỉ bộ nhớ.
  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Logic dùng chung cho cả hai cách submit: bấm Enter (TextField.onSubmitted)
  // và bấm nút (IconButton.onPressed). Hai callback đó khác chữ ký
  // (một cái nhận String, một cái không nhận gì), nên không gộp thẳng
  // thành một biến function được — phải bọc trong một method riêng như này.
  //
  // Trong State, widget cha (immutable) được truy cập qua `widget`,
  // vì vậy gọi callback là widget.onSubmitGuess chứ không phải onSubmitGuess.
  void _onSubmit() {
    widget.onSubmitGuess(_textEditingController.text.trim());
    _textEditingController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Expanded cho TextField chiếm hết chiều ngang còn lại của Row.
        // Thiếu nó thì TextField không biết mình rộng bao nhiêu và sẽ lỗi layout.
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              // Giới hạn 5 ký tự đúng bằng độ dài một từ trong game.
              maxLength: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(35)),
                ),
              ),
              controller: _textEditingController,
              // Tự động focus ngay khi app mở, vì việc duy nhất người chơi làm
              // là gõ từ đoán — khỏi bắt họ bấm vào ô.
              autofocus: true,
              focusNode: _focusNode,
              // Chạy khi người chơi bấm Enter / nút submit trên bàn phím.
              onSubmitted: (value) => _onSubmit(),
            ),
          ),
        ),
        // Nút bấm để submit bằng tay, thay cho việc phải bấm Enter.
        IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_circle_up),
          onPressed: _onSubmit,
        ),
      ],
    );
  }
}
