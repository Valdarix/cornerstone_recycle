
local Bridge = exports.community_bridge:Bridge()
local rewardItems = Config.RecycleCenter.Rewards.Items

local function getBasePrices(item)
  for _, v in ipairs(rewardItems) do
    if v.Item == item then
      return v.BuyPrice, v.SellPrice
    end
  end
  return 1, 2
end

local function recalcPrices(item, supply, demand)
  local baseBuy, baseSell = getBasePrices(item)
  local factor = (demand - supply) * 0.05
  local sell = math.max(baseSell * (1 + factor), 1)
  local buy = math.max(baseBuy * (1 + factor * 0.8), 1)
  if buy >= sell then
    sell = buy + 1
  end
  return buy, sell
end

local function ensureItem(item)
  local row = MySQL.single.await('SELECT item FROM recycle_market WHERE item = ?', { item })
  if not row then
    local buy, sell = getBasePrices(item)
    MySQL.insert.await('INSERT INTO recycle_market (item, buy_price, sell_price) VALUES (?, ?, ?)', {
      item, buy, sell
    })
    MySQL.insert.await('INSERT INTO recycle_market_history (item, buy_price, sell_price) VALUES (?, ?, ?)', {
      item, buy, sell
    })
  end
end

function InitMarket()
  for _, v in ipairs(rewardItems) do
    ensureItem(v.Item)
  end
end

local function updateMarket(item, supplyChange, demandChange)
  local row = MySQL.single.await('SELECT * FROM recycle_market WHERE item = ?', { item })
  if not row then
    ensureItem(item)
    row = MySQL.single.await('SELECT * FROM recycle_market WHERE item = ?', { item })
  end
  local supply = row.supply + (supplyChange or 0)
  local demand = row.demand + (demandChange or 0)
  local buy, sell = recalcPrices(item, supply, demand)
  MySQL.update.await('UPDATE recycle_market SET supply = ?, demand = ?, buy_price = ?, sell_price = ? WHERE item = ?', {
    supply, demand, buy, sell, item
  })
  MySQL.insert.await('INSERT INTO recycle_market_history (item, buy_price, sell_price) VALUES (?, ?, ?)', {
    item, buy, sell
  })
end

function GetMarketData()
  local items = MySQL.query.await('SELECT * FROM recycle_market')
  for i = 1, #items do
    items[i].history = MySQL.query.await('SELECT buy_price, sell_price, timestamp FROM recycle_market_history WHERE item = ? ORDER BY id DESC LIMIT 5', {
      items[i].item
    })
  end
  return items
end

function QuickSell(src)
  local total = 0
  for _, v in ipairs(rewardItems) do
    local count = Inventory.GetItemCount(src, v.Item)
    if count > 0 then
      local row = MySQL.single.await('SELECT buy_price FROM recycle_market WHERE item = ?', { v.Item })
      local price = row and row.buy_price or v.BuyPrice
      removeItem(src, v.Item, count)
      addMoney(src, price * count, 'cash', 'recycle-sale')
      total = total + price * count
      updateMarket(v.Item, count, 0)
    end
  end
  if total > 0 then
    doNotifyServer(src, 5000, 'Recycle', ('Sold items for $%s'):format(total), 'success')
  else
    doNotifyServer(src, 5000, 'Recycle', 'Nothing to sell', 'error')
  end
  TriggerClientEvent('cornerstone_recycle:client:refreshMarket', src)
end

function BuyItem(src, item, amount)
  amount = tonumber(amount) or 1
  local row = MySQL.single.await('SELECT sell_price FROM recycle_market WHERE item = ?', { item })
  local price = row and row.sell_price
  if not price then return end
  local cost = price * amount
  local ok = takeMoney(src, cost, 'recycle-purchase')
  if not ok then
    doNotifyServer(src, 5000, 'Recycle', 'Not enough money', 'error')
    return
  end
  addItem(src, item, amount)
  updateMarket(item, 0, amount)
  doNotifyServer(src, 5000, 'Recycle', ('Purchased %sx %s'):format(amount, item), 'success')
  TriggerClientEvent('cornerstone_recycle:client:refreshMarket', src)
end
