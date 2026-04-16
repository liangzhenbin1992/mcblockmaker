@tool
class_name Generator

const TEXTURE_SHEET_WIDTH := 8
const TEXTURE_TILE_SIZE := 1.0 / TEXTURE_SHEET_WIDTH
const HALF := Vector3(-0.5, -0.5, -0.5)

enum BlockType { SKIP, NORMAL, TRANSPARENT, CROSS }

static func generate(config: Dictionary) -> bool:
	var save_dir: String = config.get("output_dir", "res://gridmap_assets/")
	var blocks: Array = config.get("blocks", [])
	var texture_path: String = config.get("texture_path", "")
	
	if texture_path.is_empty():
		push_error("未选择纹理图片！")
		return false
	
	if not ResourceLoader.exists(texture_path):
		push_error("纹理图片不存在: " + texture_path)
		return false
	
	DirAccess.make_dir_recursive_absolute(save_dir)
	
	var meshes: Dictionary = {}
	var valid_count := 0
	
	for i in range(64):
		if i >= blocks.size():
			break
		var block_type: int = blocks[i]
		if block_type == BlockType.SKIP:
			continue
		
		var mesh: Mesh
		if block_type == BlockType.CROSS:
			mesh = _create_cross_mesh(i, texture_path)
		else:
			var transparent := (block_type == BlockType.TRANSPARENT)
			mesh = _create_cube_mesh(i, transparent, texture_path)
		
		if mesh:
			meshes[i] = mesh
			var mesh_path := save_dir + "block_%d.tres" % i
			ResourceSaver.save(mesh, mesh_path)
			valid_count += 1
	
	if meshes.is_empty():
		push_warning("没有选择任何方块类型，未生成资源。")
		return false
	
	_create_mesh_library(meshes, blocks, save_dir, texture_path)
	print("MCBlockMaker: 资源生成完成！共生成 %d 个方块，保存至: %s" % [valid_count, save_dir])
	return true


static func _create_cross_mesh(block_id: int, texture_path: String) -> Mesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var uvs := _calculate_uvs(block_id)
	var normal_a := Vector3(-1, 0, 1).normalized()
	var normal_b := Vector3(1, 0, -1).normalized()
	var normal_c := Vector3(1, 0, 1).normalized()
	var normal_d := Vector3(-1, 0, -1).normalized()
	
	_add_cross_face(st,
		HALF + Vector3(0, 1, 0), HALF + Vector3(0, 0, 0),
		HALF + Vector3(1, 1, 1), HALF + Vector3(1, 0, 1),
		uvs, normal_a)
	_add_cross_face(st,
		HALF + Vector3(1, 1, 1), HALF + Vector3(1, 0, 1),
		HALF + Vector3(0, 1, 0), HALF + Vector3(0, 0, 0),
		uvs, normal_b)
	_add_cross_face(st,
		HALF + Vector3(0, 1, 1), HALF + Vector3(0, 0, 1),
		HALF + Vector3(1, 1, 0), HALF + Vector3(1, 0, 0),
		uvs, normal_c)
	_add_cross_face(st,
		HALF + Vector3(1, 1, 0), HALF + Vector3(1, 0, 0),
		HALF + Vector3(0, 1, 1), HALF + Vector3(0, 0, 1),
		uvs, normal_d)
	
	st.generate_tangents()
	st.index()
	var mesh := st.commit()
	
	var mat := _create_material(true, texture_path)
	mesh.surface_set_material(0, mat)
	return mesh


static func _create_cube_mesh(block_id: int, transparent: bool, texture_path: String) -> Mesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var uvs := _calculate_uvs(block_id)
	
	_add_face(st, [HALF + Vector3(0,1,0), HALF + Vector3(0,0,0), HALF + Vector3(0,1,1), HALF + Vector3(0,0,1)], uvs, Vector3.LEFT)
	_add_face(st, [HALF + Vector3(1,1,1), HALF + Vector3(1,0,1), HALF + Vector3(1,1,0), HALF + Vector3(1,0,0)], uvs, Vector3.RIGHT)
	_add_face(st, [HALF + Vector3(1,1,0), HALF + Vector3(1,0,0), HALF + Vector3(0,1,0), HALF + Vector3(0,0,0)], uvs, Vector3.FORWARD)
	_add_face(st, [HALF + Vector3(0,1,1), HALF + Vector3(0,0,1), HALF + Vector3(1,1,1), HALF + Vector3(1,0,1)], uvs, Vector3.BACK)
	_add_face(st, [HALF + Vector3(1,0,0), HALF + Vector3(1,0,1), HALF + Vector3(0,0,0), HALF + Vector3(0,0,1)], uvs, Vector3.DOWN)
	_add_face(st, [HALF + Vector3(0,1,0), HALF + Vector3(0,1,1), HALF + Vector3(1,1,0), HALF + Vector3(1,1,1)], uvs, Vector3.UP)
	
	st.generate_tangents()
	st.index()
	var mesh := st.commit()
	
	var mat := _create_material(transparent, texture_path)
	mesh.surface_set_material(0, mat)
	return mesh


