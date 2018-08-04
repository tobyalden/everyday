package entities;

import flash.events.Event;
import flash.net.FileReference;
import flash.net.FileFilter;
import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;
import haxepunk.graphics.tile.*;
import haxepunk.input.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import openfl.Assets;
import scenes.GameScene;

class BuildModeUI extends Entity
{
    public var screenPlacer:Graphiclist;
    public var screenPath(default, null):String;
    private var onIndicator:Text;
    private var fileRef:FileReference;

    public function new()
    {
        super(0, 0);
        visible = false;
        layer = -99;
        onIndicator = new Text("BUILD MODE", {size: 24, color: 0xf940bc});
        addGraphic(onIndicator);
        graphic.scrollX = 0;
        graphic.scrollY = 0;
        Key.define("load", [Key.L]);
        screenPlacer = new Graphiclist();
        screenPlacer.add(new ColoredRect(
            GameScene.GAME_WIDTH, GameScene.GAME_HEIGHT, 0x00ff00, 0.5
        ));
        addGraphic(screenPlacer);
        screenPath = null;
    }

    public function echo(message:String) {
        onIndicator.text = message;
        var resetTimer = new Alarm(1, TweenType.OneShot);
        resetTimer.onComplete.bind(function() {
            onIndicator.text = "BUILD MODE";
        });
        addTween(resetTimer);
        resetTimer.start();
    }

    override public function update() {
        if(!visible) {
            super.update();
            return;
        }
        if(Input.pressed("load")) {
            pickScreen();
        }
        super.update();
    }

    public function setScale(newScale:Float) {
        onIndicator.scale = newScale;
    }

    private function pickScreen() {
        fileRef = new FileReference();
        fileRef.addEventListener(Event.SELECT, onFileSelected);
        var oelTypeFilter:FileFilter = new FileFilter(".oel Files", "*.oel");
        fileRef.browse([oelTypeFilter]);
    }
    
    private function onFileSelected(_:Event) {
        var levelDir = Sys.getCwd().split("bin")[0] + "assets/levels/";
        findScreen(levelDir, fileRef.name);
    }

    private function loadScreenToPlace() {
        var xml = Xml.parse(Assets.getText("levels/" + screenPath));
        var fastXml = new haxe.xml.Fast(xml.firstElement());
        var screenWidth = Std.parseInt(fastXml.node.width.innerData);
        var screenHeight = Std.parseInt(fastXml.node.height.innerData);
        var screenPreview = new Tilemap(
            "graphics/debugtiles.png", screenWidth, screenHeight,
            GameScene.TILE_SIZE, GameScene.TILE_SIZE
        );
        for (r in fastXml.node.ground.nodes.rect) {
            screenPreview.setRect(
                Std.int(Std.parseInt(r.att.x) / GameScene.TILE_SIZE),
                Std.int(Std.parseInt(r.att.y) / GameScene.TILE_SIZE),
                Std.int(Std.parseInt(r.att.w) / GameScene.TILE_SIZE),
                Std.int(Std.parseInt(r.att.h) / GameScene.TILE_SIZE)
            );
        }
        screenPreview.smooth = false;
        screenPreview.alpha = 0.5;
        screenPlacer.removeAll();
        screenPlacer.add(screenPreview);
    }

    private function findScreen(directory:String, name:String) {
        if(sys.FileSystem.exists(directory)) {
            for(file in sys.FileSystem.readDirectory(directory)) {
                var path = haxe.io.Path.join([directory, file]);
                if(!sys.FileSystem.isDirectory(path)) {
                    if(file == name) {
                        screenPath = path.split("levels/")[1];
                        loadScreenToPlace();
                    }
                }
                else {
                    var directory = haxe.io.Path.addTrailingSlash(path);
                    findScreen(directory, name);
                }
            }
        }
    }
}
