const root = document.getElementById('root');

async function render() {
  root.textContent = 'Loading shipments...';

  try {
    const res = await fetch('/api/shipments');
    const { shipments } = await res.json();

    const list = document.createElement('ul');
    for (const s of shipments) {
      const li = document.createElement('li');
      li.textContent = `${s.id} - ${s.status} (${s.carrier})`;
      list.appendChild(li);
    }

    root.textContent = '';
    const heading = document.createElement('h1');
    heading.textContent = 'Northwind Console';
    root.append(heading, list);
  } catch (err) {
    root.textContent = `Could not reach the shipments API: ${err.message}`;
  }
}

render();
