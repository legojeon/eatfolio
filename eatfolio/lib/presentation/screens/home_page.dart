import 'package:flutter/material.dart';
import '../../core/fonts.dart';
import '../widgets/searchbar.dart' as custom;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: null,
        centerTitle: true,
        title: Text('eatfolio', style: AppFonts.logotext),
      ),
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          // 키보드 숨기기
          print('키보드 숨기기');
          FocusScope.of(context).unfocus();
        },
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                custom.SearchBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}