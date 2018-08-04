package scenes;

import entities.*;
import flash.system.System;
import haxe.Serializer;
import haxe.Unserializer;
import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;
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

    private var castle:Map<String, String>;
    private var currentScreenX:Int;
    private var currentScreenY:Int;
    private var entitiesByScreen:Map<String, Array<Entity>>;
    private var player:Player;

    private var buildModeUI:BuildModeUI;
    private var cameraAnchor:Vector2;
    private var lastMouse:Vector2;

    public function new() {
        super();
    }

    public override function begin() {
        var castlePath = (
            Sys.getCwd().split("bin")[0] + "assets/levels/castle.txt"
        );
        castle = Unserializer.run(sys.io.File.getContent(castlePath));
        currentScreenX = 12;
        currentScreenY = 4;
        entitiesByScreen = new Map<String, Array<Entity>>();
        player = null;

        buildModeUI = new BuildModeUI();
        add(buildModeUI);

        lastMouse = new Vector2(Mouse.mouseX, Mouse.mouseY);

        Key.define("quit", [Key.ESCAPE]);
        Key.define("build", [Key.B]);
        Key.define("savecastle", [Key.S]);
        loadCurrentScreen();
    }

    private function getScreenKey(screenX:Int, screenY:Int) {
        return '${screenX}, ${screenY}';
    }

    private function getCurrentScreenKey() {
        return getScreenKey(currentScreenX, currentScreenY);
    }

    private function loadCurrentScreen() {
        loadScreen(currentScreenX, currentScreenY);
    }

    private function loadScreen(screenX:Int, screenY:Int, wallsOnly:Bool = false) {
        var screenKey = getScreenKey(screenX, screenY);
        if(!castle.exists(screenKey)) {
            trace("No screen with this key found in castle.");
            return;
        }
        if(entitiesByScreen.exists(screenKey)) {
            trace("Screen already loaded.");
            return;
        }
        var screenData = 'levels/${castle[screenKey]}';
        var xml = Xml.parse(Assets.getText(screenData));
        var fastXml = new haxe.xml.Fast(xml.firstElement());

        // Add collision mask
        var screenWidth = Std.parseInt(fastXml.node.width.innerData);
        var screenHeight = Std.parseInt(fastXml.node.height.innerData);
        var mask = new Grid(screenWidth, screenHeight, TILE_SIZE, TILE_SIZE);
        var graphic = new Tilemap(
            "graphics/tiles.png", screenWidth, screenHeight,
            TILE_SIZE, TILE_SIZE
        );
        for (r in fastXml.node.ground.nodes.rect) {
            mask.setRect(
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

        if(wallsOnly) {
            walls.x += screenX * GAME_WIDTH;
            walls.y += screenY * GAME_HEIGHT;
            entitiesByScreen[screenKey] = [walls];
            add(walls);
            return;
        }

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
            entity.x += screenX * GAME_WIDTH;
            entity.y += screenY * GAME_HEIGHT;
            if(Type.getClass(entity) == Platform) {
                var platform = cast(entity, Platform);
                var nodes = platform.getNodes();
                for(node in nodes) {
                    node.x += screenX * GAME_WIDTH;
                    node.y += screenY * GAME_HEIGHT;
                }
                platform.setNodes(nodes);
            }
            add(entity);
        }
        entities.remove(player);
        entitiesByScreen[screenKey] = entities;
    }

    public function loadAllScreens() {
        for(screenKey in castle.keys()) {
            var screenX = Std.parseInt(screenKey.split(", ")[0]);
            var screenY = Std.parseInt(screenKey.split(", ")[1]);
            loadScreen(screenX, screenY, true);
        }
    }

    public override function update() {
        if(Input.pressed("quit")) {
            System.exit(0);
        }
        if(Input.pressed("build")) {
            buildModeUI.visible = !buildModeUI.visible;
            if(buildModeUI.visible) {
                loadAllScreens();
            }
        }

        if(buildModeUI.visible) {
            buildMode();
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
                    entitiesByScreen.remove(screenKey);
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

    private function buildMode() {
        // Camera controls
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
        buildModeUI.setScale(1/camera.scale);

        // Updating screen placer
        buildModeUI.screenPlacer.x = (
            Math.round(
                (camera.x + Mouse.mouseX * (1/camera.scale) - GAME_WIDTH/2)
                / GAME_WIDTH
            ) * GAME_WIDTH
        );
        buildModeUI.screenPlacer.y = (
            Math.round(
                (camera.y + Mouse.mouseY * (1/camera.scale) - GAME_HEIGHT/2)
                / GAME_HEIGHT
            ) * GAME_HEIGHT
        );

        // Placing screens
        if(Mouse.rightMousePressed && buildModeUI.screenPath != null) {
            var screenX = Std.int(buildModeUI.screenPlacer.x / GAME_WIDTH);
            var screenY = Std.int(buildModeUI.screenPlacer.y / GAME_HEIGHT);
            var screenKey = getScreenKey(screenX, screenY);
            castle.set(screenKey, buildModeUI.screenPath);
            for(entity in entitiesByScreen[screenKey]) {
                remove(entity);
            }
            entitiesByScreen.remove(screenKey);
            loadScreen(screenX, screenY);
        }

        if(Input.pressed("savecastle")) {
            var castlePath = (
                Sys.getCwd().split("bin")[0] + "assets/levels/castle.txt"
            );
            sys.io.File.saveContent(castlePath, Serializer.run(castle));
            buildModeUI.echo("CASTLE SAVED!");
        }
    }
}
