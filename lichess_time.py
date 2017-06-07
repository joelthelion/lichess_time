#!/usr/bin/env python3

import bz2
import chess.pgn

class TimeChessGameVisitor(chess.pgn.BaseVisitor):
    def __init__(self):
        self.clocks = [0,0]
        self.move = -1
        pass
    def visit_header(self, name, value):
        if name == "TimeControl":
            print(value)
            if "+" in value:
                self.main, self.increment = [float(v) for v in value.split("+")]
            else:
                assert(value == "-")
                self.main, self.increment = 1000, 0
    def visit_comment(self, comment):
        if "%clk" in comment:
            raw_clock = comment[6:-1]
            h,m,s = [float(t) for t in raw_clock.split(":")]
            self.clocks[self.move%2] = h*3600 + m*60 + s
            print(self.move, self.clocks)
        else:
            print(comment)
    def visit_move(self, board, move):
        self.move += 1
    def end_game(self):
        self.game_duration = self.increment * self.move + 2 * self.main - self.clocks[0] - self.clocks[1]
    def result(self):
        return self.game_duration

if __name__ == "__main__":
    lichess_file = bz2.open("./lichess_db_standard_rated_2017-05.pgn.bz2", "rt")
    while True:
        total_time = chess.pgn.read_game(lichess_file, TimeChessGameVisitor)
        print(total_time)
