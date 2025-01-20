package main 

import "core:fmt"
import rl "vendor:raylib"


getDirectionVector :: proc(dir : Direction) -> rl.Vector2 {
  switch(dir) {
    case .LEFT, .RIGHT:
      return {32, 0};
    case .UP, .DOWN: 
      return {0, 32};
  }
  return {0, 0};
}

conveyorTick :: proc() {
    // so we need to do this backwards or else we endup doing some silly bits of recursion. 
    // or do we?
    // so if we have a conveyor array


    // [conv1 = {0, 1, item, DOWN}, conv2 = {0, 2, item, DOWN}, conv3 = {1, 3, item, DOWN}, conv4 = {0, 3, RIGHT}]
    // so step by step here
    // for conveyor in conveyors 
    //      

    fmt.println(conveyors);
    for beltPos, belt in conveyors {
      // so for each conveyor we need to see if DIRECTION + NEXT SQUARE = a spot in the conveyor map 
      //
      // check direction + 1 tile
      checkDirVec : rl.Vector2;
      dir := getDirectionVector(belt.direction);
      switch(belt.direction) {
        case .LEFT, .UP:
          checkDirVec = beltPos - dir;
        case .RIGHT, .DOWN:
          checkDirVec = beltPos + dir;
      }
      // also need to check that it's not opposite
      // TODO: Fix the check for -> right to UP 
      // same for left to down -> ther/es some weird vector math, need to run a debugger
      fmt.println(checkDirVec)
      if checkDirVec in conveyors {
        // we must offload the item
        fmt.println("i see a belt in front of me")
      }

      if belt.conveyor.inventory.item != nil {
        // we have to sort out offloading the item

      }
    }
    fmt.println("end func")
}