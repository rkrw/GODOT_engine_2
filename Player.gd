extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var LIMIT_FALLING_SPEED = 15
export var MOVE_SPEED = 3
export var ACCELERATE_TIME = .15
export var GRAVITY = 10
export var DECELERATE_TIME = .15
export var MAX_JUMP_POWER = 5
export var MIN_JUMP_POWER = 1
export var AIR_JUMP_POWER = 3
var Accelerate_move = 0
var Decelerate_move = 0
var grounded = false
var air_jump = false
var jump_pressed = false
var facing_dir = 1
var velocity = Vector2()
onready var sprite = get_node("Sprite")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	Accelerate_move = MOVE_SPEED/ACCELERATE_TIME
	Decelerate_move = MOVE_SPEED/DECELERATE_TIME
	set_fixed_process(true)

func _fixed_process(delta):
	var movement = Vector2(velocity.x, velocity.y+GRAVITY*delta)
	var input_right = Input.is_action_pressed("Right")
	var input_left = Input.is_action_pressed("Left")
	var input_jump = Input.is_action_pressed("Jump")
	
	if input_right:
		movement.x+=Accelerate_move*delta
	elif input_left:
		movement.x-=Accelerate_move*delta
	#stopping movement when the movement key not pressed
	elif movement.x!=0:
		var _dir = sign(movement.x)
		var _decelerate = _dir*-1*Decelerate_move
		#applying to the movement
		movement.x+=_decelerate
		#stopping when movement out of bond, it means when goes right the movement always above 0 and otherwise
		if _dir==1 && movement.x<0:
			movement.x = 0
		elif _dir==-1 && movement.x>0:
			movement.x = 0
	#keeping the speed below the limit
	if abs(movement.x)>MOVE_SPEED:
		movement.x = sign(movement.x)*MOVE_SPEED
	
	if input_jump&&grounded:
		movement.y = -MAX_JUMP_POWER
		jump_pressed =true
	
	elif !input_jump&&jump_pressed:		
		if movement.y<-MIN_JUMP_POWER:
			movement.y = -MIN_JUMP_POWER		
		jump_pressed = false;
	
	elif !grounded&&!jump_pressed:
		if input_jump&&air_jump:
			movement.y = -AIR_JUMP_POWER
			air_jump = false
			
	
	if velocity.y>LIMIT_FALLING_SPEED:
		velocity.y = LIMIT_FALLING_SPEED
	
	
	velocity = movement
	#get the normal movement, normal movement is a movement that affected by normal force and gravity force, it will stay constant on ordinate
	var normal_movement =  move(velocity)
	
	if is_colliding():
		var normal = get_collision_normal()
		normal_movement = normal.slide(normal_movement)
		velocity = normal.slide(velocity)
		if normal==Vector2(0,-1):
			grounded = true
			air_jump = true
		move(normal_movement)

	elif !is_colliding():
			grounded = false

	if velocity.x != 0:
		facing_dir = sign(velocity.x)
		sprite.set_flip_h(facing_dir!=true)

func get_center_pos():
	return get_pos() + get_node("CollisionShape2D").get_pos()