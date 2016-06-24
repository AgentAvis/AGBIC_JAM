 ///scr_export_tiled_map

var filename = "testExport.json";


if ( global.tileheight == undefined ){
    global.tileheight = 32;
}
if ( global.tilewidth == undefined ){
    global.tilewidth = 32;
}


//for every object in the room, throw into a list
instance_activate_all();

var object_layer = ds_map_create();
var lst_objects = ds_list_create();
var i;
for(i = 0; i < instance_count; i++) {
    var object = instance_id[i];
    show_debug_message(object_get_name(object.object_index));
    if ( object_get_name(object.object_index) != "obj_room_writer"){
        var object_map = ds_map_create();
        ds_map_add(object_map, "id", round(i + 1));
        
        ds_map_add(object_map, "type", object_get_name(instance_id[i].object_index));
        ds_map_add(object_map, "x", object.x - ( object.sprite_xoffset ) );
        ds_map_add(object_map, "y", object.y - ( object.sprite_yoffset) );
        ds_map_add(object_map, "height", object.sprite_height );
        ds_map_add(object_map, "width", object.sprite_width );
        ds_map_add(object_map, "rotation", 0 );
        
        ds_list_add(lst_objects, object_map);
        ds_list_mark_as_map(lst_objects, i);
    }
}


ds_map_add(object_layer, "name", "ObjectLayer1");
ds_map_add(object_layer, "draworder", "topdown");
ds_map_add(object_layer, "type", "objectgroup");
ds_map_add(object_layer, "opacity", 1);
ds_map_add(object_layer, "visible", "true");
ds_map_add(object_layer, "height", ( room_height / global.tileheight ) );
ds_map_add(object_layer, "width", ( room_width / global.tilewidth));
ds_map_add(object_layer, "x", 0);
ds_map_add(object_layer, "y", 0);
var lst_test = ds_list_create();
ds_map_add_list(object_layer, "objects", lst_objects);
var lst_layer = ds_list_create();
ds_list_add(lst_layer, object_layer);
ds_list_mark_as_map(lst_layer, 0);
var tiled_layer = ds_map_create();
ds_map_add(tiled_layer, "height", ( room_height / global.tileheight ) );
ds_map_add_list(tiled_layer, "layers", lst_layer); 
ds_map_add(tiled_layer, "nextobjectid", round(i));
ds_map_add(tiled_layer, "orientation", "orthogonal");
ds_map_add(tiled_layer, "renderorder", "right-down");
ds_map_add(tiled_layer, "version", 1);
ds_map_add(tiled_layer, "tileheight", global.tileheight);
var lst_tileset = ds_list_create();
var lst_properties = ds_map_create();
ds_map_add_list(tiled_layer, "tilesets", lst_tileset);
ds_map_add_map(tiled_layer, "properties", lst_properties);
ds_map_add(tiled_layer, "tilewidth", global.tilewidth);
ds_map_add(tiled_layer, "width", ( room_width / global.tilewidth));
//export to a json map

var str = json_encode(tiled_layer);

var data_file = file_text_open_write(working_directory + filename);
file_text_write_string(data_file, str);
file_text_close(data_file);

ds_map_destroy(tiled_layer);
