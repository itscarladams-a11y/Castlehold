class_name WorldBuilder
extends RefCounted
var root: Node3D
var castle: CastleController
var mats: Dictionary = {}
var rng := RandomNumberGenerator.new()
func material(color: String) -> StandardMaterial3D:
	if mats.has(color): return mats[color]
	var m := StandardMaterial3D.new(); m.albedo_color=Color(color); m.roughness=.86
	mats[color]=m;return m
func box(parent: Node3D, pos: Vector3, size: Vector3, color: String, angle: float=0.0) -> MeshInstance3D:
	var n := MeshInstance3D.new(); var m := BoxMesh.new();m.size=size
	n.mesh=m;n.material_override=material(color);n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;parent.add_child(n);n.position=pos;n.rotation.y=angle;return n
func cone(parent: Node3D,pos: Vector3,bottom: float,top: float,height: float,color: String, sides: int=12) -> MeshInstance3D:
	var n := MeshInstance3D.new();var m := CylinderMesh.new()
	m.bottom_radius=bottom;m.top_radius=top;m.height=height;m.radial_segments=sides
	n.mesh=m;n.material_override=material(color);n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;parent.add_child(n);n.position=pos;return n
func banner(parent: Node3D,at: Vector3):
	box(parent,at+Vector3(0,.65,0),Vector3(.07,1.8,.07),"9f7849")
	box(parent,at+Vector3(.37,1.0,0),Vector3(.70,.85,.025),"12516c")
	box(parent,at+Vector3(.37,1.0,-.025),Vector3(.08,.52,.02),"f0d9a0")
	box(parent,at+Vector3(.37,1.08,-.03),Vector3(.35,.08,.02),"f0d9a0")
func build(game: Node3D):
	root=game;castle=game.castle;rng.seed=413
	var ground:=MeshInstance3D.new();var plane:=PlaneMesh.new();plane.size=Vector2(100,100)
	ground.mesh=plane;var ground_material:=ShaderMaterial.new()
	ground_material.shader=load("res://assets/materials/valley_ground.gdshader")
	ground.material_override=ground_material;ground.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;root.add_child(ground)
	FortressArchitecture.new().build(game)
	# Distant low, irregular ridges leave the battle silhouettes unobstructed.
	ridgeline(-36.0,9.0,"839d9b",0.0)
	ridgeline(-26.0,6.0,"637d77",1.8)
	ridgeline(-18.0,3.8,"425f51",4.1)
	for i in 18:
		var x:=rng.randf_range(-15,30);var z:=rng.randf_range(-16,-9)
		tree(Vector3(x,0,z),rng.randf_range(.7,1.05))
	# Only small bushes at the extreme foreground corners, never the fight lane.
	for x in [-13.0,-11.5,18.5,20.0]:
		foliage(root,Vector3(x,.35,6.5),Vector3(.9,.7,.8),"355a40")
	for i in 30:
		var x:=rng.randf_range(-13,24);var z:=rng.randf_range(4.8,8)*(1 if i%2 else -1)
		foliage(root,Vector3(x,.12,z),Vector3(.23,.22,.16),"777d69")
	for i in 70:
		var x:=rng.randf_range(-12,22);var z:=rng.randf_range(3.4,7.5)*(1 if i%2 else -1)
		grass_tuft(Vector3(x,.01,z))
	# Battlefield storytelling stays outside the combat lane: abandoned gear,
	# rough stakes and stone clusters add depth without extra animated actors.
	broken_cart(Vector3(11.5,0,-6.15),-.18)
	broken_cart(Vector3(19.0,0,6.65),PI+.28)
	stake_line(Vector3(14.0,0,6.2),6,-.18)
	stake_line(Vector3(4.0,0,-6.0),5,.14)
	for at in [Vector3(-1.5,0,6.45),Vector3(7.2,0,-6.55),Vector3(17.0,0,-6.2),Vector3(22.0,0,5.8)]:rock_cluster(at)
	var light:=DirectionalLight3D.new();light.name="ValleySun";light.rotation_degrees=Vector3(-48,-35,0)
	light.light_color=Color("ffe6c5");light.light_energy=1.12;light.shadow_enabled=true
	# Mobile stability pass: one orthogonal shadow map avoids split/cascade handoffs
	# that can read as a one-frame whole-scene brightness flash while scouting.
	light.directional_shadow_max_distance=52.0;light.directional_shadow_fade_start=1.0
	light.directional_shadow_pancake_size=10.0;light.shadow_blur=1.15
	light.directional_shadow_mode=DirectionalLight3D.SHADOW_ORTHOGONAL
	light.directional_shadow_blend_splits=false;root.add_child(light)
	var env:=WorldEnvironment.new();env.environment=Environment.new()
	var sky:=Sky.new();var sky_material:=ProceduralSkyMaterial.new()
	sky_material.sky_top_color=Color("6497b0");sky_material.sky_horizon_color=Color("dfd6b7")
	sky_material.ground_bottom_color=Color("304d3d");sky_material.ground_horizon_color=Color("bdc1ac")
	sky_material.sky_curve=.22;sky_material.sun_angle_max=8.0;sky.sky_material=sky_material
	sky.radiance_size=Sky.RADIANCE_SIZE_128;sky.process_mode=Sky.PROCESS_MODE_QUALITY
	env.environment.sky=sky;env.environment.background_mode=Environment.BG_SKY
	env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_SKY
	env.environment.reflected_light_source=Environment.REFLECTION_SOURCE_SKY
	env.environment.ambient_light_energy=.55
	env.environment.tonemap_mode=Environment.TONE_MAPPER_FILMIC;root.add_child(env)

