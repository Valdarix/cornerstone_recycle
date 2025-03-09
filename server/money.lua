if Config.Framework == 'qb'  then QBCore = exports['qb-core']:GetCoreObject() end
if Config.Framework == 'QBX' then QBX = exports.QBX_core end
if Config.Framework == 'esx' then ESX = exports["es_extended"]:getSharedObject() end

---@param src number # player source
---@param amount number # amount to take from player
local function takeMoney(src, amount, reason)
  if Config.Framework == 'QBX' then
    if QBX:GetMoney(src, 'cash') >= amount then
      QBX:RemoveMoney(src, 'cash', amount, reason)
      return true
    elseif QBX:GetMoney(src, 'bank') >= amount then
      QBX:RemoveMoney(src, 'bank', amount, reason)
      return true
    else
      return false
    end
  elseif Config.Framework == 'qb' then
    local plr = QBCore.Functions.GetPlayer(src)
    if not plr then return false end
    if plr.Functions.GetMoney('cash') >= amount then -- Changed > to >=
      plr.Functions.RemoveMoney('cash', amount)
      return true
    elseif plr.Functions.GetMoney('bank') >= amount then
      plr.Functions.RemoveMoney('bank', amount)
      return true
    else
      return false
    end  
  elseif Config.Framework == 'esx' then
    local plr = ESX.GetPlayerFromId(src)
    if not plr then return false end
    if plr.getMoney() >= amount then
      plr.removeMoney(amount)
      return true
    else
      return false
    end
  end
end
exports('takeMoney', takeMoney)

---@param src number # player source
---@param amount number # amount to take from player
---@param account string # bank or cash
---@param reason string # reason for change
local function addMoney(src, amount, account, reason)
  if Config.Framework == 'QBX' then
    QBX:AddMoney(src, account, amount, reason)
  elseif Config.Framework == 'qb' then
    local plr = QBCore.Functions.GetPlayer(src)
    if not plr then return false end
    plr.Functions.AddMoney(account, amount)  
  elseif Config.Framework == 'esx' then
    local plr = ESX.GetPlayerFromId(src)
    if not plr then return false end
    plr.addMoney(amount)
  end
end
exports('addMoney', addMoney)
