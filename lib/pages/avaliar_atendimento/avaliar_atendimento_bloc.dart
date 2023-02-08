import 'package:flutter_dandelin/model/rating.dart';
import 'package:flutter_dandelin/pages/avaliar_atendimento/avaliar_atendimento_api.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/app_rating_widget.dart';

class AvaliarAtendimentoBloc extends AppRatingBloc {
  final showInput = BooleanBloc();
  final comment = SimpleBloc<String>();
  final button = ButtonBloc();

  fetch() {
    super.fetchRating();
  }

  changeRating(int index) {
    showInput.add(index <= 2 ? true : false);
    button.setEnabled(true);

    super.changeStars(index);
  }

  Future<ApiResponse> sendRating({int idConsulta, int idRating}) async {
    try {
      button.setProgress(true);
      List<StarsRating> list = super.starsRating.value;
      int totRating = list.where((r) => r.marcado == true).length;

      Rating rating = Rating(
        id: idRating,
        idConsulta: idConsulta,
        comment: comment.value,
        rating: totRating == 0 ? null : totRating,
        type: "USER",
      );

      return idRating == null
          ? await AvaliarAtendimentoApi.sendRating(rating)
          : await AvaliarAtendimentoApi.editRating(rating);
    } finally {
      button.setProgress(false);
    }
  }

  dispose() {
    super.disposeRating();
    showInput.dispose();
    comment.dispose();
    button.dispose();
  }
}

class StarsRating {
  bool marcado;
  StarsRating({marcado = false});

  static List<StarsRating> startList() {
    return [
      StarsRating(marcado: false),
      StarsRating(marcado: false),
      StarsRating(marcado: false),
      StarsRating(marcado: false),
      StarsRating(marcado: false),
    ];
  }
}
