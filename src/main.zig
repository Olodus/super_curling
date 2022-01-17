const w4 = @import("wasm4.zig");
const std = @import("std");

//const stone = [8]u8{
//    0b00011000,
//    0b01100110,
//    0b01000010,
//    0b10011001,
//    0b10011001,
//    0b01000010,
//    0b01100110,
//    0b00011000,
//};

const stoneSprite15 = [32]u8{
    0b00000111,0b11000000,
    0b00011000,0b00110000,
    0b00100000,0b00001000,
    0b01000000,0b00000100,
    0b01000000,0b00000100,
    0b10000000,0b00000010,
    0b10000000,0b00000010,
    0b10000001,0b00000010,
    0b10000000,0b00000010,
    0b10000000,0b00000010,
    0b01000000,0b00000100,
    0b01000000,0b00000100,
    0b00100000,0b00001000,
    0b00011000,0b00110000,
    0b00000111,0b11000000,
    0b00000000,0b00000000,
};

const aimSprite = [32]u8{
    0b00000111,0b11000000,
    0b00011001,0b00110000,
    0b00100001,0b00001000,
    0b01000001,0b00000100,
    0b01000001,0b00000100,
    0b10000001,0b00000010,
    0b10000001,0b00000010,
    0b11111111,0b11111110,
    0b10000001,0b00000010,
    0b10000001,0b00000010,
    0b01000001,0b00000100,
    0b01000001,0b00000100,
    0b00100001,0b00001000,
    0b00011001,0b00110000,
    0b00000111,0b11000000,
    0b00000000,0b00000000,
};

const startSprite = [32]u8{
    0b00000111,0b11000000,
    0b00011111,0b11110000,
    0b00111111,0b11111000,
    0b01111111,0b11111100,
    0b01111111,0b11111100,
    0b11111111,0b11111110,
    0b11111111,0b11111110,
    0b11111111,0b11111110,
    0b11111111,0b11111110,
    0b11111111,0b11111110,
    0b01111111,0b11111100,
    0b01111111,0b11111100,
    0b00111111,0b11111000,
    0b00011111,0b11110000,
    0b00000111,0b11000000,
    0b00000000,0b00000000,
};

const handle_length: f32 = 4.0;

pub const Stone = struct {
    in_play: bool = false,
    x: f32,
    y: f32,
    rot: f32,
    dx: f32,
    dy: f32,
    drot: f32,
    radius: f32,
    drag: f32,
    
    pub fn draw(this: @This()) void {
        if (this.in_play) {
            w4.DRAW_COLORS.* = 0x21;
            w4.blit(&stoneSprite15, @floatToInt(i32, this.x - 7.0), @floatToInt(i32, this.y - 7.0), 16, 16, w4.BLIT_1BPP);
            w4.DRAW_COLORS.* = 0x2;
            w4.line(@floatToInt(i32, this.x),
                    @floatToInt(i32, this.y),
                    @floatToInt(i32, this.x + (handle_length * @sin(this.rot))),
                    @floatToInt(i32, this.y + (handle_length * @cos(this.rot)))
            );
        }
    }
};

fn throwStone(stone: *Stone, dx: f32, dy: f32, drot: f32) void {
    stone.in_play = true;
    stone.x = startMark.x;
    stone.y = startMark.y;
    stone.rot = 0.0;
    stone.dx = dx;
    stone.dy = dy;
    stone.drot = drot;
    stone.drag = 0.5;
}

fn updateStone(stone: *Stone) void {
    if (stone.in_play) {
        stone.dx = stone.dx - stone.drag;
        if (@fabs(stone.dx) < 0.5) {
            stone.dx = 0;
        }
        stone.dy = stone.dy - stone.drag;
        if (@fabs(stone.dy) < 0.5) {
            stone.dy = 0;
        }
        stone.drot = stone.drot - stone.drag;
        if (stone.drot < 0.1) {
            stone.drot = 0;
        }
        stone.x = stone.x + stone.dx;
        stone.y = stone.y + stone.dy;
        stone.rot = stone.rot + stone.drot;

        if (stone.x < 0.0 or stone.x > 160.0 or stone.y < 0.0 or stone.y > 160.0) {
            stone.in_play = false;
        }
    }
}
    
