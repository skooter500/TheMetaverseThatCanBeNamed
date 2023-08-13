class_name SkeletonSpineAnimator extends Node

export var skeleton_path:NodePath
var skeleton
export var damping:float = 7
export var angular_damping:float = 20
				
var bones = [] 
var offsets = [] 

func calculateOffsets():
	skeleton = get_node(skeleton_path)
	bones.clear()
	offsets.clear()	
		
	for i in skeleton.get_bone_count():
		var bone = skeleton.get_bone_custom_pose(i)
		
		var txt = skeleton.get_bone_name(i) + str(bone.origin)  \
				+ " Bone Pose: " + str(skeleton.get_bone_pose(i).origin) \
				+ " Rest Pose: " + str(skeleton.get_bone_rest(i).origin) \
				+ " Custom Pose: " + str(skeleton.get_bone_custom_pose(i).origin) \
				+ " Global Pose: " + str(skeleton.get_bone_global_pose(i).origin) \
				+ " Global Pose Rotation: " + str(skeleton.get_bone_global_pose(i).basis.get_euler()) \
				
		
		print(txt)
		bones.push_back(bone)
		if i > 0:
			var offset = bones[i].origin - bones[i-1].origin
			offset = bones[i-1].basis.xform_inv(offset)
			offsets.push_back(offset)

# Called when the node enters the scene tree for the first time.
func _ready():
	calculateOffsets()
	
func _physics_process(delta):
	var t = OS.get_system_time_msecs() / 500.0
	for i in skeleton.get_bone_count():
		var bone = skeleton.get_bone_global_pose(i)		
		bone.origin
		# bone.origin = pos
		# skeleton.set_bone_pose(i, bone)
		# skeleton.set_bone_pose_position(i, bone)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func __physics_process(delta):
	for i in offsets.size():
		var prev = bones[i]
		var next = bones[i + 1]
		
		var wantedPos = prev.global_transform.xform(offsets[i])
		
		# Clamp it, cthey dont get too far apart
		var lerped = lerp(next.global_transform.origin, wantedPos, delta * damping)
		var clamped = (lerped - prev.global_transform.origin).normalized() * offsets[i].length()
		var pos = prev.global_transform.origin + clamped
		# next.move_and_slide(pos - next.global_transform.origin)
		next.global_transform.origin = pos
		
		var prevRot = prev.global_transform.basis.orthonormalized()
		
		# Why?
		var target_rot = prev.global_transform.looking_at(next.global_transform.origin, prev.global_transform.basis.y).basis.orthonormalized()			
		# var next_rot = nextRot.slerp(prevRot, angular_damping * delta).orthonormalized()
		 
		next.global_transform.basis = next.global_transform.basis.slerp(target_rot, angular_damping * delta).orthonormalized()
		

