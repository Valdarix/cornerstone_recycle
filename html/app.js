window.addEventListener('message', function(e) {
  const data = e.data;
  if (data.action === 'open') {
    document.getElementById('app').style.display = 'block';
  } else if (data.action === 'setData') {
    const tbody = document.querySelector('#items tbody');
    tbody.innerHTML = '';
    data.data.forEach(function(item) {
      const history = (item.history || []).map(h => '$' + h.sell_price).join(', ');
      const tr = document.createElement('tr');
      tr.innerHTML = `<td>${item.item}</td><td>$${item.buy_price}</td><td>$${item.sell_price}</td><td>${history}</td><td><input type="number" min="1" value="1" data-item="${item.item}"></td><td><button data-item="${item.item}">Buy</button></td>`;
      tbody.appendChild(tr);
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
    const amtInput = document.querySelector(`input[data-item="${item}"]`);
    const amount = parseInt(amtInput.value) || 1;
    fetch('https://' + GetParentResourceName() + '/buyItem', {
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
