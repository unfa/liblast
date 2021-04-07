extends Spatial

# This Scene is meant for playing back sound groups. For simple, singular sound effects use stock Godot nodes, this is meant to play a random sound among a group with variations.

const SFX_dir = "res://Assets/Audio/SFX/" # all sound clips must reside somewhere in this directory

export(String, FILE, "*01*.wav") var SoundClip = SFX_dir + "Test_01.wav"
export(bool) var AutoPlay = false
export(float) var MinimumRandomDistance = 0.35 # gives optimal playback repetition for sound clip groups of different sizes. 
export(bool) var PlayUntilEnd = false # determines if the play() function is allowed to sop a previously started sound
export(float) var MinDelay = 0 # determines how many seconds must pass before the sound can be triggered again
export(float) var PitchScale = 1
export(float) var RandomizePitch = 0
export(int) var Voice_Count = 1
var min_distance = 0 # this  determines how ofte na sound is allowed to play (any Nth time) this is calculated automatically based on maximum_repetition
var clips = [] # holds loaded sound stream resources
var recently_played = [] # holds indexes of recently played 
var ready = true # used as a semaphor for MinDelay 

var voices = []
var voice = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var files = []
	var dir = Directory.new()
	dir.open(SFX_dir)
	dir.list_dir_begin()
	
	print("SoundClip: ", SoundClip)
	# determine the sound group name part
	var group = SoundClip.left(SoundClip.find_last('_')).right(SoundClip.find_last('/') + 1)
	
	# determine the sound layer name part
	var layer = SoundClip.right(SoundClip.find_last('01') + 1)
	layer = layer.right(layer.find_last('_') + 1)
	layer = layer.left(layer.find_last('.'))
	if layer == "1": # sound without a layer defined will return "1", so let's take that as a "no layers defined in this sound"
		layer = ""
	else: # if the layers was specified the group will be incorrectly including the variant number, let's fix that
		group = group.left(group.find_last('_'))
	
	print("group: ", group)
	print("layer: ", layer)
	
	while true:
		var file = dir.get_next()
		#print(file)
		if file == "":
			break
		elif not file.begins_with(".") and file.begins_with(group) and file.ends_with(".wav"):
			if layer.length() == 0: # no layer specified?
				files.append(file)
				print("no layer specified - adding ", file)
			elif file.find(layer) > -1: # chek if the file name contains the layer string
				files.append(file)
				print("layer matches - adding ", file)
		
	dir.list_dir_end()
	
	print("files in list: \n", files)
	
	for f in files:
		var res_file = SFX_dir + f 
		var clip = load(res_file)
		clips.append(clip)
		print("loading ", res_file, "; result: ", clip)

	var clip_count = clips.size()
	
	if not MinimumRandomDistance == null:
		min_distance = floor(clip_count * MinimumRandomDistance)
	else:
		min_distance = 0
	
	
	#print ("Clips: ", len(clips))
	#print ("min_distance: ", min_distance)
	
	# prepare voices - TODO: this does not work! as aworkaround I've duplicated the secondary AudioStreamPlayer3D manually
	if Voice_Count > 1:
		for i in range(1, Voice_Count):
			var new_voice = $AudioStreamPlayer3D.duplicate()
			add_child(new_voice)
	
	for i in get_children():
		voices.append(i)
		
	print("voices: ", voices)
	
	if AutoPlay:
		play()

func pick_random():
	assert(len(clips) > 0)
	return randi() % len(clips)

sync func play():
	var player = voices[voice]
	
	voice = (voice + 1) % voices.size()
	
	print("playing ", name, " on voice ", voice)
	
	if PlayUntilEnd:
		if player.playing:
			return 1
	
	if MinDelay > 0:
		if not ready:
			return 2
	
	var i = pick_random()
	
	while recently_played.has(i):
		i = pick_random()
	
	#print("i: ", i)
	
	recently_played.append(i)
	
	if len(recently_played) > min_distance:
		recently_played.remove(0)
		
	print("random pick: ", clips[i])
	
	player.stream = clips[i]
	
	if RandomizePitch != 0:
		player.pitch_scale = PitchScale + rand_range(-RandomizePitch /2, RandomizePitch/2)
	else:
		player.pitch_scale = PitchScale
		
	player.play()
	
	ready = false
	
	yield(get_tree().create_timer(MinDelay), "timeout")
	
	ready = true
	
	# TODO implement final randomization algorithm 

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
