extends Node

var allJobs = {}
var activeTimer: Timer
var activeTimerProgressBar: ProgressBar
var jobQueue = []
var jobTimers = {}
var inventory = {}
const maxItemCount = 20
var dungeons = {}
var dungeonHealthBars = {}
