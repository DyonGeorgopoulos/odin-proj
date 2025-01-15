package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"
import rlgl "vendor:raylib/rlgl"

MAP_TILE_SIZE: i32 = 32

Global :: struct {
	direction : Direction
}

Direction :: enum {
	DOWN = 0,
	LEFT = 1,
	RIGHT = 2,
	UP = 3,
}

DIRECTION_DEGREE : []int = {
	0,
	90,
	180,
	270,
} 

Mode :: enum {
	BUILD,
}

Map :: struct {
	tilesX: i32,
	tilesY: i32,
}

Animation :: struct {
	numFrames:    int,
	frameTimer:   f32,
	offset:		  rl.Vector2,
	animTexture:  ^rl.Texture2D,
	currentFrame: int,
	frameLength:  f32,
}

Entity :: struct {
	animation: Animation,
	position:  rl.Vector2,
}

/**
	GLOBALS
*/ 
global : Global = {}

// will eventually need an inventory
// lets do some cleanup 

snapToNearestGridCell :: proc(position: rl.Vector2) -> rl.Vector2 {
	x := i32(position.x) + abs((i32(position.x) % MAP_TILE_SIZE) - MAP_TILE_SIZE)
	y := i32(position.y) + abs((i32(position.y) % MAP_TILE_SIZE) - MAP_TILE_SIZE)
	return {f32(x), f32(y)}
}

drawGrid :: proc(gameMap: Map) {
	using rl

	for y: i32 = 0; y < gameMap.tilesY; y += 1 {
		for x: i32 = 0; x < gameMap.tilesX; x += 1 {
			DrawRectangle(x * MAP_TILE_SIZE, y * MAP_TILE_SIZE, MAP_TILE_SIZE, MAP_TILE_SIZE, BLUE)

			// draw borders
			DrawRectangleLines(
				x * MAP_TILE_SIZE,
				y * MAP_TILE_SIZE,
				MAP_TILE_SIZE,
				MAP_TILE_SIZE,
				Fade(DARKBLUE, 0.5),
			)
		}
	}
}

calculateAnimationRect :: proc(entity: ^Entity) -> rl.Rectangle {
	animationWidth := f32(entity.animation.animTexture.width)
	animationHeight := f32(entity.animation.animTexture.height)

	// increase animation timer
	entity.animation.frameTimer += rl.GetFrameTime()


	// if the timer exceeds configured animation timer
	if entity.animation.frameTimer > entity.animation.frameLength {
		entity.animation.currentFrame += 1
		entity.animation.frameTimer = 0
		if entity.animation.currentFrame == entity.animation.numFrames {
			entity.animation.currentFrame = 0
		}
	}

	sourceEntityRect := rl.Rectangle {
		x 	   	= f32(entity.animation.currentFrame) * animationWidth / f32(entity.animation.numFrames),
		y		= 0,
		width  	= animationWidth / f32(entity.animation.numFrames),
		height 	= animationHeight,
	}

	return sourceEntityRect;
}

handleInput :: proc() {
	if rl.IsKeyPressed(rl.KeyboardKey.R) {
		global.direction = Direction((int(global.direction) + 1) % (len(Direction)))
	}
}

drawEntites :: proc(entities : ^[]Entity) {

	// loop through entities & draw them 
	// This will be placed entities on the grid & all their information.
	// for example:
	// for each entity in entities: 
	// 		calculate animation rect
	// 		draw src + dst
	for &entity in entities^ {
		srcRect := calculateAnimationRect(&entity); 

		dstRect := rl.Rectangle {
			x      = entity.position.x,
			y      = entity.position.y,
			width  = f32(entity.animation.animTexture.width * 2) / f32(entity.animation.numFrames),
			height = f32(entity.animation.animTexture.height * 2),
		}
		rl.DrawTexturePro(entity.animation.animTexture^, srcRect, dstRect, 0, 0, rl.WHITE);
	}
}


drawCursor :: proc(mode : Mode, entity : ^Entity) {

	if mode == .BUILD {
		entity.position = snapToNearestGridCell(rl.GetMousePosition());
		srcRect := calculateAnimationRect(entity);
		dstRect := rl.Rectangle {
			x      = entity.position.x-16,
			y      = entity.position.y-16,
			width  = f32(entity.animation.animTexture.width * 2) / f32(entity.animation.numFrames),
			height = f32(entity.animation.animTexture.height * 2),
		}

		rotation := f32(DIRECTION_DEGREE[int(global.direction)])

		// some notes ->
		// if a single 
		rl.DrawTexturePro(entity.animation.animTexture^, srcRect, dstRect, {16, 32+16}, rotation, rl.WHITE);
	}

}

main :: proc() {
	using rl
	InitWindow(800, 450, "BELT")
	// HideCursor()
	gameMap: Map = {}

	gameMap.tilesX = 30
	gameMap.tilesY = 20
	camera: Camera2D = {}
	SetTargetFPS(144)

	mousePosition: Vector2 = {-100, 100}


	texture: Texture2D = LoadTexture("assets/atlas.png")
	compactor: Texture2D = LoadTexture("assets/compactor_idle.png")
	storage: Texture2D = LoadTexture("assets/tunnel-in_idle.png");

	/*
	* TODO:
	*	- Implement sprites
	*	- Rotate camera to give a plane look
	* 	- Implement grid based memory to remember tiles that have been affected
	* 	- Some sort of entity spawn system to place on grid
	*/

	// create an animation for the compactor:
	compactorEntity : Entity = {
		animation = {
		numFrames    = int(compactor.width / 16),
			frameTimer   = 0,
			animTexture  = &compactor,
			offset 		= {0, 16},
			currentFrame = 0,
			frameLength  = 0.1,
		},
		position = {0, 0}
	}

	mode : Mode = .BUILD;
	for (!WindowShouldClose()) {
		mousePosition = GetMousePosition()

		// logic
		handleInput();

		BeginMode2D(camera)
		BeginDrawing()
		ClearBackground(WHITE)
		// draw the grid, with the current mouse pos highlighted
		drawGrid(gameMap)
		drawCursor(mode, &compactorEntity);

		// fps must be last call to be on top
		DrawFPS(0, 1)

		EndDrawing()
		EndMode2D()
	}

	CloseWindow()
}
