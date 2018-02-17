package entities;

import com.haxepunk.*;
import com.haxepunk.utils.*;
import com.haxepunk.graphics.*;

class Spring extends Entity
{
    public static inline var BOUNCE_SQUASH = 0.1;
    public static inline var BOUNCE_STRETCH = 1.5;
    public static inline var SQUASH_RECOVERY = 0.05;

    private var sprite:Image;

    public function new(x:Float, y:Float)
    {
        super(x, y);
        type = "spring";
        sprite = new Image("graphics/spring.png");
        sprite.smooth = false;
        graphic = sprite;
        setHitbox(8, 7, 0, -1);
    }

    public function bounce() {
        scaleY(BOUNCE_SQUASH);
    }

    public override function update()
    {
        if(sprite.scaleY < 1) {
            scaleY(Math.min(sprite.scaleY + SQUASH_RECOVERY, 1));
        }
        super.update();
    }

    private function scaleY(newScaleY:Float) {
        // Scales sprite vertically upwards
        sprite.scaleY = newScaleY;
        sprite.originY = height - (height / sprite.scaleY);
    }
}

