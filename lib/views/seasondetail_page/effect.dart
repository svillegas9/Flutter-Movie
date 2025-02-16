import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:movie/actions/http/base_api.dart';
import 'package:movie/actions/http/tmdb_api.dart';
import 'package:movie/views/stream_link_page/episode_livestream_page/page.dart';
import 'action.dart';
import 'state.dart';

Effect<SeasonDetailPageState> buildEffect() {
  return combineEffects(<Object, Effect<SeasonDetailPageState>>{
    SeasonDetailPageAction.action: _onAction,
    SeasonDetailPageAction.episodeCellTapped: _episodeCellTapped,
    Lifecycle.initState: _onInit,
  });
}

void _onAction(Action action, Context<SeasonDetailPageState> ctx) {}

Future _onInit(Action action, Context<SeasonDetailPageState> ctx) async {
  ctx.state.scrollController = new ScrollController();
  final _tmdb = TMDBApi.instance;
  if (ctx.state.tvid != null && ctx.state.seasonNumber != null) {
    final _detail = await _tmdb.getTVSeasonDetail(
        ctx.state.tvid, ctx.state.seasonNumber,
        appendToResponse: 'credits');
    if (_detail.success)
      ctx.dispatch(
          SeasonDetailPageActionCreator.onSeasonDetailChanged(_detail.result));
    final _videos = await _tmdb.getTvShowSeasonVideo(
        ctx.state.tvid, ctx.state.seasonNumber);
    if (_videos.success)
      ctx.dispatch(SeasonDetailPageActionCreator.setVideos(_videos.result));
    final _images = await _tmdb.getTvShowSeasonImages(
        ctx.state.tvid, ctx.state.seasonNumber);
    if (_images.success)
      ctx.dispatch(SeasonDetailPageActionCreator.setImages(_images.result));
    final _baseApi = BaseApi.instance;
    final _streamLinks = await _baseApi.getTvSeasonStreamLinks(
        ctx.state.tvid, ctx.state.seasonNumber);
    if (_streamLinks.success) {
      for (var e in ctx.state.seasonDetailModel.episodes) {
        e.streamLink = _streamLinks.result.list.firstWhere((d) {
          return d.episode == e.episodeNumber;
        }, orElse: () => null);
      }

      ctx.dispatch(
          SeasonDetailPageActionCreator.setStreamLinks(_streamLinks.result));
    }
  }
}

Future _episodeCellTapped(
    Action action, Context<SeasonDetailPageState> ctx) async {
  await Navigator.of(ctx.context).push(
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (BuildContext context, Animation animation,
          Animation secondaryAnimation) {
        final _curvedAnimation =
            CurvedAnimation(parent: animation, curve: Curves.ease);
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 1),
            end: Offset.zero,
          ).animate(_curvedAnimation),
          child: FadeTransition(
            opacity: _curvedAnimation,
            child: EpisodeLiveStreamPage().buildPage(
              {
                'tvid': ctx.state.tvid,
                'selectedEpisode': action.payload,
                'streamlinks': ctx.state.streamLinks,
                'season': ctx.state.seasonDetailModel
              },
            ),
          ),
        );
      },
    ),
  );
}
