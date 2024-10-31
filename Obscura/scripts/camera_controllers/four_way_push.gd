class_name FourWayPush
extends CameraControllerBase

@export var box_width: float = 10.0
@export var box_height: float = 10.0
@export var push_ratio: float = 4;
@export var pushbox_top_left: Vector2;
@export var pushbox_bottom_right: Vector2;
@export var speedup_zone_top_left: Vector2;
@export var speedup_zone_bottom_right: Vector2;


func _ready() -> void:
	super()
	speedup_zone_top_left = Vector2(target.position.x - (box_width / 2), target.position.z + (box_height / 2))
	speedup_zone_bottom_right = Vector2(target.position.x + (box_width / 2), target.position.z - (box_height / 2))
	pushbox_top_left = Vector2(target.position.x - box_width, target.position.z + box_height)
	pushbox_bottom_right = Vector2(target.position.x + box_width, target.position.z - box_height)
	position = target.position


func _process(delta: float) -> void:
	if !current:
		return
	
	if draw_camera_logic:
		draw_logic()
	
	super(delta)


func _physics_process(delta: float) -> void:
	var target_pos: Vector3 = target.global_position
	var camera_pos: Vector3 = global_position
	
	# boundary checks
	
	var diff_between_left_edges: float = (target_pos.x - target.WIDTH / 2.0) - (camera_pos.x - box_width)
	
	# left - speed
	if diff_between_left_edges > 0 and diff_between_left_edges < (box_width / 2):
		
		if target.velocity.x < 0:
			var speed_multiplier: float = lerp(1, 6, clamp((diff_between_left_edges - (box_width / 1.5)) / (box_width / 1.5), 0, 1))
			var smooth_speed: float = push_ratio * speed_multiplier
			global_position.x = lerp(camera_pos.x, target_pos.x, smooth_speed * delta)
	
	# left - push
	elif diff_between_left_edges < 0:
		global_position.x += diff_between_left_edges
		
		
	var diff_between_right_edges: float = (target_pos.x + target.WIDTH / 2.0) - (camera_pos.x + box_width)
	
	# right - speed
	if diff_between_right_edges < 0 and diff_between_right_edges > -(box_width / 2):
		
		if target.velocity.x > 0:
			var speed_multiplier: float = lerp(1, 6, clamp((diff_between_right_edges - (box_width / 1.5)) / (box_width / 1.5), 0, 1))
			var smooth_speed: float = push_ratio * speed_multiplier
			global_position.x = lerp(camera_pos.x, target_pos.x, smooth_speed * delta)
	
	# right - push
	elif diff_between_right_edges > 0:
		global_position.x += diff_between_right_edges
		
		
	var diff_between_top_edges: float = (target_pos.z - target.HEIGHT / 2.0) - (camera_pos.z - box_height)	
	
	# top - speed
	if diff_between_top_edges > 0 and diff_between_top_edges < (box_height / 2):
	
		if target.velocity.z < 0:
			var speed_multiplier: float = lerp(1, 6, clamp((diff_between_top_edges - (box_height / 1.5)) / (box_height / 1.5), 0, 1))
			var smooth_speed: float = push_ratio * speed_multiplier
			global_position.z = lerp(camera_pos.z, target_pos.z, smooth_speed * delta)
	
	# top - push
	elif diff_between_top_edges < 0:
		global_position.z += diff_between_top_edges
		
		
	var diff_between_bottom_edges: float = (target_pos.z + target.HEIGHT / 2.0) - (camera_pos.z + box_height)
	
	# bottom - speed
	if diff_between_bottom_edges < 0 and diff_between_bottom_edges > -(box_height / 2):
		
		if target.velocity.z > 0:
			var speed_multiplier: float = lerp(1, 6, clamp((diff_between_bottom_edges - (box_height / 1.5)) / (box_height / 1.5), 0, 1))
			var smooth_speed: float = push_ratio * speed_multiplier
			global_position.z = lerp(camera_pos.z, target_pos.z, smooth_speed * delta)
	
	# bottom - push
	elif diff_between_bottom_edges > 0:
		global_position.z += diff_between_bottom_edges


func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var speed_material := ORMMaterial3D.new()
	var push_material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var left: float = -box_width / 2
	var right: float = box_width / 2
	var top: float = -box_height / 2
	var bottom: float = box_height / 2
	
	# speed up zone
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, speed_material)
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_top_left.x, 0, speedup_zone_top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_top_left.x, 0, speedup_zone_bottom_right.y))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_top_left.x, 0, speedup_zone_bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_bottom_right.x, 0, speedup_zone_bottom_right.y))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_bottom_right.x, 0, speedup_zone_bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_bottom_right.x, 0, speedup_zone_top_left.y))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_bottom_right.x, 0, speedup_zone_top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_top_left.x, 0, speedup_zone_top_left.y))
	immediate_mesh.surface_end()
	
	# push box
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, push_material)
	immediate_mesh.surface_add_vertex(Vector3(pushbox_top_left.x, 0, pushbox_top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_top_left.x, 0, pushbox_bottom_right.y))
	
	immediate_mesh.surface_add_vertex(Vector3(pushbox_top_left.x, 0, pushbox_bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_bottom_right.x, 0, pushbox_bottom_right.y))
	
	immediate_mesh.surface_add_vertex(Vector3(pushbox_bottom_right.x, 0, pushbox_bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_bottom_right.x, 0, pushbox_top_left.y))
	
	immediate_mesh.surface_add_vertex(Vector3(pushbox_bottom_right.x, 0, pushbox_top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_top_left.x, 0, pushbox_top_left.y))
	immediate_mesh.surface_end()
	
	speed_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	speed_material.albedo_color = Color.GRAY
	
	push_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	push_material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	#mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()
