extends Node
class_name Story

func intro_text() -> Array[String]:
	var speaker = "Commander Ballari"
	return [
		speaker + ":\n
Are you awake yet? Give an ack on your radio to let me know you can hear me.",
		speaker + ":\n
Looks like that last blast really shook you up. You might be experiencing some amnesia, but we need you back up and running ASAP.",
		speaker + ":\n
Take a look at the terminal there to see what we need and how we need it.",
		speaker + ":\n
But hurry, our sources say we have another attack expected soon."
	]
	
func normal_flow_start() -> Array[String]:
	var speaker = "Commander Ballari"
	return [
		speaker + ":\nSeems like you've got the hang of things!",
		speaker + ":\nBe sure to check your terminal for new orders regularly.",
	]

func good_hit_bark() -> Array[String]:
	var speaker = "Commander Ballari"
	var barks = [
		"We're hearing reports that the target was destroyed.",
		"We've received confirmation of a successful strike.",
	]
	
	return [speaker + ":\n" + barks.pick_random()]
	
func bad_hit_bark() -> Array[String]:
	var speaker = "Commander Ballari"
	var barks = [
		"That launch did not follow mission parameters!",
		"What in the blazes was that? I need you to follow orders.",
	]
	
	return [speaker + ":\n" + barks.pick_random()]

func cat_overheating() -> Array[String]:
	return ["Commander Ballari: the C.A.T is overheating! You won't be able to launch any payloads until it's taken care of.",
	 "Commander Ballari: Go fix it before the whole facility melts down!"]
