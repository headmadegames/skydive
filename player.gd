extends Node2D

const GRAV = Vector2(0,9.0)
const ACCEL = 5.0
const MAXSPEED = 300.0

var debugEnabled = true
var lift = Vector2(0,0)
var drag = Vector2(0,0)
var mov = Vector2(1,1)
var faceDir = Vector2(1,0)
var isPlayerControlled = true

onready var body = get_node("body")
onready var follower = get_node("follower")
onready var debugLabel = get_node("body/debugLabel")
onready var camera = get_node("body/camera")
onready var trailParticles = get_node("body/trail")

func _fixed_process(delta):
	var speed = mov.length()
	var move2FaceAngle = mov.angle_to(faceDir)
	var dragFac = abs(sin(move2FaceAngle))
	var liftFac = abs(sin(move2FaceAngle*2))
	
	lift = speed * dragFac*dragFac * faceDir#.rotated(PI/2)
	#lift = speed * (abs(sin(mov.angle_to(faceDir)*2)) + 5) * faceDir#.rotated(PI/2)
	drag = speed * dragFac * faceDir.rotated(PI/2)
	mov += (GRAV+lift+drag)*delta
	
	var zoom = max(1, min(4, speed/10))
	camera.set_zoom(Vector2(zoom, zoom))
#	camera.update()
	trailParticles.set_param(Particles2D.PARAM_INITIAL_ANGLE, rad2deg(mov.angle())+270)
	
	var motion = body.move(mov)
	if (body.is_colliding()):
		var n = body.get_collision_normal()
		motion = n.slide(motion)
		body.move(motion)

	if (Input.is_action_pressed("ui_left")):
		faceDir = faceDir.rotated(0.1)
	if (Input.is_action_pressed("ui_right")):
		faceDir = faceDir.rotated(-0.1)
	body.set_rot(faceDir.angle())
	
	if(debugEnabled):
		debugLabel.set_rotation(-body.get_rot())
		debugLabel.set_text("faceDir: " + str(faceDir) + "\nlift: " + str(lift)+ "\ndrag: " + str(drag))
		debugLabel.show()
		update()
	else:
		debugLabel.hide()
	
	follower.set_pos(body.get_pos())
	
func _ready():
	set_fixed_process(true)
#	set_process_input(true)
	
func _on_player_draw():
#	var pos = get_viewport_rect().pos
	var pos = body.get_pos()+Vector2(100,0)
	draw_line(pos, pos+faceDir*20, Color(1,1,1,1), 1)
	draw_line(pos, pos+lift*20, Color(0,1,0,1), 1)
	draw_line(pos, pos+drag*20, Color(0,0,1,1), 1)
	draw_line(pos, pos+GRAV*20, Color(1,0,0,1), 1)
	draw_line(pos, pos+mov*20, Color(1,1,1,1), 1)
