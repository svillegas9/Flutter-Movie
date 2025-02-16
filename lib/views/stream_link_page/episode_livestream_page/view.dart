import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:movie/actions/adapt.dart';
import 'package:movie/actions/imageurl.dart';
import 'package:movie/models/creditsmodel.dart';
import 'package:movie/models/enums/imagesize.dart';
import 'package:movie/models/episodemodel.dart';
import 'package:movie/models/seasondetail.dart';
import 'package:movie/style/themestyle.dart';
import 'package:movie/widgets/expandable_text.dart';
import 'components/bottom_panel.dart';
import 'components/webview_player.dart';

import 'action.dart';
import 'state.dart';

Widget buildView(
    EpisodeLiveStreamState state, Dispatch dispatch, ViewService viewService) {
  return Builder(
    builder: (context) {
      final _theme = ThemeStyle.getTheme(context);

      return Scaffold(
        backgroundColor: _theme.backgroundColor,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: _theme.brightness == Brightness.light
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light,
          child: Stack(
            children: [
              Container(
                child: ListView(
                  controller: state.scrollController,
                  padding: EdgeInsets.symmetric(horizontal: Adapt.px(40)),
                  children: [
                    SizedBox(
                      height: Adapt.px(30) + Adapt.padTopH(),
                    ),
                    WebViewPlayer(
                      tvid: state.tvid,
                      episode: state.selectedEpisode,
                    ),
                    _Header(
                      episode: state.selectedEpisode,
                      season: state.season,
                    ),
                    _Episodes(
                      episodes: state.season.episodes,
                      episodeNumber: state.selectedEpisode.episodeNumber,
                      onTap: (d) => dispatch(
                          EpisodeLiveStreamActionCreator.episodeTapped(d)),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              Container(
                color: _theme.backgroundColor,
                height: Adapt.padTopH(),
              ),
              BottomPanel(
                commentCount: state.comments?.totalCount ?? 0,
                likeCount: state.likeCount,
                userLiked: state.userliked,
                likeTap: () =>
                    dispatch(EpisodeLiveStreamActionCreator.likeTvShow()),
                commentTap: () =>
                    dispatch(EpisodeLiveStreamActionCreator.commentTap()),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _Header extends StatelessWidget {
  final Episode episode;
  final Season season;
  const _Header({this.episode, this.season});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Adapt.px(40)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            episode.name,
            style: TextStyle(
              fontSize: Adapt.px(35),
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),
          SizedBox(height: Adapt.px(40)),
          Row(children: [
            Container(
              width: Adapt.px(80),
              height: Adapt.px(80),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Adapt.px(20)),
                image: season.posterPath != null
                    ? DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(
                          ImageUrl.getUrl(season.posterPath, ImageSize.w300),
                        ),
                      )
                    : null,
              ),
            ),
            SizedBox(width: Adapt.px(10)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(season.name),
                Text(
                  DateFormat.yMMMd().format(DateTime.parse(season.airDate)),
                  style: TextStyle(
                    fontSize: Adapt.px(24),
                    color: const Color(0xFF717171),
                  ),
                ),
              ],
            ),
            Spacer(),
            _CastCell(casts: season.credits.cast)
          ]),
          SizedBox(height: Adapt.px(40)),
          ExpandableText(
            season.overview,
            maxLines: 3,
            style: TextStyle(color: const Color(0xFF717171), height: 1.5),
          )
        ],
      ),
    );
  }
}

class _CastCell extends StatelessWidget {
  final List<CastData> casts;
  const _CastCell({this.casts});
  @override
  Widget build(BuildContext context) {
    final _theme = ThemeStyle.getTheme(context);
    return Container(
      width: Adapt.px(240),
      child: Row(
        children: casts
            .take(4)
            .map((e) {
              final int _index = casts.indexOf(e);
              return Container(
                width: Adapt.px(60),
                height: Adapt.px(60),
                transform: Matrix4.translationValues(10.0 * _index, 0, 0),
                decoration: BoxDecoration(
                  color: _theme.primaryColorDark,
                  border: Border.all(
                    color: const Color(0xFFFFFFFF),
                    width: 1,
                  ),
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(
                        ImageUrl.getUrl(e.profilePath, ImageSize.w300)),
                  ),
                ),
              );
            })
            .toList()
            .reversed
            .toList(),
      ),
    );
  }
}

class _Episodes extends StatelessWidget {
  final List<Episode> episodes;
  final int episodeNumber;
  final Function(Episode) onTap;

  const _Episodes({this.episodes, this.episodeNumber, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Adapt.px(40)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Episode',
            style: TextStyle(
              fontSize: Adapt.px(30),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: Adapt.px(30)),
          ListView.separated(
              padding: EdgeInsets.zero,
              physics: PageScrollPhysics(),
              shrinkWrap: true,
              separatorBuilder: (_, __) => SizedBox(height: Adapt.px(30)),
              itemCount: episodes.length,
              itemBuilder: (_, index) {
                int _episodeIndex = episodeNumber - 1;
                int _d = _episodeIndex + index;
                final int _index =
                    _d < episodes.length ? _d : _d - episodes.length;
                return _EpisodeCell(
                  episode: episodes[_index],
                  onTap: onTap,
                );
              })
        ],
      ),
    );
  }
}

class _EpisodeCell extends StatelessWidget {
  final Episode episode;
  final Function(Episode) onTap;
  const _EpisodeCell({this.episode, this.onTap});
  @override
  Widget build(BuildContext context) {
    final _theme = ThemeStyle.getTheme(context);
    return GestureDetector(
      onTap: () => onTap(episode),
      child: Row(
        children: [
          Container(
            width: Adapt.px(220),
            height: Adapt.px(122),
            decoration: BoxDecoration(
              color: _theme.primaryColorDark,
              borderRadius: BorderRadius.circular(Adapt.px(15)),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(
                  ImageUrl.getUrl(episode.stillPath, ImageSize.w300),
                ),
              ),
            ),
          ),
          SizedBox(width: Adapt.px(20)),
          SizedBox(
            width: Adapt.screenW() - Adapt.px(320),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EP${episode.episodeNumber}',
                  style: TextStyle(
                      fontSize: Adapt.px(28), fontWeight: FontWeight.bold),
                ),
                Text(episode.name),
              ],
            ),
          )
        ],
      ),
    );
  }
}
