package scenes;

import com.haxepunk.*;
import com.haxepunk.utils.*;
import entities.*;
import flash.system.System;

class GameScene extends Scene
{
    public function new()
    {
        super();
    }

    public override function begin()
    {
        var level:Level = new Level("levels/cave3.tmx");
        add(level);
        for (entity in level.entities) {
            add(entity);
        }

        var wipe = new Wipe(true);
        add(wipe);
    }

    public override function update() {
        if(Input.check(Key.ESCAPE)) {
            System.exit(0);
        }
        super.update();
    }
}
