package scenes;

import com.haxepunk.*;
import com.haxepunk.utils.*;
import com.haxepunk.graphics.*;
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
        var bg = new Entity(0, 0, new Backdrop("graphics/background.png"));
        bg.layer = 100;
        add(bg);

        var level:Level = new Level("levels/cave.tmx");
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
