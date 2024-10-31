class_name LockLerp
extends CameraControllerBase

@export var box_width: float = 10.0
@export var box_height: float = 10.0
@export var follow_speed: float = 3.5
@export var catchup_speed: float = 4.0
@export var leash_distance: float = 10.0


func _ready() -> void:
	super()
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
	
	if target.velocity.x != 0 or target.velocity.z != 0:
		
		var target_2d_vector: Vector2 = Vector2(target_pos.x, target_pos.z)
		var camera_2d_vector: Vector2 = Vector2(camera_pos.x, camera_pos.z)
		var distance: float = target_2d_vector.distance_to(camera_2d_vector)
	
		var speed_multiplier: float = lerp(1, 6, clamp((distance - leash_distance) / leash_distance, 0, 1))
		var smooth_speed: float = follow_speed * speed_multiplier
		
		global_position = global_position.lerp(target_pos, smooth_speed * delta)
	
	# when target velocity is 0, catch up
	if target.velocity.x == 0:
		global_position.x = lerp(camera_pos.x, target_pos.x, catchup_speed * delta)

	if target.velocity.z == 0:
		global_position.z = lerp(camera_pos.z, target_pos.z, catchup_speed * delta)


func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var left:float = -box_width / 2
	var right:float = box_width / 2
	var top:float = -box_height / 2
	var bottom:float = box_height / 2
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(0, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(0, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(right, 0, 0))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, 0))
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	# mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()
