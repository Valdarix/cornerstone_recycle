---@param duration number # length of progress
---@param label string # progress text
---@param anim? table # {dict, clip}
local function TriggerProgress(duration, label, anim)
  anim = anim or {}

  local options = {
    duration = duration,
    label = label,
    anim = {
      dict = anim[1],
      clip = anim[2],
    }
  }

  return ProgressBar.Open(options)
end
exports('TriggerProgress', TriggerProgress)
