// Laitoksen revisioiden käsittely

async function showPlantRevisionSelection(plant) {
  let old = document.getElementById('plantRevisionSection');
  if (old) old.remove();
  const section = document.createElement('div');
  section.id = 'plantRevisionSection';
  section.className = 'mt-3';
  section.innerHTML = `
    <div class="d-flex align-items-center mb-2" style="gap: 8px;">
      <i class="bi bi-layers-half" style="font-size: 1.2em;"></i>
      <span style="font-weight: 500;">Valitse laitoksen revisio</span>
      <button class="btn btn-outline-theme btn-sm ms-auto" id="refreshRevisionsBtn" title="Päivitä revisiot">
        <i class="bi bi-arrow-clockwise"></i>
      </button>
      <button class="btn btn-outline-theme btn-sm" id="addRevisionBtn" title="Lisää uusi revisio">
        <i class="bi bi-plus"></i>
      </button>
    </div>
    <div id="revisionList" class="list-group mb-2"></div>
    <div id="revisionActions" class="d-flex gap-2"></div>
  `;
  const collapsedPlant = document.getElementById('collapsedPlant');
  if (collapsedPlant && collapsedPlant.parentNode) {
    collapsedPlant.parentNode.insertBefore(section, collapsedPlant.nextSibling);
  }
  await loadAndDisplayPlantRevisions(plant.id);
  document.getElementById('refreshRevisionsBtn').onclick = () => loadAndDisplayPlantRevisions(plant.id);
  document.getElementById('addRevisionBtn').onclick = () => addNewPlantRevision(plant.id);
}

async function loadAndDisplayPlantRevisions(plantId) {
  const list = document.getElementById('revisionList');
  if (!list) return;
  list.innerHTML = '<div class="text-muted">Loading revisions...</div>';
  try {
    const resp = await fetch(`${API_BASE}/plants/${plantId}/revisions`);
    if (!resp.ok) throw new Error('Failed to load revisions');
    let revisions = await resp.json();
    revisions = revisions.filter(r => r.status === 'DRAFT');
    if (revisions.length === 0) {
      list.innerHTML = '<div class="text-muted">Ei keskeneräisiä revisioita.</div>';
      return;
    }
    list.innerHTML = '';
    revisions.forEach(rev => {
      const item = document.createElement('button');
      item.className = 'list-group-item list-group-item-action d-flex align-items-center gap-2';
      item.type = 'button';
      item.innerHTML = `
        <i class="bi bi-file-earmark-text"></i>
        <span style="flex:1;">Revisio ${rev.revision_number || ''}</span>
        <span class="badge bg-secondary">${rev.status}</span>
      `;
      item.onclick = () => selectPlantRevision(rev);
      list.appendChild(item);
    });
  } catch (e) {
    list.innerHTML = '<div class="alert alert-danger">Failed to load revisions.</div>';
  }
}

function selectPlantRevision(revision) {
  const selection = JSON.parse(localStorage.getItem('customerPlantSelection') || '{}');
  selection.revision = revision;
  localStorage.setItem('customerPlantSelection', JSON.stringify(selection));
  showSuccess(`Revision ${revision.revision_number || ''} selected`);
  document.querySelectorAll('#revisionList .list-group-item').forEach(btn => btn.classList.remove('active'));
  const list = document.getElementById('revisionList');
  if (list) {
    const idx = Array.from(list.children).findIndex(btn => btn.textContent.includes(revision.revision_number));
    if (idx >= 0) list.children[idx].classList.add('active');
  }
}

// Lisää tähän mahdolliset addNewPlantRevision yms. funktiot
