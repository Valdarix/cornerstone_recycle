window.addEventListener('message', function(e) {
  const data = e.data;
  if (data.action === 'open') {
    document.getElementById('app').style.display = 'block';
  } else if (data.action === 'setData') {
    const tbody = document.querySelector('#items tbody');
    tbody.innerHTML = '';
    data.data.forEach(function(item) {
      const tr = document.createElement('tr');
      const chartId = `hist-${item.item}`;
      tr.innerHTML = `
        <td>${item.item}</td>
        <td>$${item.buy_price}</td>
        <td>$${item.sell_price}</td>
        <td>${item.supply}</td>
        <td><canvas id="${chartId}" width="120" height="40"></canvas></td>
        <td>
          <input type="number" min="1" value="1" data-item="${item.item}" class="buy-amt">
          <button data-item="${item.item}" data-action="buy">Buy</button>
        </td>
        <td>
          <input type="number" min="1" value="1" data-item="${item.item}" class="sell-amt">
          <button data-item="${item.item}" data-action="sell">Sell</button>
        </td>`;
      tbody.appendChild(tr);
      const history = (item.history || []).map(h => h.sell_price).reverse();
      const ctx = document.getElementById(chartId).getContext('2d');
      new Chart(ctx, {
        type: 'line',
        data: { labels: history.map((_, i) => i + 1), datasets: [{ data: history, borderColor: '#4CAF50', backgroundColor: 'transparent' }] },
        options: { responsive: false, plugins: { legend: { display: false } }, scales: { x: { display: false }, y: { display: false } } }
      });
      if (item.supply <= 0) {
        tr.querySelector('button[data-action="buy"]').disabled = true;
      }
    });
  }
});

document.getElementById('quickSell').addEventListener('click', function() {
  fetch('https://' + GetParentResourceName() + '/quickSell', {
    method: 'POST',
    body: JSON.stringify({})
  });
});

document.getElementById('items').addEventListener('click', function(e) {
  if (e.target.tagName === 'BUTTON') {
    const item = e.target.dataset.item;
    const action = e.target.dataset.action;
    const inputSelector = action === 'buy' ? '.buy-amt' : '.sell-amt';
    const amtInput = e.target.parentElement.querySelector(inputSelector);
    const amount = parseInt(amtInput.value) || 1;
    const eventName = action === 'buy' ? 'buyItem' : 'sellItem';
    fetch('https://' + GetParentResourceName() + '/' + eventName, {
      method: 'POST',
      body: JSON.stringify({ item: item, amount: amount })
    });
  }
});

document.getElementById('close').addEventListener('click', function() {
  fetch('https://' + GetParentResourceName() + '/close', {
    method: 'POST',
    body: '{}'
  });
  document.getElementById('app').style.display = 'none';
});
