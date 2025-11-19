--  Game Frames per Second
FPS = 60

--  Y Coordinates Offset
Y_OFFSET = 92

--  Game Matrix
SCALE_FACTOR = 4
ASSET_GRID_SIZE = 16
SIZE = SCALE_FACTOR * ASSET_GRID_SIZE
SNAP_SIZE = SIZE / 5
ROWS = 12
COLS = 30

--  Level Time
STAGE_TIME = 200

--  Game Window Settings
SCREENWIDTH = 20 * SIZE
SCREENHEIGHT = 14 * SIZE
WINDOW_SIZE_SCALE = 0.5

--  Colours
BLACK = {0, 0, 0}
RED = {1, 0, 0}
GREEN = {0, 1, 0}
BLUE = {0, 0, 1}
GREY = {188/255, 188/255, 188/255}

-- Enemy Attributes
ENEMIES = {ballom = {speed = 1, wall_hack = false, chase_player = false, LoS = 0, see_player_hack = false},
           onil = {speed = 2, wall_hack = false, chase_player = true, LoS = 4, see_player_hack = false},
           dahl = {speed = 2, wall_hack = false, chase_player = true, LoS = 0, see_player_hack = false},
           minvo = {speed = 2, wall_hack = false, chase_player = true, LoS = 4, see_player_hack = true},
           doria = {speed = 0.5, wall_hack = true, chase_player = true, LoS = 6, see_player_hack = true},
           ovape = {speed = 1, wall_hack = true, chase_player = true, LoS = 8, see_player_hack = false},
           pass = {speed = 2, wall_hack = true, chase_player = true, LoS = 12, see_player_hack = false},
           pontan = {speed = 4, wall_hack = true, chase_player = true, LoS = 30, see_player_hack = false},
        }

--  Sprite Coordinates
PLAYER = {walk_left  = {{0, 1}, {0, 0}, {0, 2}},
          walk_down  = {{0, 4}, {0, 3}, {0, 5}},
          walk_right = {{0, 7}, {0, 6}, {0, 8}},
          walk_up    = {{0, 10}, {0, 9}, {0, 11}},
          dead_anim  = {{1, 0}, {1, 1}, {1, 2}, {1, 3}, {1, 4}, {1, 5}, {1, 6}}}

HARD_BLOCK = {hard_block = {{1, 10}}}
SOFT_BLOCK = {soft_block = {{2, 0}, {2, 1}, {2, 2}, {2, 3}, {2, 4}, {2, 5}, {2, 6}}}
BACKGROUND = {background = {{2, 11}}}
BOMB = {bomb = {{1, 7}, {1, 8}, {1, 9}, {1, 8}}}
EXPLOSIONS = {centre    = {{2, 7}, {2, 8}, {2, 9}, {2, 10}},
              left_end  = {{3, 0}, {3, 1}, {3, 2}, {3, 3}},
              right_end = {{3, 0}, {3, 1}, {3, 2}, {3, 3}},
              up_end    = {{4, 0}, {4, 1}, {4, 2}, {4, 3}},
              down_end  = {{4, 0}, {4, 1}, {4, 2}, {4, 3}},
              left_mid  = {{3, 4}, {3, 5}, {3, 6}, {3, 7}},
              right_mid = {{3, 4}, {3, 5}, {3, 6}, {3, 7}},
              up_mid    = {{4, 4}, {4, 5}, {4, 6}, {4, 7}},
              down_mid  = {{4, 4}, {4, 5}, {4, 6}, {4, 7}}}
BALLOM =     {walk_right= {{5, 0}, {5, 1}, {5, 2}},
              walk_down = {{5, 0}, {5, 1}, {5, 2}},
              walk_left = {{5, 3}, {5, 4}, {5, 5}},
              walk_up   = {{5, 3}, {5, 4}, {5, 5}},
              death     = {{5, 6}, {5, 7}, {5, 8}, {5, 9}, {5, 10}}}

ONIL =     {walk_right= {{8, 0}, {8, 1}, {8, 2}},
            walk_down = {{8, 0}, {8, 1}, {8, 2}},
            walk_left = {{8, 3}, {8, 4}, {8, 5}},
            walk_up   = {{8, 3}, {8, 4}, {8, 5}},
            death     = {{8, 6}, {8, 7}, {8, 8}, {8, 9}, {8, 10}}}

DAHL =     {walk_right= {{10, 0}, {10, 1}, {10, 2}},
            walk_down= {{10, 0}, {10, 1}, {10, 2}},
            walk_left= {{10, 3}, {10, 4}, {10, 5}},
            walk_up= {{10, 3}, {10, 4}, {10, 5}},
            death= {{10, 6}, {10, 7}, {10, 8}, {10, 9}, {10, 10}}}
    
