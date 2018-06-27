package scenes;

import entities.*;
import flash.system.System;
import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.utils.*;
import openfl.Assets;

class GameScene extends Scene
{
    public static inline var GAME_WIDTH = 640;
    public static inline var GAME_HEIGHT = 480;
    public static inline var TILE_SIZE = 16;

    public function new()
    {
        super();
    }

    public override function begin()
    {
        camera.anchor(new Vector2(GAME_WIDTH/2, GAME_HEIGHT/2));
        Key.define("quit", [Key.ESCAPE]);
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
        for (e in fastXml.node.objects.nodes.player) {
            var player = new Player(
                Std.parseInt(e.att.x), Std.parseInt(e.att.y)
            );
			add(player);
            player.y -= player.height;
        }
        for (e in fastXml.node.objects.nodes.floorspikes) {
            var spike = new Spike(
                Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                Spike.SPIKE_FLOOR, Std.parseInt(e.att.width)
            );
            spike.y -= spike.height;
            add(spike);
        }
        for (e in fastXml.node.objects.nodes.ceilingspikes) {
            var spike = new Spike(
                Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                Spike.SPIKE_CEILING, Std.parseInt(e.att.width)
            );
            add(spike);
        }
        for (e in fastXml.node.objects.nodes.leftwallspikes) {
            var spike = new Spike(
                Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                Spike.SPIKE_LEFT_WALL, Std.parseInt(e.att.height)
            );
            add(spike);
        }
        for (e in fastXml.node.objects.nodes.rightwallspikes) {
            var spike = new Spike(
                Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                Spike.SPIKE_RIGHT_WALL, Std.parseInt(e.att.height)
            );
            spike.x -= spike.width;
            add(spike);
        }
        for (e in fastXml.node.objects.nodes.extraflip) {
            var extraFlip = new ExtraFlip(
                Std.parseInt(e.att.x), Std.parseInt(e.att.y)
            );
            add(extraFlip);
        }
        for (e in fastXml.node.objects.nodes.platform) {
            var platform = new Platform(
                Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                Std.parseInt(e.att.width), Std.parseInt(e.att.height)
            );
            add(platform);
        }
    }

    public override function update() {
        if(Input.check("quit")) {
            System.exit(0);
        }
        super.update();
    }
}
