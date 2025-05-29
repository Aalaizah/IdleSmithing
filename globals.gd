extends Node

var allJobs = {}
var activeTimer: Timer
var activeTimerProgressBar: ProgressBar
var jobQueue = []
var jobTimers = {}
var inventory = {"Copper Dagger": 2, "Poplar Bow": 1}
const maxItemCount = 20
var activeDungeons = []
var dungeons = {}
var dungeonHealthBars = {}
