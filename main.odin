package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"


MAP_TILE_SIZE : i32 = 32;

Map :: struct {
	tilesX : i32,
	tilesY : i32,
};

snapToNearestGridCell :: proc (position : rl.Vector2) -> rl.Vector2 {
	x := int(position.x) + abs((int(position.x) % 32) - 32);
	y := int(position.y) + abs((int(position.y) % 32) - 32);
	return {f32(x), f32(y)};
}

drawGrid :: proc(gameMap: Map, mousePosition : rl.Vector2, texture : rl.Texture2D) {
	using rl;

		for y :i32 = 0; y < gameMap.tilesY; y+=1 {
			for x :i32 = 0; x < gameMap.tilesX; x+=1 {
				DrawRectangle(x*MAP_TILE_SIZE, y*MAP_TILE_SIZE, MAP_TILE_SIZE, MAP_TILE_SIZE, BLUE);
				
				// draw borders
				DrawRectangleLines(x*MAP_TILE_SIZE, y*MAP_TILE_SIZE, MAP_TILE_SIZE, MAP_TILE_SIZE, Fade(DARKBLUE, 0.5));
			}
		}

		pos := snapToNearestGridCell(mousePosition);

		rec1 : Rectangle = {
			0,
			0,
			f32(MAP_TILE_SIZE),
			f32(MAP_TILE_SIZE),
		}

		rec2 : Rectangle = {
			1,
			32,
			f32(MAP_TILE_SIZE) ,
			f32(MAP_TILE_SIZE),
		}
		// The rectangle itself defines the texture to be load ^
		DrawTextureRec(texture, rec1, Vector2({(pos.x-32),(pos.y-32)}), WHITE);
}

main :: proc() {
	using rl;
	InitWindow(800, 450, "hello world");
	HideCursor();	
	gameMap : Map = {};

	gameMap.tilesX = 25;
	gameMap.tilesY = 15;
	camera : Camera2D = {};
	SetTargetFPS(144);

	mousePosition : Vector2 = {-100, 100};


	texture : Texture2D = LoadTexture("assets/atlas.png");
	fmt.println(texture);
	/*
	* TODO:
	*	- Implement sprites
	*	- Rotate camera to give a plane look
	* 	- Implement grid based memory to remember tiles that have been affected
	* 	- Some sort of entity spawn system to place on grid
	*/
	for (!WindowShouldClose()) {
		mousePosition = GetMousePosition();

		BeginMode2D(camera);
		BeginDrawing();
			ClearBackground(WHITE);
			// draw the grid, with the current mouse pos highlighted
			drawGrid(gameMap, mousePosition, texture);

			// fps must be last call to be on top
			DrawFPS(0, 1);

		EndDrawing();
		EndMode2D();
	}

	CloseWindow();
}