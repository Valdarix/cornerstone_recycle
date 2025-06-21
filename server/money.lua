-- Money handling via Community Bridge
local Bridge = exports.community_bridge:Bridge()
---@param src number # player source
---@param amount number # amount to take from player
function takeMoney(src, amount, reason)
  return Bridge.Framework.RemoveAccountBalance(src, 'cash', amount)
end
exports('takeMoney', takeMoney)

---@param src number # player source
---@param amount number # amount to take from player
---@param account string # bank or cash
---@param reason string # reason for change
function addMoney(src, amount, account, reason)
  Bridge.Framework.AddAccountBalance(src, account or 'cash', amount)
end
exports('addMoney', addMoney)
