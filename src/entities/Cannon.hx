package entities;

import com.haxepunk.graphics.*;
import com.haxepunk.utils.*;
import com.haxepunk.*;

class Cannon extends ActiveEntity
{

  public static inline var SHOOT_INTERVAL = 100;

  private var orientation:String;
  private var shootTimer:Int;

  public function new(x:Float, y:Float, orientation:String)
  {
    super(x, y);
    type = "walls";
    this.orientation = orientation;
    shootTimer = SHOOT_INTERVAL;
    sprite = new Spritemap("graphics/cannon.png", 32, 32);
    sprite.add("horizontal", [0]);
    sprite.add("vertical", [1]);
    sprite.play(orientation);
    setHitbox(32, 32);
    finishInitializing();
  }

  public override function update()
  {
    super.update();
    shootTimer -= 1;
    if(shootTimer == 0)
    {
      shoot();
      shootTimer = SHOOT_INTERVAL;
    }
  }

  private function shoot()
  {
    if(orientation == "horizontal") {
      if(!isOnLeftWall()) {
        scene.add(new Bullet(x - 32, y, "left"));
      }
      if(!isOnRightWall()) {
        scene.add(new Bullet(x + 32, y, "right"));
      }
    }
    else if(orientation == "vertical") {
      if(!isOnCeiling()) {
        scene.add(new Bullet(x, y - 32, "up"));
      }
      if(!isOnGround()) {
        scene.add(new Bullet(x, y + 32, "down"));
      }
    }
  }
}

