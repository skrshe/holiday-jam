package game

// snow

import rl "vendor:raylib"

Flake :: struct {
    using pos: Vec2,
    tex: Tex,
}

snowArray: [dynamic]Flake

snowTexArray: [2]Tex

updateSnow :: proc() {
    using rl

    tex:= snowTexArray[GetRandomValue(0,1)]

    if g_mem.framecount % 10 == 0 {
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

drawSnow :: proc() {
    using rl

    for flake in snowArray {
        DrawTexture(flake.tex, i32(flake.x), i32(flake.y), WHITE)
    }
}
