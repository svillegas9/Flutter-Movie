import 'package:fish_redux/fish_redux.dart';
import 'package:movie/models/base_api_model/tvshow_stream_link.dart';
import 'package:movie/models/episodemodel.dart';
import 'package:movie/models/imagemodel.dart';
import 'package:movie/models/seasondetail.dart';
import 'package:movie/models/videomodel.dart';
import 'package:movie/views/seasondetail_page/components/seasoncast_component/state.dart';

import 'action.dart';
import 'state.dart';

Reducer<SeasonDetailPageState> buildReducer() {
  return asReducer(
    <Object, Reducer<SeasonDetailPageState>>{
      SeasonDetailPageAction.action: _onAction,
      SeasonDetailPageAction.seasonDetailChanged: _onSeasonDetailChanged,
      SeasonDetailPageAction.setImages: _setImages,
      SeasonDetailPageAction.setVideos: _setVideos,
      SeasonDetailPageAction.setStreamLinks: _setStreamLinks,
    },
  );
}

SeasonDetailPageState _onAction(SeasonDetailPageState state, Action action) {
  final SeasonDetailPageState newState = state.clone();
  return newState;
}

SeasonDetailPageState _onSeasonDetailChanged(
    SeasonDetailPageState state, Action action) {
  final Season model =
      action.payload ?? Season.fromParams(episodes: List<Episode>());
  final SeasonDetailPageState newState = state.clone();
  newState.seasonDetailModel = model;
  newState.seasonCastState = new SeasonCastState(castData: model.credits.cast);
  return newState;
}

SeasonDetailPageState _setVideos(SeasonDetailPageState state, Action action) {
  final VideoModel _videos = action.payload;
  final SeasonDetailPageState newState = state.clone();
  newState.videos = _videos;
  return newState;
}

SeasonDetailPageState _setImages(SeasonDetailPageState state, Action action) {
  final ImageModel _images = action.payload;
  final SeasonDetailPageState newState = state.clone();
  newState.images = _images;
  return newState;
}

SeasonDetailPageState _setStreamLinks(
    SeasonDetailPageState state, Action action) {
  final TvShowStreamLinks _streamLinks = action.payload;
  final SeasonDetailPageState newState = state.clone();
  newState.streamLinks = _streamLinks;
  return newState;
}
