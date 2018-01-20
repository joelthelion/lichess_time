#!/usr/bin/env python3

""" Capture total game time as a function of time settings.
    Input data: lichess game archives from database.lichess.org
"""

import math
import bz2
import csv
import chess.pgn

class TimeChessGameVisitor(chess.pgn.BaseVisitor):
    def __init__(self):
        self.clocks = [0,0]
        self.move = -1
        self.past_val = 0.15
        self.centipawn = {0:0, 1:0}
        self.centipawn_counts = {0:0, 1:0}
        self.white_elo, self.black_elo = None, None
    def visit_header(self, name, value):
        if name == "TimeControl":
            # print(value)
            self.time_control = value
            if "+" in value:
                self.main, self.increment = [float(v) for v in value.split("+")]
            else:
                assert value == "-"
                self.main, self.increment = 0, 0
        elif name == "WhiteElo":
            self.white_elo = float(value)
        elif name == "BlackElo":
            self.black_elo = float(value)
        elif name == "Site":
            pass
            # print(value)
    def visit_comment(self, comment):
        if "%clk" in comment:
            raw_clock = comment[6:-1]
            h,m,s = [float(t) for t in raw_clock.split(":")]
            self.clocks[self.move%2] = h*3600 + m*60 + s
        elif "%eval" in comment:
            val = comment[7:-1]
            if not val.startswith("#"):
                val = float(val)
                if abs(val)>10:
                    val = math.copysign(10., val)
            elif val[1] == "-":
                val = -10.
            else:
                val = 10.
            loss = val - self.past_val
            print(val, loss)
            self.past_val = val
            player = self.move % 2
            self.centipawn_counts[player] += 1
            if (loss>0) != (player == 0):
                self.centipawn[player] += abs(loss)
        else:
            pass
    def visit_move(self, board, move):
        self.move += 1
    def end_game(self):
        self.game_duration = self.increment * self.move + 2 * self.main - self.clocks[0] - self.clocks[1]
        if self.centipawn_counts[0] > 0:
            self.centipawn = {p:self.centipawn[p]/self.centipawn_counts[p]*100. for p in self.centipawn.keys()} 
            print("centipawn loss: ", self.centipawn)
        else:
            self.centipawn = {0:None, 1:None}
    def result(self):
        return self.time_control, self.main, self.increment, self.game_duration, self.white_elo, \
                self.black_elo, self.centipawn[0], self.centipawn[1]

if __name__ == "__main__":
    lichess_file = bz2.open("./lichess_db_standard_rated_2017-05.pgn.bz2", "rt")
    with open("game_times.csv","wt") as output:
        writer = csv.writer(output)
        writer.writerow(["time_control","main","increment","total_time","white_elo","black_elo","white_cpwn","black_cpwn"])
        while True:
            time_control, main, increment, total_time, white_elo, black_elo, white_cpwn, black_cpwn = chess.pgn.read_game(lichess_file, TimeChessGameVisitor)
            writer.writerow([time_control, main, increment, total_time, white_elo, black_elo, white_cpwn, black_cpwn])
