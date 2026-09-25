-- Session-only stage select. Does not change the ROM on disk.
-- The three NOPs in boot_banks become jsr pick_area, which is the
-- same patch as the Game Genie codes AZUTYSXT+OTUVASXV+EGUVPSXT.
-- It appears once, when the game boots, before the stage loads.
-- A and Right add one, A and Left subtract one, Start confirms.
-- Up, A, B, and Start on that first moment opens the sound test.

local codes = { "AZUTYSXT", "OTUVASXV", "EGUVPSXT" }
for _, code in ipairs(codes) do
  emu.addCheat(emu.cheatType.nesGameGenie, code)
end
