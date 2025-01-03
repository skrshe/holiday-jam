package holidayjam


import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

// --- game

Width   :: 1280
Height  :: 720

frameCounter:= 0

JumpPower :f32= 14
MaxSpd    :f32= 4
G         :f32= 1

keys: i32
win: bool

Player :: struct {
    using pos: rl.Vector2,

    vel:    rl.Vector2,
    spd:    f32,
    in_air: bool,
    health: i32,
}

EnvTypeEnum :: enum i32 {
    none,
    block,
    key,
    lock,
}

EnvType :: union { EnvTypeEnum, i32 }

EnvItem :: struct {
    using rect: rl.Rectangle,

    type:  EnvType,
    hurts: bool,
    color: rl.Color,
}

player: Player


// Map
envItems:= [dynamic]EnvItem {
    // roof
    {{ 300, 175, 680, 10 },   .block, false, rl.GRAY },
    // walls
    {{ 300, 175, 10, 360 },   .block, false, rl.GRAY },
    {{ 980, 175, 10, 300 },   .block, false, rl.GRAY },
    // floor
    {{ 300,   525, 690, 25 }, .block, false, rl.GRAY },
    {{ 700,   465, 50, 10 },  .block, false, rl.GRAY },
    {{ 300,   415, 640, 10 }, .block, false, rl.GRAY },
    {{ 400,   300, 590, 10 }, .block, false, rl.GRAY },
    // key
    {{ 330, 205, 5, 5 },      .key,   false, rl.YELLOW },
    // door
    {{ 980, 477, 10,  46 },   .lock,  false, rl.ORANGE },
    // hurts
    {{ 635, 505, 5, 5 },      .none,  true,  rl.RED },
}

// --- art

Flake :: struct {
    using pos: rl.Vector2,
    tex: rl.Texture,
}

snowArray: [dynamic]Flake

snowTexArray: [2]rl.Texture


main :: proc() {
    using rl

    InitWindow(Width, Height, "Holiday Jam")
    defer CloseWindow()

    SetTargetFPS(60)
    SetExitKey(.KEY_NULL)

    holires:= LoadTexture("res/holiday.png")

    snowTexArray[0] = LoadTexture("res/flake1.png")
    snowTexArray[1] = LoadTexture("res/flake2.png")

    full_reset()

    for !WindowShouldClose() {
        frameCounter += 1

        if IsKeyPressed(.Q) do CloseWindow()

        updateSnow()
        updatePlayer()

        BeginDrawing()
            if win {
                ClearBackground(YELLOW)
                DrawText("you WON!!" , Width / 2 - 50, Height / 2 - 15, 30, ORANGE)
                DrawText("Press [space] to restart" , Width / 2 - 125, Height / 2 + 20, 27, GOLD)

                if IsKeyPressed(.SPACE) do full_reset()
            } else if player.health > 0 {
                ClearBackground(DARKGREEN)

                // DrawTexture(holires, Width/2 - holires.width/2, Height/2 - holires.height/2 - 40, WHITE)

                drawEnv()
                drawPlayer()


                DrawText("Holiday Jam", 2, 1, 1, RAYWHITE)
                DrawText(TextFormat("%v", player.health), Width - 20, 1, 1, RED)
            } else {
                ClearBackground(MAROON)
                DrawText("you DIED" , Width / 2 - 50, Height / 2 - 15, 30, RAYWHITE)
                DrawText("Press [space] to restart" , Width / 2 - 125, Height / 2 + 20, 27, LIGHTGRAY)

                if IsKeyPressed(.SPACE) do full_reset()
            }
            drawSnow()

        EndDrawing()
    }
}

full_reset :: proc() {
    win = false
    player = {
        pos = { 350, 450 },
        vel = {},
        spd = 0,
        health = 10,
        in_air = true,
    }
}

reset_pos :: proc() {
    player.pos = { 350, 450 }
    player.vel = { 0, 0 }
    player.spd = 0
}

// --- Updates

updateSnow :: proc() {
    using rl

    tex:= snowTexArray[GetRandomValue(0,1)]

    if frameCounter % 10 == 0 {
        if len(snowArray) <= 500 do append(
            &snowArray,
            Flake {
                x = f32(GetRandomValue(- tex.width, Width + tex.width)),
                y = - f32(tex.height),
                tex = tex,
            }
        )
    }

    for &flake in snowArray {
        flake.x += f32(GetRandomValue(-5, 5)) / 2
        flake.y += 1 + f32(GetRandomValue(-100, 100)) / 100

        if flake.y > Height {
            flake.x = f32(GetRandomValue(- flake.tex.width, Width + flake.tex.width))
            flake.y = - f32(flake.tex.height)
        }
    }
}

updatePlayer :: proc() {
    using rl
    using player

    //HACK: this should be in  the player struct?
    prect:= Rectangle { x, y - 25, 10, 25 }

    //TODO: jump or jump velocity doesnt reset on reset
    if IsKeyDown(.LEFT)  { vel.x -= MaxSpd }
    if IsKeyDown(.RIGHT) { vel.x += MaxSpd }
    if IsKeyPressed(.H)  { health -= 1 }
    if IsKeyPressed(.B)  { win = true }

    if IsKeyDown(.SPACE) && !in_air {
        spd = -JumpPower
        in_air = true
    }

    if vel.y >  MaxSpd do vel.y =  MaxSpd
    if vel.x >  MaxSpd do vel.x =  MaxSpd
    if vel.y < -MaxSpd do vel.y = -MaxSpd
    if vel.x < -MaxSpd do vel.x = -MaxSpd

    pos += vel
    vel /= {1.13, 1.13}

    if y > Height {
        health -= 1
        reset_pos()
    }

    Collision: bool

    // per item
    for ei in envItems {
        if (
            ei.type == .block &&
            ei.x <= x && ei.x + ei.width >= x &&
            ei.y >= y && ei.y <= y + spd
        ) {
            Collision = true
            spd = 0
            y = ei.y
        }

        if ei.hurts {
            if CheckCollisionRecs(ei, prect) {
                health -= 1
                reset_pos()
            }
        }
    }

    // complete
    if !Collision {
        pos.y += spd
        spd += G
        in_air = true
    } else do in_air = false
}

// --- Draws

drawSnow :: proc() {
    using rl

    for flake in snowArray {
        DrawTexture(flake.tex, i32(flake.x), i32(flake.y), WHITE)
    }
}

drawPlayer :: proc() {
    using rl

    DrawRectangle(i32(player.x), i32(player.y) - 25, 10, 25, GREEN)
    DrawCircleV(player.pos, 3, YELLOW)
}

drawEnv :: proc() {
    using rl

    for ei in envItems {
        using  ei
        DrawRectangleRec(rect, color)
        DrawCircle(i32(rect.x), i32(rect.y), 3, YELLOW)
    }
}
