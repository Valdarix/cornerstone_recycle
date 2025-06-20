-- Inventory functions are routed through the Community Bridge

---@param src number # player source
---@param item string # item name
---@param amount number # amount to take from player
function removeItem(src, item, amount)
  Inventory.RemoveItem(src, item, amount)
end
exports('removeItem', removeItem)

---@param src number # player source
---@param item string # item name
---@param amount number # amount to take from player
function addItem(src, item, amount)
  local success = Inventory.AddItem(src, item, amount)
  if not success then
    doNotifyServer(src, 5000, 'Inventory:', 'You cant carry that!', 'error')
  end
end
exports('addItem', addItem)
