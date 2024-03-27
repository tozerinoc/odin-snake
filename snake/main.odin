package snake

import "core:fmt"
import "core:time"

import SDL "vendor:sdl2"
import TTF "vendor:sdl2/ttf"

NS_PER_SEC :: 1e+9
NS_PER_FRAME :: 4.166666e+6
SNAKE_SPEED: f32: 0.05
WINDOWX :: 900
WINDOWY :: 900
SNAKEHEADSIZE :: 2


Direction :: enum { LEFT, RIGHT, UP, DOWN }

Vector2 :: struct {
    x, y: f32,
}

State :: struct {
    window:     ^SDL.Window,
    renderer:   ^SDL.Renderer,
    texture:    ^SDL.Texture,
    
    text:       struct {
                    font:           ^TTF.Font,
                    surface:        ^SDL.Surface,
                    texture:        ^SDL.Texture,
    },

    snake:      struct {
                    head_pos:       Vector2,
                    dir:            Direction,
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

vecMul :: proc(u: ^Vector2, s: f32) -> Vector2 {
    v := Vector2{x= u.x*s, y= u.y*s}
    return v
}

vecAdd :: proc(u, v: ^Vector2) -> Vector2 {
    w := Vector2{x = u.x+v.x, y = u.y+v.y}
    return w
}

main :: proc() {

    using Direction
    fmt.println("hello, snake")

    // initialize game state
    state: State
    TTF.Init()

    defer SDL.DestroyWindow(state.window)
    defer SDL.DestroyRenderer(state.renderer)
    defer SDL.DestroyTexture(state.texture)
    defer TTF.CloseFont(state.text.font)
    defer SDL.FreeSurface(state.text.surface)
    defer SDL.DestroyTexture(state.text.texture)

    // create window
    state.window = SDL.CreateWindow("SNAKES AND LADDERS WITHOUT THE LADDERS", 20, 0, WINDOWX, WINDOWY, {SDL.WindowFlag.BORDERLESS})
    if state.window == nil {
        fmt.eprintln("window bad")
        fmt.eprintln(SDL.GetError())
        return
    }

    // create renderer
    state.renderer = SDL.CreateRenderer(state.window, -1, {.ACCELERATED})
    if state.renderer == nil {
        fmt.eprintln("renderer bad")
        fmt.eprintln(SDL.GetError())
        return
    }

    // create texture/backbuffer
    state.texture = SDL.CreateTexture(state.renderer, u32(SDL.PixelFormatEnum.RGBA8888), .TARGET, WINDOWX / 75, WINDOWY / 75)
    if state.texture == nil {
        fmt.eprintln("texture bad")
        fmt.eprintln(SDL.GetError())
        return
    }

    state.text.font = TTF.OpenFont("./uni05_53.ttf", 10)
    if state.text.font == nil {
        fmt.eprintln("text font bad")
        fmt.eprintln(TTF.GetError())
        return
    }


    
    


    state.snake.dir = .RIGHT


    event: SDL.Event
    loop: for {

        now := time.to_unix_nanoseconds(time.now())

        state.time.delta_ns = now - state.time.last_frame
        state.time.delta = f32(state.time.delta_ns) / NS_PER_SEC
        state.time.last_frame = now
        state.time.frames += 1

        
        // set fps == 240
        SDL.Delay(2)

        // update fps count
        if now - state.time.last_second > NS_PER_SEC {
            state.time.last_second = now
            state.time.fps = state.time.frames
            state.time.frames = 0
            fmt.printf("FPS: %v\n", state.time.fps)
        }


        #partial switch state.snake.dir {
            case .LEFT:
                state.snake.head_pos.x -= 1 * SNAKE_SPEED
            case .RIGHT:
                state.snake.head_pos.x += 1 * SNAKE_SPEED
            case .UP:
                state.snake.head_pos.y += 1 * SNAKE_SPEED
            case .DOWN:
                state.snake.head_pos.y -= 1 * SNAKE_SPEED
        }

        //loop the snake for the borders of the screen
        if      state.snake.head_pos.x > WINDOWX / 75 {
            state.snake.head_pos.x = -(SNAKEHEADSIZE / 2)
        
        } else if state.snake.head_pos.y > WINDOWY / 75 {
            state.snake.head_pos.y = -(SNAKEHEADSIZE / 2)
        
        } else if state.snake.head_pos.x < -(SNAKEHEADSIZE / 2) {
            state.snake.head_pos.x = WINDOWX / 75
        
        } else if state.snake.head_pos.y < -(SNAKEHEADSIZE / 2) {
            state.snake.head_pos.y = WINDOWY / 75
        
        }


        state.text.surface = TTF.RenderText_Solid(state.text.font, fmt.caprintf("FPS: %v", state.time.fps), SDL.Color{0xFF, 0xFF, 0xFF, 0xFF})
        if state.text.surface == nil {
            fmt.eprintln("text surface bad")
            fmt.eprintln(TTF.GetError())
            return
        }

        state.text.texture = SDL.CreateTextureFromSurface(state.renderer, state.text.surface)
        if state.text.texture == nil {
            fmt.eprintln("text texture bad")
            fmt.eprintln(SDL.GetError())
            return
        }


        for SDL.PollEvent(&event) {
            #partial switch event.type {
                case .KEYDOWN:
                    #partial switch event.key.keysym.sym {
                        case .A, .LEFT, .J:
                            if state.snake.dir == .RIGHT {
                                continue
                            }
                            state.snake.dir = .LEFT

                        case .D, .RIGHT, .L:
                            if state.snake.dir == .LEFT {
                                continue
                            }
                            state.snake.dir = .RIGHT

                        case .S, .DOWN, .K:
                            if state.snake.dir == .UP {
                                continue
                            }
                            state.snake.dir = .DOWN

                        case .W, .UP, .I:
                            if state.snake.dir == .DOWN {
                                continue
                            }
                            state.snake.dir = .UP

                        case .ESCAPE:
                            break loop
                    }
                case .QUIT:
                    break loop
            }
        } 
        
        

        SDL.SetRenderTarget(state.renderer, state.texture)
        
        SDL.SetRenderDrawColor(state.renderer, 0, 0, 0, 0xff)
        SDL.RenderClear(state.renderer)

        SDL.SetRenderDrawColor(state.renderer, 0x13, 0x54, 0x27, 0xff)
        SDL.RenderFillRect(state.renderer, &SDL.Rect{i32(state.snake.head_pos.x), i32(state.snake.head_pos.y), SNAKEHEADSIZE, SNAKEHEADSIZE})

        // draw texture to screen
        SDL.SetRenderTarget(state.renderer, nil)
        SDL.RenderCopyEx(state.renderer, state.texture, nil, nil, 0.0, nil, .VERTICAL)

        SDL.SetRenderTarget(state.renderer, state.text.texture)
        SDL.RenderCopy(state.renderer, state.text.texture, nil, &SDL.Rect{0,0, 80, 40})

        SDL.RenderPresent(state.renderer)
        
        
    }

}
