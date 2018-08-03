package scenes;

import entities.*;
import flash.system.System;
import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;
import haxepunk.graphics.tile.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.utils.*;
import openfl.Assets;

// TODO: Unload levels

class GameScene extends Scene
{
    public static inline var GAME_WIDTH = 640;
    public static inline var GAME_HEIGHT = 480;
    public static inline var TILE_SIZE = 16;

    private var castle:Map<String, String>;
    private var currentScreenX:Int;
    private var currentScreenY:Int;
    private var entitiesByScreen:Map<String, Array<Entity>>;
    private var player:Player;

    private var buildMode:Bool;
    private var buildModeUI:Entity;
    private var cameraAnchor:Vector2;
    private var lastMouse:Vector2;

    public function new() {
        super();
    }

    public override function begin() {
        castle = [
	        "lvl1/rundotexe4, 4" => "lvl1/tempstart",
			"5, 4" => "lvl1/rundotexe",
			"6, 4" => "lvl1/distantshore2",
			"7, 4" => "lvl1/returnal",
			"8, 4" => "lvl1/departure",
			"9, 4" => "lvl1/hellothere",
			"10, 4" => "lvl1/arrival",
			"11, 4" => "lvl1/voyage",
			"12, 4" => "lvl1/graduate",
			"12, 3" => "lvlmisc/seeyoulater", // NO MUSIC
        ];
        currentScreenX = 12;
        currentScreenY = 4;
        entitiesByScreen = new Map<String, Array<Entity>>();
        player = null;

        buildMode = false;
        buildModeUI = new Entity(new Text("BUILD MODE", {size: 24, color: 0xf940bc}));
        buildModeUI.graphic.scrollX = 0;
        buildModeUI.graphic.scrollY = 0;
        buildModeUI.layer = -99;
        add(buildModeUI);

        lastMouse = new Vector2(Mouse.mouseX, Mouse.mouseY);

        Key.define("quit", [Key.ESCAPE]);
        Key.define("build", [Key.B]);
        loadCurrentScreen();
    }

    private function getCurrentScreenKey() {
        return '${currentScreenX}, ${currentScreenY}';
    }

