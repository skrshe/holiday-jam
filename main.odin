package holidayjam


import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

// --- game

Width   :: 1280
Height  :: 720

frameCounter:= 0

JumpPower :f32= 14
Gravity   :f32= 1
Speed     :f32= 4

Player :: struct {
    using pos: rl.Vector2,
    vel:    rl.Vector2,
    speed:  f32,
    jump:   bool,
    health: i32,
}

EnvItem :: struct {
    rect:     rl.Rectangle,
    blocking: bool,
    hurts:    bool,
    color:    rl.Color,
}

player: Player

envItems :[dynamic]EnvItem= {
    // roof
    {{ 300, 175, 680, 10 }, true, false,  rl.GRAY },

    // walls
    {{ 300, 175, 10, 360 }, true,  false, rl.GRAY },
    {{ 980, 175, 10, 300 }, true,  false, rl.GRAY },

    // floor
    {{ 300,   525, 690, 25 }, true, false,  rl.GRAY },
    {{ 300,   415, 640, 10 }, false, false,  rl.GRAY },
    {{ 400,   300, 640, 10 }, false, false,  rl.GRAY },

    // danger
    {{ 635, 495, 5, 5 }, true,  true, rl.RED },

    // door
    {{ 980, 477, 10,  46 }, true,  true, rl.ORANGE },

    // key
    {{ 330, 205, 5, 5 }, true,  true, rl.YELLOW },
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

    player.pos = { 955, 330 }
    player.health = 10

    for !WindowShouldClose() {
        frameCounter += 1

        if IsKeyPressed(.Q) do CloseWindow()

        updateSnow()
        updatePlayer()

        BeginDrawing()
            if player.health > 1 {
                ClearBackground(DARKGREEN)

                // DrawTexture(holires, Width/2 - holires.width/2, Height/2 - holires.height/2 - 40, WHITE)

                drawEnv()
                drawPlayer()
                drawSnow()


                DrawText("Holiday Jam", 2, 1, 1, RAYWHITE)
                DrawText(TextFormat("%v", player.health), Width - 20, 1, 1, RED)
            } else {
                ClearBackground(MAROON)
                DrawText("you DIED" , Width / 2 - 50, Height / 2 - 10, 30, RAYWHITE)
            }

        EndDrawing()
    }
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
        flake.y += 1 + f32(GetRandomValue(-100,100)) / 100

        if flake.y > Height {
            flake.x = f32(GetRandomValue(- flake.tex.width, Width + flake.tex.width))
            flake.y = - f32(flake.tex.height)
        }
    }
}

updatePlayer :: proc() {
    using rl

    if IsKeyDown(.LEFT)  { player.vel.x -= Speed }
    if IsKeyDown(.RIGHT) { player.vel.x += Speed }
    if IsKeyPressed(.H) { player.health -= 1 }

    if IsKeyDown(.SPACE) && !player.jump {
        player.speed = -JumpPower
        player.jump = true
    }

    if player.vel.y >  Speed do player.vel.y =  Speed
    if player.vel.x >  Speed do player.vel.x =  Speed
    if player.vel.y < -Speed do player.vel.y = -Speed
    if player.vel.x < -Speed do player.vel.x = -Speed

    player.pos += player.vel
    player.vel /= {1.13, 1.13}

    if player.y > Height {
        player.health -= 1
        player.pos = { 955, 330 }
    }

    Collision: bool
    for i in 0 ..< len(envItems) {
        ei:= &envItems[i]
        p:= player.pos

        if ( ei.blocking &&
            ei.rect.x <= p.x &&
            ei.rect.x + ei.rect.width >= p.x &&
            ei.rect.y >= p.y &&
            ei.rect.y <= p.y + player.speed
        ) {
            Collision = true
            player.speed = 0.0
            p.y = ei.rect.y
        }

        if ei.hurts {
            if CheckCollisionRecs(ei.rect, {p.x, p.y, 10, 25}) {
                player.health -= 1
                player.pos = { 955, 330 }
            }
        }
    }

    if !Collision {
        // if
        player.pos.y += player.speed
        player.speed += Gravity
        player.jump = true


    } else do player.jump = false
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
}

drawEnv :: proc() {
    using rl

    for i in 0..< len(envItems) {
        DrawRectangleRec(envItems[i].rect, envItems[i].color)
    }
}
