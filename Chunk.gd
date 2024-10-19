extends Node3D

@export var noise:FastNoiseLite
@export var mat:ShaderMaterial
var Chuk:joe = joe.new()
func _ready():
	Chuk.setFastNoise(noise)
	Chuk.setMat(mat)
	var array_3d = Chuk.arrayGen(Vector2.ZERO)
	add_child(Chuk.GEEEEN(array_3d,Vector2.ZERO))
