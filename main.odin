package snake

import "core:fmt"
import "core:time"

import SDL "vendor:sdl2"

NS_PER_SEC :: 1e+9
SNAKE_SPEED: f32: 0.000001 

directions :: enum {
    LEFT,
    RIGHT,
    UP,
    DOWN
}


Vector2 :: struct {
    x, y: f32,
}

LEFT:   Vector2:    Vector2{-1, 0}
RIGHT:  Vector2:    Vector2{1, 0}
UP:     Vector2:    Vector2{0, 1}
DOWN:   Vector2:    Vector2{0, -1}




State :: struct {
    window:     ^SDL.Window,
    renderer:   ^SDL.Renderer,
    texture:    ^SDL.Texture,
    snake:      struct {
                    head_pos, dir:  Vector2,
                    diren:          directions,
                    },

    time:       struct {
                    last_second:    i64,
                    last_frame:     i64,
                    delta_ns:       i64,
                    delta:          f32,
                    frames:         i32,
                    fps:            i32,
    },
}

vecAdd :: proc(u, v: ^Vector2) {
    u.x += v.x
    u.y += v.y
}

vecMul :: proc(u: ^Vector2, s: f32) -> Vector2{
    return Vector2{u.x*s, u.y*s}
}


main :: proc() {
    fmt.println("hello, snake")

    // initialize game state
    state: State

    // create window
    state.window = SDL.CreateWindow("SNAKES AND LADDERS WITHOUT THE LADDERS", 100, 200, 800, 800, {})
    if state.window == nil {
        fmt.eprintln("window bad")
        return
    }
    defer SDL.DestroyWindow(state.window)

    // create renderer
    state.renderer = SDL.CreateRenderer(state.window, -1, {.ACCELERATED})
    if state.renderer == nil {
        fmt.eprintln("renderer bad")
        return
    }
    defer SDL.DestroyRenderer(state.renderer)

    // create texture/backbuffer
    state.texture = SDL.CreateTexture(state.renderer, u32(SDL.PixelFormatEnum.RGBA8888), .TARGET, 512, 512)
    if state.texture == nil {
        fmt.eprintln("texture bad")
        return
    }
    defer SDL.DestroyTexture(state.texture)







    event: SDL.Event
    loop: for {
        

        now := time.to_unix_nanoseconds(time.now())

        state.time.delta_ns = now - state.time.last_frame
        state.time.delta = f32(state.time.delta_ns) / NS_PER_SEC
        state.time.last_frame = now
        state.time.frames += 1

        // update fps count
        if now - state.time.last_second > NS_PER_SEC {
            state.time.last_second = now
            state.time.fps = state.time.frames
            state.time.frames = 0
            fmt.printf("FPS: %v\n", state.time.fps)
        }
        
        // update snake
        state.snake.dir.x *= SNAKE_SPEED * state.time.delta
        state.snake.dir.y *= SNAKE_SPEED * state.time.delta
        vecAdd(&state.snake.head_pos, &state.snake.dir)

        fmt.println(state.snake.head_pos)



        for SDL.PollEvent(&event) {
            #partial switch event.type {
                case .KEYDOWN:
                    #partial switch event.key.keysym.sym {
                        case .A, .LEFT, .J:
                            if state.snake.diren == directions.RIGHT {
                                continue
                            }
                            state.snake.diren = directions.LEFT
                            state.snake.dir = LEFT

                        case .D, .RIGHT, .L:
                            if state.snake.diren == directions.LEFT {
                                continue
                            }
                            state.snake.diren = directions.RIGHT
                            state.snake.dir = RIGHT

                        case .S, .DOWN, .K:
                            if state.snake.diren == directions.UP {
                                continue
                            }
                            state.snake.diren = directions.DOWN
                            state.snake.dir = DOWN

                        case .W, .UP, .I:
                            if state.snake.diren == directions.DOWN {
                                continue
                            }
                            state.snake.diren = directions.UP
                            state.snake.dir = UP
                    }
                case .QUIT:
                    break loop
            }
        
        
        } 


        SDL.SetRenderTarget(state.renderer, state.texture)

        SDL.SetRenderDrawColor(state.renderer, 0, 0, 0, 0xff)
        SDL.RenderClear(state.renderer)

        SDL.SetRenderDrawColor(state.renderer, 0xff, 0, 0xff, 0xff)
        SDL.RenderFillRect(state.renderer, &SDL.Rect{i32(state.snake.head_pos.x), i32(state.snake.head_pos.y), 32, 32})


        // draw texture to screen
        SDL.SetRenderTarget(state.renderer, nil)
        SDL.RenderCopyEx(state.renderer, state.texture, nil, nil, 0.0, nil, .VERTICAL)

        SDL.RenderPresent(state.renderer)
        
        
    }

}