MINVO =  {walk_right= {{6, 0}, {6, 1}, {6, 2}},
            walk_down= {{6, 0}, {6, 1}, {6, 2}},
            walk_left= {{6, 3}, {6, 4}, {6, 5}},
            walk_up= {{6, 3}, {6, 4}, {6, 5}},
            death= {{6, 6}, {6, 7}, {6, 8}, {6, 9}, {6, 10}}}

DORIA = { walk_right= {{9, 0}, {9, 1}, {9, 2}},
            walk_down= {{9, 0}, {9, 1}, {9, 2}},
            walk_left= {{9, 3}, {9, 4}, {9, 5}},
            walk_up= {{9, 3}, {9, 4}, {9, 5}},
            death= {{9, 6}, {9, 7}, {9, 8}, {9, 9}, {9, 10}}}

OVAPE = { walk_right= {{11, 0}, {11, 1}, {11, 2}},
            walk_down= {{11, 0}, {11, 1}, {11, 2}},
            walk_left= {{11, 3}, {11, 4}, {11, 5}},
            walk_up= {{11, 3}, {11, 4}, {11, 5}},
            death= {{11, 6}, {11, 7}, {11, 8}, {11, 9}, {11, 10}}}

PASS =   {  walk_right= {{7, 0}, {7, 1}, {7, 2}},
            walk_down= {{7, 0}, {7, 1}, {7, 2}},
            walk_left= {{7, 3}, {7, 4}, {7, 5}},
            walk_up= {{7, 3}, {7, 4}, {7, 5}},
            death= {{7, 6}, {7, 7}, {7, 8}, {7, 9}, {7, 10}}}

PONTAN = {walk_right= {{5, 11}, {6, 11}, {7, 11}, {8, 11}},
            walk_down= {{5, 11}, {6, 11}, {7, 11}, {8, 11}},
            walk_left= {{5, 11}, {6, 11}, {7, 11}, {8, 11}},
            walk_up= {{5, 11}, {6, 11}, {7, 11}, {8, 11}},
            death= {{9, 11}, {5, 7}, {5, 8}, {5, 9}, {5, 10}}}

SPECIALS = {bomb_up= {{3, 8}},
            fire_up= {{3, 9}},
            speed_up= {{3, 10}},
            wall_hack= {{3, 11}},
            remote= {{4, 8}},
            bomb_pass= {{4, 9}},
            flame_pass= {{4, 10}},
            invincible= {{4, 11}},
            exit= {{1, 11}}}

SPECIAL_CONNECTIONS = { bomb_up= "ballom",
                        fire_up= "onil",
                        speed_up= "dahl",
                        wall_hack= "minvo",
                        remote= "doria",
                        bomb_pass= "ovape",
                        flame_pass= "pass",
                        invincible= "pontan",
                        exit= "pontan"}

TIME_WORD  = { time_word = {{13, 4}}}
LEFT_WORD  = { left_word = {{13, 0}}}
STAGE_WORD = { stage_word = {{14, 0}}}

NUMBERS_BLACK = {[0] = {{12, 10}}, [1] = {{12, 11}}, [2] = {{13, 8}},
                 [3] = {{13, 9}},  [4] = {{13, 10}}, [5] = {{13, 11}},
                 [6] = {{14, 8}},  [7] = {{14, 9 }}, [8] = {{14, 10}},
                 [9] = {{14, 11}} }

NUMBERS_WHITE = {[0] = {{12, 10}}, [1] = {{12, 11}}, [2] = {{13, 8}},
                 [3] = {{13, 9}},  [4] = {{13, 10}}, [5] = {{13, 11}},
                 [6] = {{14, 8}},  [7] = {{14, 9 }}, [8] = {{14, 10}},
                 [9] = {{14, 11}} }

SCORE_IMAGES = {[100] = {{12, 6}}, [200] = {{12.5, 11}}, [400] = {{12, 7}},
                 [800] = {{12, 6}}, [1000] = {{12.5, 11}}, [2000] = {{12, 7}},
                 [4000] = {{12, 6}}, [8000] = {{12.5, 11}} }

SCORES = {ballom = 100, onil = 100, dahl = 200, minvo = 200, 
          doria = 400, ovape = 400, pass = 800, pontan = 800}

SOUNDS = {
        'walk_lr.wav',
        'walk_ud.wav',
        'plantbomb.wav',
        'special.wav',
        'dead.wav',
        '6.wav',
        'explosion.wav'
}

MUSIC = {
        'BM-Main-BGM.wav', 
        'BM-Stage-Clear.wav', 
        'BM-Miss.wav',
        'BM-Stage-Start.wav', 
        'BM-Power-Up-Get.wav', 
        'BM-Title-Screen.wav',
        'BM-Special-Power-Up-Get.wav'
}