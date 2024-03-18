package snake

import "core:fmt"
import "core:time"

import SDL "vendor:sdl2"

SNAKE_SPEED :: 0.9


Vector2 :: struct {
    x, y: f32,
}

VEC2LEFT :: Vector2{-1, 0}
VEC2RIGHT :: Vector2{1, 0}
VEC2UP :: Vector2{0, 1}
VEC2DOWN :: Vector2{0, -1}

State :: struct {
    window:     ^SDL.Window,
    renderer:   ^SDL.Renderer,
    texture:    ^SDL.Texture,
    snake:      struct {
                    head_pos, dir:  Vector2,
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

vecMul :: proc(u: ^Vector2, s: f32) {
    u.x *= s
    u.y *= s
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
        NS_PER_SEC :: 1e+9

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
        //vecMul(&state.snake.dir, SNAKE_SPEED)
        vecAdd(&state.snake.head_pos, &state.snake.dir)
        

        for SDL.PollEvent(&event) {
            #partial switch event.type {
                case .KEYDOWN:
                    #partial switch event.key.keysym.sym {
                        case .A, .LEFT, .J:
                            if state.snake.dir == VEC2RIGHT {
                                continue
                            }
                            state.snake.dir = VEC2LEFT
                        case .D, .RIGHT, .L:
                            if state.snake.dir == VEC2LEFT {
                                continue
                            }
                            state.snake.dir = VEC2RIGHT
                        case .S, .DOWN, .K:
                            if state.snake.dir == VEC2UP {
                                continue
                            }
                            state.snake.dir = VEC2DOWN

                            
                        case .W, .UP, .I:
                            if state.snake.dir == VEC2DOWN {
                                continue
                            }
                            state.snake.dir = VEC2UP
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
        SDL.RenderCopyEx(state.renderer, state.texture, nil, nil, 0.0, nil, .NONE)

        SDL.RenderPresent(state.renderer)
        
        
    }

}