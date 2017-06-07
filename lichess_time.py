#!/usr/bin/env python3

""" Capture total game time as a function of time settings.
    Input data: lichess game archives from database.lichess.org
"""

import bz2
import csv
import chess.pgn

class TimeChessGameVisitor(chess.pgn.BaseVisitor):
    def __init__(self):
        self.clocks = [0,0]
        self.move = -1
    def visit_header(self, name, value):
        if name == "TimeControl":
            print(value)
            self.time_control = value
            if "+" in value:
                self.main, self.increment = [float(v) for v in value.split("+")]
            else:
                assert value == "-"
                self.main, self.increment = 0, 0
        elif name == "Site":
            print(value)
    def visit_comment(self, comment):
        if "%clk" in comment:
            raw_clock = comment[6:-1]
            h,m,s = [float(t) for t in raw_clock.split(":")]
            self.clocks[self.move%2] = h*3600 + m*60 + s
        else:
            pass
    def visit_move(self, board, move):
        self.move += 1
    def end_game(self):
        self.game_duration = self.increment * self.move + 2 * self.main - self.clocks[0] - self.clocks[1]
    def result(self):
        return self.time_control, self.main, self.increment, self.game_duration

if __name__ == "__main__":
    lichess_file = bz2.open("./lichess_db_standard_rated_2017-05.pgn.bz2", "rt")
    with open("game_times.csv","wt") as output:
        writer = csv.writer(output)
        writer.writerow(["time_control","main","increment","total_time"])
        while True:
            time_control, main, increment, total_time = chess.pgn.read_game(lichess_file, TimeChessGameVisitor)
            writer.writerow([time_control, main, increment, total_time])
