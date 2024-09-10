extends Control

var progress := []

var tips := []

var process := false
var world := "res://2D/scenes/world.tscn"

func _ready():
	ResourceLoader.load_threaded_request(world)
	tips = [
		"tip:小心被丧尸攻击过的npc！", "tip:杀死怪物可以获得各种物品", 
		"tip:善恶值过低则自动加入怪物阵营", 
		"tip:小心不要误伤NPC，他们很记仇的！", "tip:史莱姆死亡有概率分裂出至多两个分裂体", 
		"tip:Windows中‘J’键攻击，‘I’键交互", "tip:制作物品时请注意物品栏，如果没有空置物品栏则会直接弃置！",
		"tip:攻击树木石头可以获得资源！", "tip:升级可以提升各种属性，怪物也有等级系统，请在其强大前扼杀！",
		"tip:每隔一段时间会在沙地中产生石头", "tip:失去生命值会额外消耗饱食来缓慢补充生命！", 
		"tip:如果卡顿，说明系统正在生成资源和怪物", "tip:杀死NPC可以获得他的所有物品", "tip:坤坤会下蛋！", 
	]
	$Label2.text = tips.pick_random()
	
	
func _process(delta):
	var status := ResourceLoader.load_threaded_get_status(world, progress)
	$ProgressBar.value = progress[0] * 100
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		#set_process(false)
		get_tree().change_scene_to_file(world)
