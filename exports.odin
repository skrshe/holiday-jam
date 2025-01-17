package game

// exports that arent very topical to gameplay

import "core:fmt"
import "core:math/linalg"
import rl "vendor:raylib"

@(export)
game_shutdown :: proc()
{ free(g_mem) }

@(export)
game_shutdown_window :: proc()
{ rl.CloseWindow() }

@(export)
game_memory :: proc() -> rawptr
{ return g_mem }

@(export)
game_memory_size :: proc() -> int
{ return size_of(Game_Memory) }

@(export)
game_hot_reloaded :: proc(mem: rawptr)
{ g_mem = (^Game_Memory)(mem) }

@(export)
game_force_reload :: proc() -> bool
{ return rl.IsKeyPressed(.F5) }

@(export)
game_force_restart :: proc() -> bool
{ return rl.IsKeyPressed(.F6) }

// In a web build, this is called when browser changes size. Remove the
// `rl.SetWindowSize` call if you don't want a resizable game.
game_parent_window_size_changed :: proc(w, h: int)
{ rl.SetWindowSize(i32(w), i32(h)) }