var stones = [_]Stone{makeUnplayedStones()} ** 16;
fn makeUnplayedStones() Stone {
    return Stone{
        .in_play = false,
        .x       = 0.0,
        .y       = 0.0,
        .rot     = 0.0,
        .dx      = 0.0,
        .dy      = 0.0,
        .drot    = 0.0,
        .radius  = 7.0,
        .drag    = 0.05,
    };
}

export fn start() void {
    w4.PALETTE.* = .{0xfff6d3, 0xf9a875, 0xeb6b6f, 0x7c3f58};
}

var currentStone: usize = 0;

var cameraY: f32 = 0;

const Mark = struct {
    x: f32,
    y: f32,
    sprite: [*]const u8 = undefined,

    fn draw(this: @This()) void {
        w4.DRAW_COLORS.* = 0x21;
        w4.blit(this.sprite, @floatToInt(i32, this.x - 7.0), @floatToInt(i32, this.y - 7.0), 16, 16, w4.BLIT_1BPP);
    }
};

const startMark = Mark {.x = 80.0, .y = 120.0, .sprite = &startSprite};
var aimMark = Mark {.x = 80.0, .y = 40.0, .sprite = &aimSprite};

const Point = struct {
    x: f32,
    y: f32,
};

var timeout: u32 = 0;

fn handleCollision(a: *Stone, b: *Stone) void {
    a.in_play = true;
    b.in_play = true;
}

fn collision(a: *Stone, b: *Stone) bool {
    const dist_x = a.x - b.x;
    const dist_y = a.y - b.y;
    const dist = @sqrt(std.math.pow(f32, dist_x, 2) + std.math.pow(f32, dist_y, 2));
    if (dist < (a.radius + b.radius)) {
        return true;
    }
    return false;
}

export fn update() void {
    w4.text("Super Curling!", 10, 10);

    timeout = timeout + 1;

    const gamepad = w4.GAMEPAD1.*;
    if (gamepad & w4.BUTTON_1 != 0) {
        if (timeout > 100) {
            timeout = 0;
            const dirX = aimMark.x - startMark.x;
            const dirY = aimMark.y - startMark.y;
            const norm = @sqrt(std.math.pow(f32, dirX, 2) + std.math.pow(f32, dirY, 2));
            const speed = 6.0;
            throwStone(&stones[currentStone], speed * dirX/norm, speed * dirY/norm, 2.2);
            currentStone = @mod(currentStone + 1, 16);
        }
    }
    if (gamepad & w4.BUTTON_2 != 0) {

    }
    if (gamepad & w4.BUTTON_LEFT != 0) {
        aimMark.x = aimMark.x - 1;
    }
    if (gamepad & w4.BUTTON_RIGHT != 0) {
        aimMark.x = aimMark.x + 1;
    }
    if (gamepad & w4.BUTTON_UP != 0) {
        aimMark.y = aimMark.y - 1;
    }
    if (gamepad & w4.BUTTON_DOWN != 0) {
        aimMark.y = aimMark.y + 1;
    }

    for (stones) |*stone| {
        if (stone.in_play) {
            updateStone(stone);
        }
    }
    for (stones) |*stone| {
        if (stone.in_play) {
            for (stones) |*other_stone| {
                if (other_stone.in_play and collision(stone, other_stone)) {
                    w4.text("Press X to blink", 16, 90);
                    handleCollision(stone, other_stone);
                }
            }
        }
    }

    for (stones) |*stone| {
        stone.draw();
    }

    if (timeout > 100) {
        aimMark.draw();
        startMark.draw();
    }

    //w4.text("Press X to blink", 16, 90);
}
