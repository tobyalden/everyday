package entities;

import com.haxepunk.graphics.*;
import com.haxepunk.utils.*;
import com.haxepunk.*;

class Bullet extends ActiveEntity
{

  public static inline var SPEED = 5;

  private var direction:String;

  public function new(x:Float, y:Float, direction:String)
  {
    super(x, y);
    this.direction = direction;
    sprite = new Spritemap("graphics/bullet.png", 32, 32);
    sprite.add("up", [0]);
    sprite.add("down", [1]);
    sprite.add("left", [2]);
    sprite.add("right", [3]);
    sprite.add("explode", [4, 5, 6, 7, 8], 21, false);
    sprite.play(direction);
    setHitbox(32, 32);
    type = "hazard";
    finishInitializing();
  }

  public override function update()
  {
    if(sprite.currentAnim == "explode") {
      if(sprite.complete) {
        scene.remove(this);
      }
      return;
    }
    if(direction == "up") {
      velocity.y = -SPEED;
    }
    else if(direction == "down") {
      velocity.y = SPEED;
    }
    else if(direction == "left") {
      velocity.x = -SPEED;
    }
    else if(direction == "right") {
      velocity.x = SPEED;
    }

    moveBy(velocity.x, velocity.y);

    var collideWith:Entity = collide("walls", x, y);
    if(collideWith != null)
    {
      velocity.x = 0;
      velocity.y = 0;
      sprite.play("explode");
    }

  }
}