func rock_cluster(at: Vector3):
	var holder:=Node3D.new();holder.name="BattlefieldRockCluster";root.add_child(holder);holder.position=at
	for i in 5:
		var r:=rng.randf_range(.16,.38)
		var stone:=cone(holder,Vector3(rng.randf_range(-.48,.48),r*.55,rng.randf_range(-.36,.36)),r,r*.62,r*1.15,"6f6d62",7)
		stone.rotation.y=rng.randf_range(-PI,PI);stone.rotation.z=rng.randf_range(-.25,.25)
func broken_cart(at: Vector3, angle: float):
	var holder:=Node3D.new();holder.name="BrokenSiegeCart";root.add_child(holder);holder.position=at;holder.rotation.y=angle
	box(holder,Vector3(0,.42,0),Vector3(1.55,.16,.88),"66503a")
	box(holder,Vector3(-.54,.74,0),Vector3(.16,.72,.82),"765a3d")
	for z in [-.52,.52]:
		var wheel:=cone(holder,Vector3(.25,.36,z),.47,.47,.10,"4b4032",12);wheel.rotation.x=PI/2
		var hub:=cone(holder,Vector3(.25,.36,z*1.015),.13,.13,.12,"2f3434",10);hub.rotation.x=PI/2
	box(holder,Vector3(.95,.35,.12),Vector3(1.45,.10,.12),"765a3d",-.18)
	box(holder,Vector3(1.12,.30,-.18),Vector3(1.22,.09,.10),"765a3d",.13)
func stake_line(at: Vector3, count: int, angle: float):
	var holder:=Node3D.new();holder.name="AbandonedStakes";root.add_child(holder);holder.position=at;holder.rotation.y=angle
	for i in count:
		var z:float=(i-(count-1)*.5)*.44
		var stake:=cone(holder,Vector3((i%2)*.12,.48,z),.065,.018,.96,"5b4934",6)
		stake.rotation.z=(-.34 if i%2 else .28)
	box(holder,Vector3(.02,.24,0),Vector3(.11,.12,maxf(.7,count*.44)),"40362b")
func ridgeline(z: float, height: float, color: String, phase: float):
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 30:
		var x:float=-65.0+i*4.5;var xx:float=x+4.5
		var y:=height*(.55+.20*sin(x*.17+phase)+.16*sin(x*.41+phase)+.09*sin(x*.89))
		var yy:=height*(.55+.20*sin(xx*.17+phase)+.16*sin(xx*.41+phase)+.09*sin(xx*.89))
		for v in [Vector3(x,-1,z),Vector3(x,y,z),Vector3(xx,yy,z),Vector3(x,-1,z),Vector3(xx,yy,z),Vector3(xx,-1,z)]:st.add_vertex(v)
	st.generate_normals();var mesh:=MeshInstance3D.new();mesh.mesh=st.commit()
	var mat:=material(color).duplicate();mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;mat.cull_mode=BaseMaterial3D.CULL_DISABLED
	mesh.material_override=mat;mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;root.add_child(mesh)

func foliage(parent: Node3D, at: Vector3, size: Vector3, color: String):
	# Organic, asymmetric closed canopy, built as an original surface mesh.
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rings:Array=[];var sides:=9
	for j in 7:
		var ring:Array[Vector3]=[];var latitude:float=-PI/2+j*PI/6
		for i in sides:
			var angle:float=i*TAU/sides
			var radius:float=maxf(.015,cos(latitude))*(1+.09*sin(i*2.3+j*1.7))
			ring.append(Vector3(cos(angle)*radius*size.x,sin(latitude)*size.y,sin(angle)*radius*size.z))
		rings.append(ring)
	for j in 6:
		for i in sides:
			var next: int=(i+1)%sides
			for v in [rings[j][i],rings[j+1][i],rings[j+1][next],rings[j][i],rings[j+1][next],rings[j][next]]:st.add_vertex(v)
	st.generate_normals();var mesh:=MeshInstance3D.new();mesh.mesh=st.commit();mesh.material_override=material(color);mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;parent.add_child(mesh);mesh.position=at

func tree(at: Vector3, size: float):
	var tree_root:=Node3D.new();root.add_child(tree_root);tree_root.position=at;tree_root.scale=Vector3.ONE*size
	cone(tree_root,Vector3(0,.9,0),.15,.07,1.8,"5c4c36",7)
	var branch:=cone(tree_root,Vector3(-.28,1.50,0),.09,.045,.9,"5c4c36",7);branch.rotation.z=-.67
	branch=cone(tree_root,Vector3(.29,1.65,-.03),.085,.03,.8,"5c4c36",7);branch.rotation.z=.71
	foliage(tree_root,Vector3(-.40,1.8,.08),Vector3(.9,.85,.8),"31553d")
	foliage(tree_root,Vector3(.45,2.0,.02),Vector3(.85,1.0,.82),"456d45")
	foliage(tree_root,Vector3(0,2.65,-.10),Vector3(.88,.85,.83),"537649")
	foliage(tree_root,Vector3(-.54,2.22,-.47),Vector3(.52,.56,.48),"678148")
	foliage(tree_root,Vector3(.56,2.42,.22),Vector3(.48,.48,.51),"72894e")

func grass_tuft(at: Vector3):
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 3:
		var x:float=(i-1)*.08
		for v in [Vector3(x-.04,0,0),Vector3(x+.07,.2+i*.04,.04),Vector3(x+.04,0,0)]:st.add_vertex(v)
	st.generate_normals();var mesh:=MeshInstance3D.new();mesh.mesh=st.commit()
	var mat:=material("52713b");mat.cull_mode=BaseMaterial3D.CULL_DISABLED
	mesh.material_override=mat;mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;root.add_child(mesh);mesh.position=at
