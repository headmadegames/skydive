extends Node2D

const GRAV = Vector2(0,9.0)
const ACCEL = 5.0
const MAXSPEED = 30.0

var debugEnabled = false
var crashed = false
var isPlayerControlled = true
var isCloseToObstacle = false
var lift = Vector2(0,0)
var drag = Vector2(0,0)
var mov = Vector2(1,1)
var faceDir = Vector2(1,0)
var dragFac = 0
var liftFac = 0
var speedFac = 0
var windSound
var alarmSound

onready var body = get_node("body")
onready var follower = get_node("follower")
onready var debugLabel = get_node("body/debugLabel")
onready var camera = get_node("body/camera")
onready var trailParticles = get_node("body/trail")
onready var soundPlayer = get_node("follower/SamplePlayer2D")

func _ready():
	set_fixed_process(true)
#	set_process_input(true)
	
	# init step sounds
	var sample = soundPlayer.get_sample_library().get_sample("wind")
	sample.set_loop_format(sample.LOOP_FORWARD)
	sample.set_loop_begin(0)
	sample.set_loop_end(sample.get_length())
	windSound = soundPlayer.play("wind")
	soundPlayer.voice_set_volume_scale_db(windSound, -60);
	soundPlayer.voice_set_pitch_scale(windSound, 0.5)

	sample = soundPlayer.get_sample_library().get_sample("alarm")
	sample.set_loop_format(sample.LOOP_FORWARD)
	sample.set_loop_begin(0)
	sample.set_loop_end(sample.get_length())
	alarmSound = soundPlayer.play("alarm")
	soundPlayer.voice_set_volume_scale_db(alarmSound, -100);
#	soundPlayer.voice_set_pitch_scale(alarmSound, 0.5)
	
func _fixed_process(delta):
	if crashed:
		return
		
	var speed = mov.length()
	var move2FaceAngle = mov.angle_to(faceDir)
	dragFac = 0.1+pow(abs(sin(move2FaceAngle)), 2)#+0.5
	liftFac = 0.1+abs(sin(move2FaceAngle*2))#*0.9
	speedFac = min(1, pow(speed/MAXSPEED, 2))
	
	var rotAngle = 0.0
	var maxRot = 0.05 * (speedFac+dragFac)
	if Input.is_action_pressed("ui_left"):
		rotAngle = maxRot #(1.2-speedFac) 
	if Input.is_action_pressed("ui_right"):
		rotAngle = -maxRot #(1.2-speedFac) 
		
#	if (Input.is_action_pressed("ui_left")):
#		rotAngle = 0.1 * (0.2+speedFac) #(1.2-speedFac) 
#	if (Input.is_action_pressed("ui_right")):
#		rotAngle = -0.1 * (0.2+speedFac) #(1.2-speedFac) 

	if rotAngle == 0:
		var targetRot = faceDir.angle_to_point(body.get_local_mouse_pos())*-1
		if targetRot > 0:
			rotAngle = min(maxRot, targetRot)
		else:
			rotAngle = max(-maxRot, targetRot)
	faceDir = faceDir.rotated(rotAngle)
	body.set_rot(faceDir.angle())
	
	#lift = speed * (abs(sin(mov.angle_to(faceDir)*2)) + 5) * faceDir#.rotated(PI/2)
#	lift = speed * liftFac * faceDir#.rotated(PI/2)
#	drag = speed * dragFac * faceDir.rotated(PI/2)

	if move2FaceAngle > 0:
		lift = speed * liftFac * faceDir.rotated(PI/4)
#		drag = speed * dragFac * faceDir.rotated(PI*0.75)
	else:
		lift = speed * liftFac * faceDir.rotated(-PI/4)
#		drag = speed * dragFac * faceDir.rotated(-PI*0.75)
	drag = dragFac * -1 * mov
#	drag = speed * 0.05 * dragFac * (-mov)
#	lift = liftFac * Vector2(0,1) #* MAXSPEED*speedFac
#	drag = speed * dragFac * faceDir - mov*(dragFac+0.1)
	mov += (GRAV+lift+drag)*delta
	
	var zoom = max(1, min(5, speed/8))
	camera.set_zoom(Vector2(zoom, zoom))
	camera.set_offset(Vector2(400,200*zoom))
	if dragFac > 0.2:
		camera.set_pos(get_pos()+Vector2(randf()*dragFac*zoom*10,randf()*dragFac*zoom*10))
#	camera.update()
	trailParticles.set_param(Particles2D.PARAM_INITIAL_ANGLE, rad2deg(mov.angle())+270)
	
	var motion = body.move(mov)
	if (body.is_colliding()):
#		var n = body.get_collision_normal()
#		motion = n.slide(motion)
#		body.move(motion)
		
		crashed = true
		var crashSound = soundPlayer.play("gameover")
		var timer = Timer.new()
		timer.set_wait_time(1)
		timer.connect("timeout",self,"reset") 
		#timeout is what says in docs, in signals
		#self is who respond to the callback
		#_on_timer_timeout is the callback, can have any name
		add_child(timer) #to process
		timer.start() #to start
	
	follower.set_pos(body.get_pos())
	
	if(debugEnabled):
		debugLabel.set_rotation(-body.get_rot())
		debugLabel.set_text("dragFac: " + str(dragFac) + "\nliftFac: " + str(liftFac)+ " move2FaceAngle: "+str(move2FaceAngle)+"\nspeedFac: " + str(speedFac)+"\nrotAngle: "+str(rotAngle))
		debugLabel.show()
		update()
	else:
		debugLabel.hide()
	
	soundPlayer.voice_set_volume_scale_db(windSound, -30*(1-speedFac)+30*dragFac)
	if isCloseToObstacle:
		soundPlayer.voice_set_volume_scale_db(alarmSound, 0)
	else: 
		soundPlayer.voice_set_volume_scale_db(alarmSound, -100)

func reset():
	get_tree().change_scene("res://game.tscn")
	
func _on_player_draw():
	if debugEnabled:
	#	var pos = get_viewport_rect().pos
		var pos = body.get_pos()+Vector2(100,0)
	#	draw_line(pos, pos+faceDir*20, Color(1,1,1,1), 1)
		draw_line(pos, pos+lift*20, Color(0,1,0,1), 1)
		draw_line(pos, pos+drag*20, Color(0,0,1,1), 1)
		draw_line(pos, pos+GRAV*20, Color(1,0,0,1), 1)
		draw_line(pos, pos+mov*20, Color(1,1,1,1), 1)

func _on_hand_body_enter( body ):
	if body.is_in_group("obstacle"):
		print("Hand touched ", body)
		get_node("/root/game").showContact()

func _on_proximitySensor_body_enter( body ):
	if body.is_in_group("obstacle"):
		print("Close to ", body)
		get_node("/root/game").showProximity()
		isCloseToObstacle = true

func _on_proximitySensor_body_exit( body ):
	if body.is_in_group("obstacle"):
		print("No longer close to ", body)
		get_node("/root/game").hideProximity()
		isCloseToObstacle = false
