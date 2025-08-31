local Cutscene = require "scripts.game.cutscene"
local CutsceneScene = require "scripts.game.cutscene_scene"
local Light = require "scripts.graphics.light"
local Rect = require "scripts.math.rect"
local images = require "data.images"

local cutscenes = {}

cutscenes.ceo_escape_w1 = require "data.cutscenes.ceo_escape_w1"
cutscenes.ceo_escape_w2 = require "data.cutscenes.ceo_escape_w2"
cutscenes.ceo_escape_w3 = require "data.cutscenes.ceo_escape_w3"
cutscenes.tutorial_start = require "data.cutscenes.tutorial_start"
cutscenes.tutorial_end = require "data.cutscenes.tutorial_end"
cutscenes.tutorial_end_short = require "data.cutscenes.tutorial_end_short"
cutscenes.enter_ceo_office = require "data.cutscenes.enter_ceo_office"
cutscenes.dung_boss_enter = require "data.cutscenes.dung_boss_enter"
cutscenes.bee_boss_enter = require "data.cutscenes.bee_boss_enter"
cutscenes.arum_titan_enter = require "data.cutscenes.arum_titan_enter"
cutscenes.credits = require "data.cutscenes.credits"

return cutscenes