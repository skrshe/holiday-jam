package game

import rl "vendor:raylib"

JumpPower :f32= 14
MaxSpd    :f32= 4
G         :f32= 1

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

// :reset
reset_full :: proc() {
    using g_mem

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
    using g_mem

    player.pos = { 350, 450 }
    player.vel = { 0, 0 }
    player.spd = 0
}

updatePlayer :: proc() {
    using rl
    using g_mem.player

    // HACK: this should be in  the player struct?
    prect:= Rectangle { x, y - 25, 10, 25 }

    // TODO: jump or jump velocity doesnt reset on reset
    if IsKeyDown(.LEFT)  { vel.x -= MaxSpd }
    if IsKeyDown(.RIGHT) { vel.x += MaxSpd }
    if IsKeyPressed(.H)  { health -= 1 }
    if IsKeyPressed(.B)  { g_mem.win = true }

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
    for ei in g_mem.game_map {
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

drawPlayer :: proc() {
    using rl
    using g_mem

    DrawRectangle(i32(player.x), i32(player.y) - 25, 10, 25, GREEN)
    DrawCircleV(player.pos, 3, YELLOW)
}

drawEnv :: proc() {
    using rl

    for ei in g_mem.game_map {
        using  ei
        DrawRectangleRec(rect, color)
        DrawCircle(i32(rect.x), i32(rect.y), 3, YELLOW)
    }
}