    private function loadCurrentScreen() {
        var screenData = 'levels/${castle[getCurrentScreenKey()]}.oel';
        var xml = Xml.parse(Assets.getText(screenData));
        var fastXml = new haxe.xml.Fast(xml.firstElement());

        // Add collision mask
        var screenWidth = Std.parseInt(fastXml.node.width.innerData);
        var screenHeight = Std.parseInt(fastXml.node.height.innerData);
        var mask = new Grid(screenWidth, screenHeight, TILE_SIZE, TILE_SIZE);
        var graphic = new Tilemap(
            "graphics/tiles.png", screenWidth, screenHeight, TILE_SIZE, TILE_SIZE
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

        var entities = new Array<Entity>();
        entities.push(walls);

        // Add entities
        if(player == null) {
            for (e in fastXml.node.objects.nodes.player) {
                player = new Player(
                    Std.parseInt(e.att.x), Std.parseInt(e.att.y)
                );
                entities.push(player);
                player.y -= player.height;
            }
        }
        for (e in fastXml.node.objects.nodes.floorspikes) {
            var spike = new Spike(
                Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                Spike.SPIKE_FLOOR, Std.parseInt(e.att.width)
            );
            spike.y -= spike.height;
            entities.push(spike);
        }
        for (e in fastXml.node.objects.nodes.ceilingspikes) {
            var spike = new Spike(
                Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                Spike.SPIKE_CEILING, Std.parseInt(e.att.width)
            );
            entities.push(spike);
        }
        for (e in fastXml.node.objects.nodes.leftwallspikes) {
            var spike = new Spike(
                Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                Spike.SPIKE_LEFT_WALL, Std.parseInt(e.att.height)
            );
            entities.push(spike);
        }
        for (e in fastXml.node.objects.nodes.rightwallspikes) {
            var spike = new Spike(
                Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                Spike.SPIKE_RIGHT_WALL, Std.parseInt(e.att.height)
            );
            spike.x -= spike.width;
            entities.push(spike);
        }
        for (e in fastXml.node.objects.nodes.extraflip) {
            var extraFlip = new ExtraFlip(
                Std.parseInt(e.att.x), Std.parseInt(e.att.y)
            );
            entities.push(extraFlip);
        }
        for (e in fastXml.node.objects.nodes.leftfacinglaser) {
            var laser = new Laser(
                Std.parseInt(e.att.x), Std.parseInt(e.att.y), "left",
                e.att.isOn == "true", Std.parseInt(e.att.switchNumber)
            );
            entities.push(laser);
            entities.push(laser.beam);
        }
        for (e in fastXml.node.objects.nodes.rightfacinglaser) {
            var laser = new Laser(
                Std.parseInt(e.att.x), Std.parseInt(e.att.y), "right",
                e.att.isOn == "true", Std.parseInt(e.att.switchNumber)
            );
            entities.push(laser);
            entities.push(laser.beam);
        }
        for (e in fastXml.node.objects.nodes.downwardfacinglaser) {
            var laser = new Laser(
                Std.parseInt(e.att.x), Std.parseInt(e.att.y), "down",
                e.att.isOn == "true", Std.parseInt(e.att.switchNumber)
            );
            entities.push(laser);
            entities.push(laser.beam);
        }
        for (e in fastXml.node.objects.nodes.upwardfacinglaser) {
            var laser = new Laser(
                Std.parseInt(e.att.x), Std.parseInt(e.att.y), "up",
                e.att.isOn == "true", Std.parseInt(e.att.switchNumber)
            );
            entities.push(laser);
            entities.push(laser.beam);
        }
        for (e in fastXml.node.objects.nodes.lever) {
            var lever = new Lever(
                Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                Std.parseInt(e.att.switchNumber), e.att.flipped == "true"
            );
            entities.push(lever);
        }
        for (e in fastXml.node.objects.nodes.platform) {
            var nodes = new Array<Vector2>();
            // Add the platform's initial position to the list of nodes
            nodes.push(
                new Vector2(Std.parseInt(e.att.x), Std.parseInt(e.att.y))
            );
            // Add the rest of the platform's nodes
            for(n in e.nodes.node) {
                nodes.push(
                    new Vector2(Std.parseInt(n.att.x), Std.parseInt(n.att.y))
                );
            }
            var platform = new Platform(
                Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                Std.parseInt(e.att.width), Std.parseInt(e.att.height), nodes,
                Std.parseInt(e.att.switchNumber)
            );
            entities.push(platform);
        }
        for (e in fastXml.node.objects.nodes.checkpoint) {
            var checkpoint = new Checkpoint(
                Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                e.att.flipped == "true"
            );
            entities.push(checkpoint);
        }

        // Offset entities and add them to the scene
        for(entity in entities) {
            entity.x += currentScreenX * GAME_WIDTH;
            entity.y += currentScreenY * GAME_HEIGHT;
            if(Type.getClass(entity) == Platform) {
                var platform = cast(entity, Platform);
                var nodes = platform.getNodes();
                for(node in nodes) {
                    node.x += currentScreenX * GAME_WIDTH;
                    node.y += currentScreenY * GAME_HEIGHT;
                }
                platform.setNodes(nodes);
            }
            add(entity);
        }
        entities.remove(player);
        entitiesByScreen[getCurrentScreenKey()] = entities;
    }

    public override function update() {
        if(Input.pressed("quit")) {
            System.exit(0);
        }
        if(Input.pressed("build")) {
            buildMode = !buildMode;
        }

        buildModeUI.visible = buildMode;
        if(buildMode) {
            camera.scale += Mouse.mouseWheelDelta * 0.01;
            camera.scale = Math.max(camera.scale, 0.1);
            camera.scale = Math.min(camera.scale, 1);
            if(Mouse.mouseDown) {
                var cameraShift = new Vector2(
                    (Mouse.mouseX - lastMouse.x) * (1/camera.scale),
                    (Mouse.mouseY - lastMouse.y) * (1/camera.scale)
                );
                cameraAnchor.subtract(cameraShift);
            }
            cast(buildModeUI.graphic, Text).scale = 1/camera.scale;
        }
        else {
            camera.scale = 1;
            cameraAnchor = new Vector2(
                currentScreenX * GAME_WIDTH + GAME_WIDTH/2,
                currentScreenY * GAME_HEIGHT + GAME_HEIGHT/2
            );

            // Remove offscreen entities
            for(screenKey in entitiesByScreen.keys()) {
                if(screenKey != getCurrentScreenKey()) {
                    for(entity in entitiesByScreen[screenKey]) {
                        remove(entity);
                    }
                }
            }
        }
        camera.anchor(cameraAnchor);

        // Ensure players and laser beams always update last
        var laserBeams = new Array<Entity>();
        for(e in _update) {
            if(e.name == "player") {
                _update.remove(e);
                _update.add(e);
            }
            if(e.type == "laserbeam") {
                _update.remove(e);
                laserBeams.push(e);
            }
        }
        for(laserBeam in laserBeams) {
            _update.add(laserBeam);
        }

        if(player.centerX <= currentScreenX * GAME_WIDTH) {
            currentScreenX -= 1;
            loadCurrentScreen();
        }
        else if(player.centerX >= (currentScreenX + 1) * GAME_WIDTH) {
            currentScreenX += 1;
            loadCurrentScreen();
        }
        else if(player.centerY <= currentScreenY * GAME_HEIGHT) {
            currentScreenY -= 1;
            loadCurrentScreen();
        }
        else if(player.centerY >= (currentScreenY + 1) * GAME_HEIGHT) {
            currentScreenY += 1;
            loadCurrentScreen();
        }

        super.update();
        lastMouse = new Vector2(Mouse.mouseX, Mouse.mouseY);
    }
}
