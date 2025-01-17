package game

import "core:fmt"
import "core:math/linalg"
import rl "vendor:raylib"

HeightPx :: 180

Width  :: 1280
Height :: 720

Game_Memory :: struct {
    game_map: [dynamic]EnvItem,
    player:   Player,
	framecount:    int,
    keys:     int,
    win:      bool,
}

g_mem: ^Game_Memory

game_camera :: proc() -> Cam2D {
    using rl
    using g_mem

	w := f32(GetScreenWidth())
	h := f32(GetScreenHeight())

	return {
		zoom = h/HeightPx,
		target = player.pos,
		offset = { w/2, h/2 },
	}
}

ui_camera :: proc() -> Cam2D {
	return { zoom = f32(
        rl.GetScreenHeight(),
    ) / HeightPx }
}

update :: proc() {
    using rl

	input: Vec2

    updateSnow()
    updatePlayer()

    snowTexArray[0] = LoadTexture("res/flake1.png")
    snowTexArray[1] = LoadTexture("res/flake2.png")

    g_mem.game_map = {
        // roof
        {{ 300, 175, 680, 10 },   .block, false, rl.GRAY },
        // walls
        {{ 300, 175, 10, 360 },   .block, false, rl.GRAY },
        {{ 980, 175, 10, 300 },   .block, false, rl.GRAY },
        // floor
        {{ 300,   525, 690, 25 }, .block, false, rl.GRAY },
        {{ 300,   415, 640, 10 }, .block, false, rl.GRAY },
        {{ 400,   300, 590, 10 }, .block, false, rl.GRAY },
        // step
        {{ 330,   350, 50, 10 },  .block, false, rl.GRAY },
        {{ 700,   465, 50, 10 },  .block, false, rl.GRAY },
        // key
        {{ 330, 205, 5, 5 },      .key,   false, rl.YELLOW },
        // door
        {{ 980, 477, 10,  46 },   .lock,  false, rl.ORANGE },
        // hurts
        {{ 635, 505, 5, 5 },      .none,  true,  rl.RED },
    }



	input = linalg.normalize0(input)
	g_mem.player.pos += input * GetFrameTime() * 100
	g_mem.framecount += 1
}

draw :: proc() {
    using rl
    using g_mem

	BeginDrawing()
	    ClearBackground(GREEN)

	    BeginMode2D(game_camera())
            BeginDrawing()
                if win {
                    ClearBackground(YELLOW)
                    DrawText("you WON!!" , Width / 2 - 50, Height / 2 - 15, 30, ORANGE)
                    DrawText("Press [space] to restart" , Width / 2 - 125, Height / 2 + 20, 27, GOLD)

                    if IsKeyPressed(.SPACE) do reset_full()
                } else if player.health > 0 {
                    ClearBackground(DARKGREEN)

                    // DrawTexture(holires, Width/2 - holires.width/2, Height/2 - holires.height/2 - 40, WHITE)

                    drawEnv()
                    drawPlayer()


                } else {
                    ClearBackground(MAROON)
                    DrawText("you DIED" , Width / 2 - 50, Height / 2 - 15, 30, RAYWHITE)
                    DrawText("Press [space] to restart" , Width / 2 - 125, Height / 2 + 20, 27, LIGHTGRAY)

                    if IsKeyPressed(.SPACE) do reset_full()
                }
                drawSnow()

	    EndMode2D()

	    BeginMode2D(ui_camera())
            DrawText(
                TextFormat(
                    "framecount: %v\nplayer_pos: %v",
                    framecount,
                    player.pos
                ), 5, 5, 15, WHITE,
            )

            DrawText("Holiday Jam", Height - 20, 1, 1, RAYWHITE)
            DrawText(TextFormat("%v", player.health), Width - 20, 1, 1, RED)
        EndMode2D()

	EndDrawing()
}

@(export)
game_update :: proc() -> bool {
	update()
	draw()
	return !rl.WindowShouldClose()
}

@(export)
game_init_window :: proc() {
    using rl

	SetConfigFlags({ .WINDOW_RESIZABLE, .VSYNC_HINT })
	InitWindow(1280, 720, "my hot odin-rl template!")
	SetWindowPosition(200, 200)
	SetTargetFPS(500)
}

@(export)
game_init :: proc() {
    using rl

	g_mem = new(Game_Memory)

	g_mem^ = Game_Memory {
        framecount = 0,

		// You can put textures, sounds and music in the `res (resource)` folder. Those
		// files will be part any release or web build.
		//player_texture = LoadTexture("res/round_cat.png"),
	}


    holires:= LoadTexture("res/holiday.png")


    reset_full()

	game_hot_reloaded(g_mem)
}
