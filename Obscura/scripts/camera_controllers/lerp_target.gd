class_name LerpTarget
extends CameraControllerBase

@export var box_width: float = 10.0
@export var box_height: float = 10.0
@export var lead_speed: float = target.BASE_SPEED * 1.5
@export var catchup_delay_duration: float = 0.2
@export var catchup_speed: float = 4.0
@export var leash_distance: float = 15.0

var _current_camera_distance_x: float = 0.0
var _current_camera_distance_z: float = 0.0
var _catchup_wait_timer_x: float = 0.0
var _catchup_wait_timer_z: float = 0.0


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
	
	if target.velocity.x != 0:
		_current_camera_distance_x = lerp(_current_camera_distance_x, leash_distance, delta)
		var lead_offset_x: float = target.velocity.normalized().x * _current_camera_distance_x
		var lead_pos_x: float = target_pos.x + lead_offset_x
		var distance_x: float = abs(camera_pos.x - target_pos.x)
		var speed_multiplier_x: float = lerp(1, 6, clamp((distance_x - leash_distance) / leash_distance, 0, 1))
		var smooth_speed_x: float = lead_speed * speed_multiplier_x
		global_position.x = lerp(global_position.x, lead_pos_x, smooth_speed_x * delta * 0.5)
		_catchup_wait_timer_x = 0.0
	else:
		if _catchup_wait_timer_x > catchup_delay_duration:
			_current_camera_distance_x = lerp(_current_camera_distance_x, 0.0, delta)
			global_position.x = lerp(global_position.x, target_pos.x, catchup_speed * delta)

	if target.velocity.z != 0:
		_current_camera_distance_z = lerp(_current_camera_distance_z, leash_distance, delta)
		var lead_offset_z: float = target.velocity.normalized().z * _current_camera_distance_z
		var lead_pos_z: float = target_pos.z + lead_offset_z
		var distance_z: float = abs(camera_pos.z - target_pos.z)
		var speed_multiplier_z: float = lerp(1, 6, clamp((distance_z - leash_distance) / leash_distance, 0, 1))
		var smooth_speed_z: float = lead_speed * speed_multiplier_z
		global_position.z = lerp(global_position.z, lead_pos_z, smooth_speed_z * delta * 0.5)
		_catchup_wait_timer_z = 0.0
		
	else:
		if _catchup_wait_timer_z > catchup_delay_duration:
			_current_camera_distance_z = lerp(_current_camera_distance_z, 0.0, delta)
			global_position.z = lerp(global_position.z, target_pos.z, catchup_speed * delta)
		
	_catchup_wait_timer_x += delta
	_catchup_wait_timer_z += delta
	

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
