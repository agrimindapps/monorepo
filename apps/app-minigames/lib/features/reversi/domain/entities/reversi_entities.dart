enum ReversiPlayer { black, white }

extension ReversiPlayerExt on ReversiPlayer {
  ReversiPlayer get opponent =>
      this == ReversiPlayer.black ? ReversiPlayer.white : ReversiPlayer.black;
}
