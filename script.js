class ProductManager {
  constructor() {
    this.products = [];
    this.editingId = null;
    this.init();
  }

  async init() {
    await this.loadProductsFromFirebase();
    this.bindEvents();
    this.renderProducts();
  }

    loadProductsFromFirebase() {
    db.collection("products").orderBy("name").onSnapshot(snapshot => {
        this.products = snapshot.docs.map(doc => doc.data());
        this.renderProducts();
    }, error => {
        console.error("Gagal mengambil data dari Firebase:", error);
    });
    }


  bindEvents() {
    document.getElementById('product-form').addEventListener('submit', (e) => {
      e.preventDefault();
      this.handleSubmit();
    });

    document.getElementById('product-images').addEventListener('change', (e) => {
      this.handleImagesPreview(e);
    });

    document.getElementById('cancel-btn').addEventListener('click', () => {
      this.resetForm();
    });
  }

  handleImagesPreview(e) {
    const files = Array.from(e.target.files);
    const previewContainer = document.getElementById('images-preview');
    const display = document.querySelector('.file-input-display');

    previewContainer.innerHTML = '';

    if (files.length > 0) {
      display.textContent = `${files.length} gambar dipilih`;
      files.forEach(file => {
        const reader = new FileReader();
        reader.onload = (e) => {
          const img = document.createElement('img');
          img.src = e.target.result;
          img.className = 'image-preview';
          img.style.maxHeight = '80px';
          img.style.maxWidth = '80px';
          previewContainer.appendChild(img);
        };
        reader.readAsDataURL(file);
      });
    } else {
      display.textContent = 'Pilih gambar produk';
    }
  }

  handleSubmit() {
    const formData = this.getFormData();

    if (this.editingId !== null) {
      this.updateProduct(formData);
    } else {
      this.addProduct(formData);
    }

    this.resetForm();
    this.renderProducts();
  }

  getFormData() {
    const imageFiles = Array.from(document.getElementById('product-images').files);
    const images = [];

    if (this.editingId !== null && imageFiles.length === 0) {
      const existingProduct = this.products.find(p => p.id === this.editingId);
      if (existingProduct) images.push(...existingProduct.images);
    } else {
      const previewImages = document.querySelectorAll('#images-preview img');
      previewImages.forEach(img => images.push(img.src));
    }

    const featuresText = document.getElementById('product-features').value;
    const features = featuresText ? featuresText.split(',').map(f => f.trim()).filter(f => f) : [];

    const specifications = {};
    const material = document.getElementById('spec-material').value.trim();
    const dimensions = document.getElementById('spec-dimensions').value.trim();
    const weight = document.getElementById('spec-weight').value.trim();

    if (material) specifications['Material'] = material;
    if (dimensions) specifications['Dimensions'] = dimensions;
    if (weight) specifications['Weight'] = weight;

    return {
      id: this.editingId || this.generateId(),
      name: document.getElementById('product-name').value,
      category: document.getElementById('product-category').value,
      price: parseFloat(document.getElementById('product-price').value) || 0,
      description: document.getElementById('product-description').value,
      images,
      stock: parseInt(document.getElementById('product-stock').value) || 0,
      features,
      specifications,
    };
  }

  generateId() {
    return Date.now().toString() + Math.random().toString(36).substr(2, 5);
  }

  async addProduct(product) {
    try {
      await db.collection("products").doc(product.id).set(product);
      this.products.push(product);
      this.showNotification('Produk berhasil ditambahkan', 'success');
    } catch (error) {
      console.error("Gagal menambahkan produk:", error);
    }
  }

  async updateProduct(product) {
    try {
      await db.collection("products").doc(product.id).set(product);
      const index = this.products.findIndex(p => p.id === product.id);
      if (index !== -1) this.products[index] = product;
      this.showNotification('Produk berhasil diperbarui', 'success');
    } catch (error) {
      console.error("Gagal memperbarui produk:", error);
    }
  }

  async deleteProduct(id) {
    if (confirm('Apakah Anda yakin ingin menghapus produk ini?')) {
      try {
        await db.collection("products").doc(id).delete();
        this.products = this.products.filter(p => p.id !== id);
        this.renderProducts();
        this.showNotification('Produk berhasil dihapus', 'success');
      } catch (error) {
        console.error("Gagal menghapus produk:", error);
      }
    }
  }

  editProduct(id) {
    const product = this.products.find(p => p.id === id);
    if (!product) return;

    this.editingId = id;
    document.getElementById('edit-id').value = id;
    document.getElementById('product-name').value = product.name;
    document.getElementById('product-category').value = product.category;
    document.getElementById('product-price').value = product.price;
    document.getElementById('product-stock').value = product.stock;
    document.getElementById('product-description').value = product.description;
    document.getElementById('product-features').value = product.features.join(', ');
    document.getElementById('spec-material').value = product.specifications.Material || '';
    document.getElementById('spec-dimensions').value = product.specifications.Dimensions || '';
    document.getElementById('spec-weight').value = product.specifications.Weight || '';

    const previewContainer = document.getElementById('images-preview');
    previewContainer.innerHTML = '';
    product.images.forEach(src => {
      const img = document.createElement('img');
      img.src = src;
      img.className = 'image-preview';
      img.style.maxHeight = '80px';
      img.style.maxWidth = '80px';
      previewContainer.appendChild(img);
    });

    document.querySelector('.file-input-display').textContent = `${product.images.length} gambar saat ini`;
    document.getElementById('form-title').textContent = '✏️ Edit Produk';
    document.getElementById('submit-btn').textContent = 'Perbarui Produk';
    document.getElementById('cancel-btn').style.display = 'inline-block';
    document.querySelector('.form-section').scrollIntoView({ behavior: 'smooth' });
  }

  resetForm() {
    this.editingId = null;
    document.getElementById('product-form').reset();
    document.getElementById('edit-id').value = '';
    document.getElementById('images-preview').innerHTML = '';
    document.querySelector('.file-input-display').textContent = 'Pilih gambar produk';
    document.getElementById('form-title').textContent = '➕ Tambah Produk Baru';
    document.getElementById('submit-btn').textContent = 'Tambah Produk';
    document.getElementById('cancel-btn').style.display = 'none';
  }

  renderProducts() {
    const grid = document.getElementById('products-grid');
    if (this.products.length === 0) {
      grid.innerHTML = `
        <div class="empty-state">
          <div style="font-size: 4rem; margin-bottom: 20px;">🪑</div>
          <h3>Belum ada produk</h3>
          <p>Tambahkan produk anda dengan form Tambah Produk Baru</p>
        </div>`;
      return;
    }

    grid.innerHTML = this.products.map(product => `
      <div class="product-card">
        <div class="product-images">
          ${product.images.length > 0 ?
            product.images.map(img => `<div class="product-image"><img src="${img}" alt=""></div>`).join('')
            : '<div class="product-image">Tidak ada gambar</div>'}
        </div>
        <div class="product-name">${product.name}</div>
        <div class="product-category">${product.category}</div>
        <div class="product-price">Rp ${product.price.toLocaleString('id-ID')}</div>
        <div class="product-description">${product.description || 'Tidak ada deskripsi'}</div>
        <div class="product-stock">Stok: ${product.stock} item</div>
        ${product.features.length ? `
        <div class="product-features">
          <h5>Fitur:</h5>
          <div class="features-list">
            ${product.features.map(f => `<span class="feature-tag">${f}</span>`).join('')}
          </div>
        </div>` : ''}
        ${Object.keys(product.specifications).length ? `
        <div class="product-specifications">
          <h5>Spesifikasi:</h5>
          ${Object.entries(product.specifications).map(([k, v]) =>
            `<div class="spec-item"><span><strong>${k}:</strong></span><span>${v}</span></div>`).join('')}
        </div>` : ''}
        <div class="product-actions">
          <button class="btn btn-edit" onclick="productManager.editProduct('${product.id}')">✏️ Edit</button>
          <button class="btn btn-danger" onclick="productManager.deleteProduct('${product.id}')">🗑️ Hapus</button>
        </div>
      </div>`).join('');
  }

  showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.style.cssText = `
      position: fixed;
      top: 20px;
      right: 20px;
      padding: 15px 25px;
      background: ${type === 'success' ? '#4CAF50' : '#2196F3'};
      color: white;
      border-radius: 10px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.2);
      z-index: 1000;
      animation: slideIn 0.3s ease;
    `;
    notification.textContent = message;
    document.body.appendChild(notification);
    setTimeout(() => notification.remove(), 3000);
  }
}

// Inisialisasi
const productManager = new ProductManager();
