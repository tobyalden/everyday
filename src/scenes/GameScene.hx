package scenes;

import entities.*;
import flash.system.System;
import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.utils.*;
import openfl.Assets;

class GameScene extends Scene
{
    public static inline var TILE_SIZE = 16;

    public function new()
    {
        super();
    }

    public override function begin()
    {
        Key.define("quit", [Key.ESCAPE]);

        var bg = new Entity(0, 0, new Backdrop("graphics/background.png"));
        bg.layer = 100;
        add(bg);

        loadLevel("levels/cave.oel");
    }

    private function loadLevel(level:String) {
        var xml = Xml.parse(Assets.getText(level));
        var fastXml = new haxe.xml.Fast(xml.firstElement());

        // Add collision mask
        var levelWidth = Std.parseInt(fastXml.node.width.innerData);
        var levelHeight = Std.parseInt(fastXml.node.height.innerData);
        var mask = new Grid(levelWidth, levelHeight, TILE_SIZE, TILE_SIZE);
        var graphic = new Tilemap(
            "graphics/tiles.png", levelWidth, levelHeight, TILE_SIZE, TILE_SIZE
        );
        for (r in fastXml.node.ground.nodes.rect) {
            mask.setRect(
                Std.int(Std.parseInt(r.att.x) / TILE_SIZE),
                Std.int(Std.parseInt(r.att.y) / TILE_SIZE),
                Std.int(Std.parseInt(r.att.w) / TILE_SIZE),
                Std.int(Std.parseInt(r.att.h) / TILE_SIZE)
            );
            graphic.setRect(
                Std.int(Std.parseInt(r.att.x) / TILE_SIZE),
                Std.int(Std.parseInt(r.att.y) / TILE_SIZE),
                Std.int(Std.parseInt(r.att.w) / TILE_SIZE),
                Std.int(Std.parseInt(r.att.h) / TILE_SIZE)
            );
        }
        graphic.loadFromString(
            mask.saveToString(",", "\n", "0", "1")
        );
        graphic.smooth = false;
        var walls = new Entity(0, 0, graphic, mask);
        walls.type = "walls";
        add(walls);

        // Add entities
        for (p in fastXml.node.objects.nodes.player) {
			add(new Player(Std.parseInt(p.att.x), Std.parseInt(p.att.y)));
        }
    }

    public override function update() {
        if(Input.check("quit")) {
            System.exit(0);
        }
        super.update();
    }
}
