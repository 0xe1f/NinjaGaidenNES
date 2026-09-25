-- Live trace while you play. Does not touch the controller.
-- Log: generated/live.log

local MEM = emu.memType.nesDebug
local OUT = "/Users/akop/code/NinjaGaiden/generated/live.log"

local frame = 0
local seenHandler = {}
local lastArea = -1
local lastLives = -1
local lastAction = -1
local logf = io.open(OUT, "w")

local function log(msg)
  if logf then
    logf:write(string.format("%d  %s\n", frame, msg))
    logf:flush()
  end
end

local watch = {
  [0xE3C9] = "lose_life",
  [0xEEAE] = "use_subweapon",
  [0xC0E9] = "pick_area",
  [0xE347] = "area_event"
}

local enemies = {
  [0xC1F9] = "boxer",
  [0xC21D] = "boxer",
  [0xC241] = "boxer",
  [0xC26A] = "boxer",
  [0xC27C] = "boxer",
  [0xC2A3] = "boxer",
  [0xC2B6] = "machine gunner",
  [0xC2DC] = "machine gunner",
  [0xC307] = "machine gunner",
  [0xC344] = "thrower",
  [0xC368] = "thrower",
  [0xC37E] = "thrower",
  [0xC3AE] = "thrower",
  [0xC3BD] = "batter",
  [0xC3E1] = "batter",
  [0xC402] = "knife thrower",
  [0xC41B] = "knife thrower",
  [0xC431] = "knife thrower",
  [0xC466] = "knife thrower",
  [0xC487] = "knife thrower",
  [0xC4BE] = "knife thrower",
  [0xC4D5] = "crouching soldier",
  [0xC4F1] = "crouching soldier",
  [0xC51D] = "crouching soldier",
  [0xC53C] = "jump kicker",
  [0xC55A] = "jump kicker",
  [0xC577] = "jump kicker",
  [0xC58E] = "jump kicker",
  [0xC5AE] = "jump kicker",
  [0xC5C1] = "running soldier",
  [0xC5E5] = "running soldier",
  [0xC5FF] = "running soldier",
  [0xC615] = "bat",
  [0xC64E] = "bat",
  [0xC67F] = "attacking dog",
  [0xC6B3] = "attacking dog",
  [0xC6D4] = "waiting dog",
  [0xC6F5] = "waiting dog",
  [0xC71A] = "waiting dog",
  [0xC739] = "bird",
  [0xC75D] = "bird",
  [0xC7AB] = "jetpack ninja",
  [0xC7D7] = "jetpack ninja",
  [0xC80E] = "jetpack ninja",
  [0xC828] = "running ninja",
  [0xC849] = "running ninja",
  [0xC86B] = "running ninja",
  [0xC88C] = "running ninja",
  [0xC8A3] = "running ninja",
  [0xC8BE] = "stone man",
  [0xC8EA] = "stone man",
  [0xC93B] = "stone man",
  [0xC963] = "stone man",
  [0xC9A9] = "stone man",
  [0xC9BA] = "crouched ghoul",
  [0xC9EA] = "crouched ghoul",
  [0xCA13] = "crouched ghoul",
  [0xCA2E] = "waiting ghoul",
  [0xCA52] = "waiting ghoul",
  [0xCA65] = "waiting ghoul",
  [0xCA8E] = "waiting ghoul",
  [0xCAA5] = "machine gun bullet",
  [0xCAE9] = "axe",
  [0xCB30] = "axe",
  [0xCB37] = "knife",
  [0xCB73] = "crouching soldier's bullet",
  [0xCBC2] = "shuriken",
  [0xCC4E] = "stone man's ring",
  [0xCCA5] = "barbarian",
  [0xCCC5] = "barbarian",
  [0xCCE1] = "barbarian",
  [0xCCEC] = "barbarian",
  [0xCD02] = "barbarian",
  [0xCD0D] = "barbarian",
  [0xCD1E] = "barbarian",
  [0xCD2E] = "barbarian",
  [0xCD41] = "second boss",
  [0xCD87] = "second boss",
  [0xCDA4] = "second boss",
  [0xCDC5] = "second boss",
  [0xCDFE] = "second boss's axe",
  [0xCE7F] = "third boss",
  [0xCEA8] = "third boss",
  [0xCEC1] = "third boss",
  [0xCEE3] = "third boss",
  [0xCF01] = "third boss",
  [0xCF14] = "third boss",
  [0xCFA4] = "third boss's shot",
  [0xCFB6] = "fourth boss",
  [0xD02D] = "fourth boss",
  [0xD052] = "fourth boss",
  [0xD0F7] = "Bloody Malth",
  [0xD131] = "Bloody Malth",
  [0xD14D] = "Bloody Malth",
  [0xD15B] = "Bloody Malth",
  [0xD170] = "Bloody Malth",
  [0xD1C9] = "Bloody Malth's lightning",
  [0xD1DE] = "Bloody Malth's lightning",
  [0xD1FE] = "Bloody Malth's lightning",
  [0xD223] = "Masked Devil",
  [0xD256] = "Masked Devil",
  [0xD2B2] = "Masked Devil's fireballs",
  [0xD2EC] = "Masked Devil's fireballs",
  [0xD32D] = "runs the Masked Devil fight",
  [0xD35B] = "Jaquio",
  [0xD394] = "Jaquio",
  [0xD40B] = "Jaquio's fireball",
  [0xD443] = "final boss",
  [0xD480] = "final boss",
  [0xD492] = "final boss",
  [0xD52B] = "final boss's head",
  [0xD540] = "final boss's head",
  [0xD5AD] = "final boss's fireballs",
  [0xD5B2] = "final boss's tail"
}

for addr, name in pairs(watch) do
  emu.addMemoryCallback(function()
    local area = emu.read(0x6D, MEM)
    local lives = emu.read(0x76, MEM)
    log(string.format("%s  area $%02X  lives %d", name, area, lives))
  end, emu.callbackType.exec, addr)
end

emu.addMemoryCallback(function()
  local handler = emu.read(0x00, MEM) + emu.read(0x01, MEM) * 256
  if handler == 0xD5B2 or seenHandler[handler] then
    return
  end
  seenHandler[handler] = true
  local who = enemies[handler] or string.format("$%04X", handler)
  log("enemy  " .. who)
end, emu.callbackType.exec, 0xE251)

emu.addEventCallback(function()
  frame = frame + 1
  local area = emu.read(0x6D, MEM)
  local lives = emu.read(0x76, MEM)
  local action = emu.read(0x80, MEM)
  if area ~= lastArea or lives ~= lastLives then
    log(string.format("area $%02X  lives %d  action $%02X  height $%02X",
      area, lives, action, emu.read(0x8A, MEM)))
    lastArea = area
    lastLives = lives
  end
  if action ~= lastAction then
    log(string.format("action $%02X  height $%02X", action, emu.read(0x8A, MEM)))
    lastAction = action
  end
end, emu.eventType.endFrame)

log("trace on")
