import 'package:flutter/material.dart';
import 'package:flutter_dandelin/pages/avaliar_atendimento/avaliar_atendimento_bloc.dart';
import 'package:flutter_dandelin/utils/bloc.dart';

class AppRatingStream extends StatelessWidget {
  final Stream<List<StarsRating>> stream;
  final Function(int) onPressed;
  final String estrelaVazia;

  const AppRatingStream(
      {Key key,
      @required this.stream,
      @required this.onPressed,
      this.estrelaVazia = 'assets/images/estrela-vazia.png'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        List<StarsRating> list =
            snapshot.hasData ? snapshot.data : List<StarsRating>();

        List<Widget> children = List<Widget>();

        list.asMap().forEach((i, star) {
          children.add(_gestureStar(star, i));

          if (i != 4) {
            children.add(SizedBox(width: 12));
          }
        });

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        );
      },
    );
  }

  _gestureStar(StarsRating star, int idx) {
    return GestureDetector(
      onTap: () {
        onPressed(idx);
      },
      child: Image.asset(
        star.marcado != null && star.marcado
            ? 'assets/images/estrela-cheia.png'
            : estrelaVazia,
        height: 35,
      ),
    );
  }
}

class AppRatingBloc {
  final starsRating = SimpleBloc<List<StarsRating>>();

  fetchRating({int index}) {
    starsRating.add(StarsRating.startList());
    if (index != null) {
      changeStars(index);
    }
  }

  changeStars(int index) {
    List<StarsRating> list = starsRating.value;

    list.asMap().forEach((idx, star) {
      idx <= index ? star.marcado = true : star.marcado = false;
    });

    starsRating.add(list);
  }

  disposeRating() {
    starsRating.dispose();
  }
}
