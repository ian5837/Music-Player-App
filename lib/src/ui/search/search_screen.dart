import 'package:flutter/material.dart';
import 'package:music_player_app/src/blocs/global.dart';
import 'package:music_player_app/src/models/playerstate.dart';
import 'package:music_player_app/src/models/serviceresponse.dart';
import 'package:music_player_app/src/ui/all_songs/song_tile.dart';
import 'package:music_player_app/src/ui/search/search_screen_bloc.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _textEditingController;
  SearchScreenBloc _searchScreenBloc;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    _searchScreenBloc = SearchScreenBloc();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _searchScreenBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Color(0xFF274D85),
              size: 35,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: StreamBuilder<List<Results>>(
            stream: _globalBloc.musicPlayerBloc.songs$,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              final List<Results> _songs = snapshot.data;
              return TextField(
                controller: _textEditingController,
                cursorColor: Color(0xFF274D85),
                decoration: InputDecoration(
                  disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFD9EAF1).withOpacity(0.7),
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFD9EAF1).withOpacity(0.7),
                    ),
                  ),
                ),
                style: TextStyle(
                  color: Color(0xFF274D85),
                  fontSize: 22.0,
                ),
                autofocus: true,
                onChanged: (String value) {
                  _searchScreenBloc.updateFilteredSongs(value, _songs);
                },
              );
            },
          ),
        ),
        body: StreamBuilder<List<Results>>(
          stream: _searchScreenBloc.filteredSongs$,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final List<Results> _filteredSongs = snapshot.data;

            if (_filteredSongs.length == 0) {
              return Center(
                child: Text(
                  "Enter proper keywords to start searching",
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Color(0xFF274D85),
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.builder(
              key: UniqueKey(),
              padding: const EdgeInsets.only(bottom: 30.0),
              physics: BouncingScrollPhysics(),
              itemCount: _filteredSongs.length,
              itemExtent: 110,
              itemBuilder: (BuildContext context, int index) {
                return StreamBuilder<MapEntry<PlayerState, Results>>(
                  stream: _globalBloc.musicPlayerBloc.playerState$,
                  builder: (BuildContext context,
                      AsyncSnapshot<MapEntry<PlayerState, Results>> snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    final PlayerState _state = snapshot.data.key;
                    final Results _currentSong = snapshot.data.value;
                    final bool _isSelectedSong =
                        _currentSong == _filteredSongs[index];
                    return GestureDetector(
                      onTap: () {
                        _globalBloc.musicPlayerBloc.performTapAction(_state, _currentSong, _isSelectedSong, index, _filteredSongs);
                      },
                      child: ResultsTile(
                        song: _filteredSongs[index],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
