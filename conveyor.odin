package main 

import "core:fmt"
import "core:container/intrusive/list"
import rl "vendor:raylib"

conveyorPath :: struct {
  node: list.Node,
  value: int,
}

conveyorPaths : [dynamic]^conveyorPath;

getDirectionVector :: proc(dir : Direction) -> rl.Vector2 {
  switch(dir) {
    case .LEFT, .RIGHT:
      return {32, 0};
    case .UP, .DOWN: 
      return {0, 32};
  }
  return {0, 0};
}

onConveyorAdded :: proc(conveyor : ^Entity) {
    // so we need to do this backwards or else we endup doing some silly bits of recursion. 
    // or do we?
    // so if we have a conveyor array

    // update the target to your direction.
    // tell the neighbours to update
    
    // check direction + 1 tile
    checkDirVec : rl.Vector2;
    dir := getDirectionVector(conveyor.direction);
    switch(conveyor.direction) {
      case .LEFT, .UP:
        checkDirVec = conveyor.position - dir;
      case .RIGHT, .DOWN:
        checkDirVec = conveyor.position + dir;
    }

    toTile := conveyors[checkDirVec];
    if toTile != nil {
      conveyor.target = toTile;
    }
    
    // now tell the neighbours to update their totile, and check if their direction points towards the new tile
    updateNeighbour(conveyor);
    fmt.println("end func")
    
    for c, cObj in conveyors {
      fmt.print(c);
      fmt.print(" ");
      fmt.println(cObj);
    }

}

updateNeighbour :: proc(from : ^Entity) {
  for direction in Direction {
    updateNeighbourFromDir(from, direction);
  }
}

updateNeighbourFromDir :: proc(from : ^Entity, dir : Direction) {
    // so now we look at the neighbour up from the placed tile.
    // if there is a conveyor there then we check it's direction.
    // if its direction points towards the from 
    // we update the neighbours target to point at the from. 
    checkDirVec : rl.Vector2;
    dirVec := getDirectionVector(dir);

    switch(dir) {
      case .LEFT, .UP:
        checkDirVec = from.position - dirVec;
      case .RIGHT, .DOWN:
        checkDirVec = from.position + dirVec;
      }

    neighbour := conveyors[checkDirVec];

    comparison_dir : Direction
    switch (dir) {
      case .LEFT:
        comparison_dir = .RIGHT;
      case .RIGHT:
        comparison_dir = .LEFT;
      case .DOWN: 
        comparison_dir = .UP;
      case .UP:
        comparison_dir = .DOWN;
    }

    if neighbour != nil && neighbour.spriteId == .SPRITE_BELT && neighbour.direction == comparison_dir {
      neighbour.target = from;
    }
}

moveConveyorItems :: proc() {
  // let
}

drawConveyorPath :: proc() {
  // getting a segfault on 2 downs???
  for cPos, conveyor in conveyors {
    // draw a line from to to
    if (conveyor.target != nil) {
      rl.DrawLine(i32(conveyor.position.x), i32(conveyor.position.y), i32(conveyor.target.position.x), i32(conveyor.target.position.y), rl.GREEN);
    }
  }
}