static func _add_face(st: SurfaceTool, verts: Array[Vector3], uvs: Array[Vector2], normal: Vector3) -> void:
	st.set_normal(normal)
	st.set_uv(uvs[1]); st.add_vertex(verts[1])
	st.set_uv(uvs[2]); st.add_vertex(verts[2])
	st.set_uv(uvs[3]); st.add_vertex(verts[3])
	st.set_uv(uvs[2]); st.add_vertex(verts[2])
	st.set_uv(uvs[1]); st.add_vertex(verts[1])
	st.set_uv(uvs[0]); st.add_vertex(verts[0])


static func _add_cross_face(st: SurfaceTool, v0: Vector3, v1: Vector3, v2: Vector3, v3: Vector3, uvs: Array[Vector2], normal: Vector3) -> void:
	st.set_normal(normal)
	st.set_uv(uvs[1]); st.add_vertex(v1)
	st.set_uv(uvs[2]); st.add_vertex(v2)
	st.set_uv(uvs[3]); st.add_vertex(v3)
	st.set_uv(uvs[2]); st.add_vertex(v2)
	st.set_uv(uvs[1]); st.add_vertex(v1)
	st.set_uv(uvs[0]); st.add_vertex(v0)


static func _calculate_uvs(block_id: int) -> Array[Vector2]:
	@warning_ignore("integer_division")
	var row := block_id / TEXTURE_SHEET_WIDTH
	var col := block_id % TEXTURE_SHEET_WIDTH
	return [
		TEXTURE_TILE_SIZE * Vector2(col + 0.01, row + 0.01),
		TEXTURE_TILE_SIZE * Vector2(col + 0.01, row + 0.99),
		TEXTURE_TILE_SIZE * Vector2(col + 0.99, row + 0.01),
		TEXTURE_TILE_SIZE * Vector2(col + 0.99, row + 0.99),
	]


static func _create_material(transparent: bool, texture_path: String) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	if transparent:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	else:
		mat.cull_mode = BaseMaterial3D.CULL_BACK
	mat.albedo_texture = load(texture_path)
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	mat.texture_repeat = false
	return mat


static func _create_preview_texture(block_id: int, texture_path: String) -> ImageTexture:
	var source_tex: Texture2D = load(texture_path)
	var image := source_tex.get_image()
	if image.is_compressed():
		image.decompress()
	@warning_ignore("integer_division")
	var row := block_id / TEXTURE_SHEET_WIDTH
	var col := block_id % TEXTURE_SHEET_WIDTH
	var tile_size := image.get_width() / TEXTURE_SHEET_WIDTH
	var tile_image := image.get_region(Rect2i(col * tile_size, row * tile_size, tile_size, tile_size))
	return ImageTexture.create_from_image(tile_image)


static func _create_mesh_library(meshes: Dictionary, blocks: Array, save_dir: String, texture_path: String) -> void:
	var library := MeshLibrary.new()
	var item_index := 0
	
	var sorted_ids := meshes.keys()
	sorted_ids.sort()
	
	for block_id in sorted_ids:
		var mesh: Mesh = meshes[block_id]
		var block_type: int = blocks[block_id] if block_id < blocks.size() else BlockType.NORMAL
		
		library.create_item(item_index)
		library.set_item_mesh(item_index, mesh)
		library.set_item_name(item_index, "block_%d" % block_id)
		library.set_item_preview(item_index, _create_preview_texture(block_id, texture_path))
		
		if block_type == BlockType.CROSS:
			library.set_item_shapes(item_index, [])
		else:
			var shape := BoxShape3D.new()
			shape.extents = Vector3(0.5, 0.5, 0.5)
			library.set_item_shapes(item_index, [shape])
		
		item_index += 1
	
	ResourceSaver.save(library, save_dir + "voxel_mesh_library.tres")
	print("MCBlockMaker: MeshLibrary 已保存，包含 %d 个项目" % item_index)
