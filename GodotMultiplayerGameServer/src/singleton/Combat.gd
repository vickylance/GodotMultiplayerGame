extends Node


func fetch_skill_damage(skill_name: String) -> int:
	return ServerData.skill_data[skill_name].Damage
