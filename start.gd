extends Node3D

@export var noise:FastNoiseLite
@export var size:int = 16
@export var mat:ShaderMaterial
func _ready():
	var offset:Vector2 = Vector2(16,0)
	var array_3d = arrayGen(Vector2.ZERO)
	GEEEEN(array_3d,Vector2.ZERO)
	array_3d = arrayGen(offset)
	GEEEEN(array_3d,offset)
enum BlockDirections{
UP,
DOWN,
LEFT,
RIGHT,
FRONT,
BACK
}

enum BlockFaces{
TOP,
BOTTOM,
LEFT,
RIGHT,
FRONT,
BACK
}
var blockDirectionVect = {
	BlockDirections.UP:Vector3i(0,1,0),
	BlockDirections.DOWN:Vector3i(0,-1,0),
	BlockDirections.LEFT:Vector3i(-1,0,0),
	BlockDirections.RIGHT:Vector3i(1,0,0),
	BlockDirections.FRONT:Vector3i(0,0,1),
	BlockDirections.BACK:Vector3i(0,0,-1)
}
var cubeVerties = [
		# Front Verties
	Vector3i(0,0,0), #0 Front Bottom Left
	Vector3i(0,1,0), #1 Front TOP Left
	Vector3i(1,1,0), #2 Front TOP Right
	Vector3i(1,0,0), #3 Front Bottom Right
		# Back Verties
	Vector3i(0,0,1), #4 Back Bottom Left
	Vector3i(0,1,1), #5 Back TOP Left
	Vector3i(1,1,1), #6 Back TOP Right
	Vector3i(1,0,1)  #7 Front Bottom Right
	]
	
var cubeFaces = {
	BlockFaces.TOP: [1,5,6,2],
	BlockFaces.BOTTOM: [4,0,3,7],
	BlockFaces.LEFT: [4,5,1,0],
	BlockFaces.RIGHT: [3,2,6,7],
	BlockFaces.FRONT: [0,1,2,3],
	BlockFaces.BACK: [7,6,5,4]
}
func arrayGen(offset:Vector2):

	var array_3d = []
	for x in range(size):
		var array_2d = []
		for z in range(size):
			var array_1d = []
			for y in range(11):
				if y <= floor(abs(noise.get_noise_2d(x + offset.x,z + offset.y) * 10 )):
					array_1d.append(1)  # Set block to 1 if below or at threshold
				else:
					array_1d.append(0)  # Set block to 0 if above threshold
			array_2d.append(array_1d)
		array_3d.append(array_2d)
	return array_3d
func GEEEEN(array_3d:Array,offset:Vector2):
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var coll:CollisionPolygon3D = CollisionPolygon3D.new()
	
	
	st.set_material(mat)
	var noisePos:Array
	for x in range(len(array_3d)):  # Loop through the x dimension
		for z in range(len(array_3d[x])):  # Loop through the z dimension
			for y in range(len(array_3d[x][z])):
				if array_3d[x][z][y] == 1:  # Check if the current block is 1
				
				# Check the bottom face (block below)
					if y > 0 and array_3d[x][z][y - 1] == 0:
						addVert(x - (size/2)+ offset.x, y, z - (size/2)+ offset.y, BlockFaces.BOTTOM, st)
				
				# Check the top face (block above)
					if y < size - 1 and array_3d[x][z][y + 1] == 0:
						addVert(x- (size/2)+ offset.x, y, z- (size/2)+ offset.y, BlockFaces.TOP, st)
 # Check the left face (block to the left in x-direction)
					if x > 0 and array_3d[x - 1][z][y] == 0:
						addVert(x- (size/2)+ offset.x , y, z- (size/2)+ offset.y, BlockFaces.LEFT, st)
				
				# Check the right face (block to the right in x-direction)
					if x < len(array_3d) - 1 and array_3d[x + 1][z][y] == 0:
						addVert(x- (size/2)+ offset.x, y, z- (size/2)+ offset.y, BlockFaces.RIGHT, st)
				
				# Check the back face (block behind in z-direction)
					if z > 0 and array_3d[x][z - 1][y] == 0:
						addVert(x- (size/2)+ offset.x, y, z- (size/2)+ offset.y, BlockFaces.FRONT, st)
				
				# Check the front face (block in front in z-direction)
					if z < len(array_3d[x]) - 1 and array_3d[x][z + 1][y] == 0:
						addVert(x- (size/2)+ offset.x, y, z- (size/2)+ offset.y, BlockFaces.BACK, st) 
	var mesh = st.commit()
	var meah3 = MeshInstance3D.new()
	meah3.mesh = mesh
	var meshArray = meah3.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var concave_shape = ConcavePolygonShape3D.new()
	concave_shape.set_faces(meshArray)
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = concave_shape
	var static_body = StaticBody3D.new()
	static_body.add_child(collision_shape)
	static_body.add_child(meah3)
	add_child(static_body)
func addVert(x:int, y:int, z:int, Face:BlockFaces, st:SurfaceTool):
	var cubeFaceI = cubeFaces[Face]
	var normals = blockDirectionVect[Face]
	st.set_normal(normals)

	# UV mapping for a 2x2 texture atlas (you can adjust this for your atlas size)
	var uv_coords = {}

	match Face:
		BlockFaces.TOP:
			st.set_uv2(Vector2(2,0))
		BlockFaces.BOTTOM:
			st.set_uv2(Vector2(1,0))
		BlockFaces.LEFT:
			st.set_uv2(Vector2(0,0))
		BlockFaces.RIGHT:
			st.set_uv2(Vector2(0,0))
		BlockFaces.FRONT:
			st.set_uv2(Vector2(0,0))
		BlockFaces.BACK:
			st.set_uv2(Vector2(0,0))
	uv_coords = [Vector2(1, 1), Vector2(1, 0.0),Vector2(0.0, 0.0), Vector2(0.0, 1)]
	# Set UVs and add vertices for the face
	st.set_uv(uv_coords[2])
	st.add_vertex(cubeVerties[cubeFaceI[2]] + Vector3i(x, y-10, z))

	st.set_uv(uv_coords[1])
	st.add_vertex(cubeVerties[cubeFaceI[1]] + Vector3i(x, y-10, z))

	st.set_uv(uv_coords[0])
	st.add_vertex(cubeVerties[cubeFaceI[0]] + Vector3i(x, y-10, z))

	st.set_uv(uv_coords[0])
	st.add_vertex(cubeVerties[cubeFaceI[0]] + Vector3i(x, y-10, z))
	st.set_uv(uv_coords[3])
	st.add_vertex(cubeVerties[cubeFaceI[3]] + Vector3i(x, y-10, z))

	st.set_uv(uv_coords[2])
	st.add_vertex(cubeVerties[cubeFaceI[2]] + Vector3i(x, y-10, z))
	
	
