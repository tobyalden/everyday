package entities;

import com.haxepunk.*;
import com.haxepunk.graphics.*;
import com.haxepunk.tmx.*;

class Level extends TmxEntity
{
    public static inline var TILE_SIZE = 8;

    public static inline var PLAYER = 17;
    public static inline var SPIKE_FLOOR = 21;
    public static inline var SPIKE_CEILING = 22;
    public static inline var SPIKE_LEFT_WALL = 23;
    public static inline var SPIKE_RIGHT_WALL = 24;

    public var entities:Array<Entity>;

    public function new(filename:String)
    {
        super(filename);
        entities = new Array<Entity>();
        loadGraphic("graphics/tiles.png", ["main"]);
        loadMask("collision_mask", "walls");
        map = TmxMap.loadFromFile(filename);
        for(entity in map.getObjectGroup("entities").objects) {
            if(entity.gid == PLAYER) {
                entities.push(new Player(entity.x, entity.y));
            }
            else if(entity.gid == SPIKE_FLOOR) {
                entities.push(
                    new Spike(entity.x, entity.y - TILE_SIZE, entity.gid)
                );
            }
            else if(entity.gid == SPIKE_CEILING) {
                entities.push(
                    new Spike(entity.x, entity.y - TILE_SIZE, entity.gid)
                );
            }
            else if(entity.gid == SPIKE_LEFT_WALL) {
                entities.push(new Spike(entity.x, entity.y, entity.gid));
            }
            else if(entity.gid == SPIKE_RIGHT_WALL) {
                entities.push(new Spike(entity.x, entity.y, entity.gid));
            }
        }
    }

    override public function loadGraphic(
        tileset:String, layerNames:Array<String>, skip:Array<Int> = null
    )
    {
        // We override this to set tilemap.smooth to false below
        var gid:Int, layer:TmxLayer;
        for (name in layerNames)
        {
            if (map.layers.exists(name) == false)
            {
                continue;
            }
            layer = map.layers.get(name);
            var spacing = map.getTileMapSpacing(name);

            var tilemap = new Tilemap(
                tileset, map.fullWidth, map.fullHeight, map.tileWidth,
                map.tileHeight, spacing, spacing
            );
            tilemap.smooth = false;

            // Loop through tile layer ids
            for (row in 0...layer.height)
            {
                for (col in 0...layer.width)
                {
                    gid = layer.tileGIDs[row][col] - 1;
                    if (gid < 0) continue;
                    if (skip == null || Lambda.has(skip, gid) == false)
                    {
                        tilemap.setTile(col, row, gid);
                    }
                }
            }
            addGraphic(tilemap);
        }
    }
}
