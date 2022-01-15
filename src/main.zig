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

const handle_length: f32 = 4.0;
const START_X = 80.5;
const START_Y = 30.0;

pub const Stone = struct {
    in_play: bool = false,
    x: f32,
    y: f32,
    rot: f32,
    dx: f32,
    dy: f32,
    drot: f32,
    
    pub fn draw(this: @This()) bool {
        if (this.in_play) {
            w4.DRAW_COLORS.* = 0x21;
            w4.blit(&stoneSprite15, @floatToInt(i32, this.x - 7.0), @floatToInt(i32, this.y - 7.0), 16, 16, w4.BLIT_1BPP);
            w4.DRAW_COLORS.* = 0x2;
            w4.line(@floatToInt(i32, this.x),
                    @floatToInt(i32, this.y),
                    @floatToInt(i32, this.x + (handle_length * @sin(this.rot))),
                    @floatToInt(i32, this.y + (handle_length * @cos(this.rot)))
            );
            return true;
        }
        return false;
    }
};

fn throwStone(stone: *Stone, dx: f32, dy: f32, drot: f32) void {
    stone.in_play = true;
    stone.x = START_X;
    stone.y = START_Y;
    stone.rot = 0.0;
    stone.dx = dx;
    stone.dy = dy;
    stone.drot = drot;
}

fn updateStone(stone: *Stone) bool {
    if (stone.in_play) {
        stone.x = stone.x + stone.dx;
        stone.y = stone.y + stone.dy;
        stone.rot = stone.rot + stone.drot;

        if (stone.x < 0.0 or stone.x > 160.0 or stone.y < 0.0 or stone.y > 160.0) {
            stone.in_play = false;
        }
        return true;
    }
    return false;
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
    };
}

var screen = start;

const Screen = enum {
    start,
    match,
};

export fn start() void {
    w4.PALETTE.* = .{0xfff6d3, 0xf9a875, 0xeb6b6f, 0x7c3f58};
}

var currentStone: usize = 0;

var cameraY: f32 = 0;

export fn update() void {
    //w4.DRAW_COLORS.* = 2;
    w4.text("Super Curling!", 10, 10);

    const gamepad = w4.GAMEPAD1.*;
    if (gamepad & w4.BUTTON_1 != 0) {
        throwStone(&stones[currentStone], 0.5, 0.8, 0.2);
        currentStone = @mod(currentStone + 1, 16);
    }

    switch (screen) {
        start => runStartScreen();
        match => runGameScreen();
    }

    for (stones) |*stone| {
        if(!updateStone(stone)) {
            break;
        }
    }
    for (stones) |*stone| {
        if (stone.draw()) {
            break;
        }
    }

    //w4.text("Press X to blink", 16, 90);
}
