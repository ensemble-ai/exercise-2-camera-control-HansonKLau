class_name HorizontalAutoScroll
extends CameraControllerBase

@export var box_width: float = 10.0
@export var box_height: float = 10.0
@export var top_left: Vector2
@export var bottom_right: Vector2
@export var autoscroll_speed: Vector3  = Vector3(0.05, 0, 0.05)


func _ready() -> void:
	super()
	top_left = Vector2(target.position.x - box_width, target.position.z + box_height)
	bottom_right = Vector2(target.position.x + box_width, target.position.z - box_height)
	position = target.position


func _process(delta: float) -> void:
	if !current:
		return
	
	if draw_camera_logic:
		draw_logic()
	
	var target_pos: Vector3 = target.global_position
	
	global_position.x += autoscroll_speed.x
	global_position.z += autoscroll_speed.z
	
	var camera_pos: Vector3 = global_position
	
	# keep target inside box
	if target_pos.x <= camera_pos.x - box_width:
		target.global_position.x = camera_pos.x - box_width
	elif target_pos.x >= camera_pos.x + box_width:
		target.global_position.x = camera_pos.x + box_width
	
	if target_pos.z <= camera_pos.z - box_height:
		target.global_position.z = camera_pos.z - box_height
	elif target_pos.z >= camera_pos.z + box_height:
		target.global_position.z = camera_pos.z + box_height
		
	super(delta)


func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(top_left.x, 0, top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(top_left.x, 0, bottom_right.y))
	
	immediate_mesh.surface_add_vertex(Vector3(top_left.x, 0, bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(bottom_right.x, 0, bottom_right.y))
	
	immediate_mesh.surface_add_vertex(Vector3(bottom_right.x, 0, bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(bottom_right.x, 0, top_left.y))
	
	immediate_mesh.surface_add_vertex(Vector3(bottom_right.x, 0, top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(top_left.x, 0, top_left.y))
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	# mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()
