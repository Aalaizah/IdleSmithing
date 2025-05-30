extends Node

var allJobs = {}
var activeTimer: Timer
var activeTimerProgressBar: ProgressBar
var jobQueue = []
var jobTimers = {}
var inventory = {}
const maxItemCount = 5
var activeDungeons = []
var dungeons = {}
var dungeonHealthBars = {}
