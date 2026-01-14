// ===========================================
// CONFIGURATION DES FICHIERS
// ===========================================

const sqlFiles = {
    // Fichiers principaux pour le carousel (les plus importants)
    carousel: [
        'ressources/sql/fournissuer.sql',
        'ressources/sql/TP_M3.sql',
        'ressources/sql/TP_M5.sql',
        'ressources/sql/uefa_PR.sql'
    ],
    // Tous les autres fichiers SQL (section pliable)
    all: [
        'ressources/sql/1.sql',
        'ressources/sql/callback.sql',
        'ressources/sql/fournissuer.sql',
        'ressources/sql/PR_linked_to_two_PO.sql',
        'ressources/sql/PR_linked_to_wrong_PO.sql',
        'ressources/sql/TP_Bonus.sql',
        'ressources/sql/TP_M1.sql',
        'ressources/sql/TP_M3.sql',
        'ressources/sql/TP_M4.sql',
        'ressources/sql/TP_M5.sql',
        'ressources/sql/TP_M6.sql',
        'ressources/sql/TP_M7.sql',
        'ressources/sql/uefa_PR.sql',
        'ressources/sql/uefa_pr_export.sql'
    ]
};

const imageFiles = [
    'ressources/images/image.png',
    'ressources/images/image(1).png',
    'ressources/images/image(2).png',
    'ressources/images/image(3).png',
    'ressources/images/image(4).png',
    'ressources/images/image(5).png',
    'ressources/images/image(6).png'
];

// ===========================================
// CHARGEMENT DES FICHIERS
// ===========================================

async function loadTextFile(path) {
    try {
        const response = await fetch(path);
        if (!response.ok) throw new Error(`Erreur de chargement: ${path}`);
        return await response.text();
    } catch (error) {
        console.error('Erreur:', error);
        return `-- Erreur lors du chargement du fichier ${path}`;
    }
}

// Charger les fichiers texte
async function loadDocuments() {
    // Journal de bord
    const journalContent = await loadTextFile('ressources/journal de bord.txt');
    document.getElementById('journal-content').innerHTML = 
        `<pre class="document-text">${journalContent}</pre>`;
    
    // Info entreprise
    const infoContent = await loadTextFile('ressources/info voc entreprise.txt');
    document.getElementById('info-voc-content').innerHTML = 
        `<pre class="document-text">${infoContent}</pre>`;
    
    // Exercices
    const exerciceContent = await loadTextFile('ressources/exercice.txt');
    document.getElementById('exercice-content').innerHTML = 
        `<pre class="document-text">${exerciceContent}</pre>`;
}

// Charger les images
function loadImages() {
    const gallery = document.getElementById('image-gallery');
    imageFiles.forEach((imgPath, index) => {
        const imgDiv = document.createElement('div');
        imgDiv.className = 'gallery-item';
        imgDiv.innerHTML = `
            <img src="${imgPath}" alt="Aperçu ${index + 1}" onclick="openImageModal('${imgPath}')">
        `;
        gallery.appendChild(imgDiv);
    });
}

// Modal pour les images
function openImageModal(imgSrc) {
    const modal = document.createElement('div');
    modal.className = 'image-modal';
    modal.innerHTML = `
        <div class="modal-content">
            <span class="close-modal" onclick="this.parentElement.parentElement.remove()">&times;</span>
            <img src="${imgSrc}" alt="Image agrandie">
        </div>
    `;
    modal.onclick = (e) => { if (e.target === modal) modal.remove(); };
    document.body.appendChild(modal);
}

// Charger les requêtes SQL dans le carousel
async function loadSQLCarousel() {
    const carouselContainer = document.getElementById('sql-carousel');
    const navContainer = document.getElementById('carousel-nav');
    
    carouselContainer.innerHTML = '';
    navContainer.innerHTML = '';
    
    for (let i = 0; i < sqlFiles.carousel.length; i++) {
        const filePath = sqlFiles.carousel[i];
        const fileName = filePath.split('/').pop();
        const content = await loadTextFile(filePath);
        
        // Créer le slide
        const slide = document.createElement('div');
        slide.className = `carousel-slide ${i === 0 ? 'active' : ''}`;
        slide.innerHTML = `
            <pre class="code-block"><span class="code-comment">-- ${fileName}</span>

${content}</pre>
        `;
        carouselContainer.appendChild(slide);
        
        // Créer le dot de navigation
        const dot = document.createElement('div');
        dot.className = `nav-dot ${i === 0 ? 'active' : ''}`;
        dot.setAttribute('data-slide', i);
        dot.onclick = () => showSlide(i);
        navContainer.appendChild(dot);
    }
}

// Charger toutes les requêtes SQL (section pliable)
async function loadAllSQL() {
    const container = document.getElementById('all-sql-queries');
    container.innerHTML = '<div class="loading">Chargement des requêtes...</div>';
    
    const sqlItems = [];
    for (const filePath of sqlFiles.all) {
        const fileName = filePath.split('/').pop();
        const content = await loadTextFile(filePath);
        
        sqlItems.push(`
            <div class="sql-item">
                <div class="sql-header">${fileName}</div>
                <pre class="code-block">${content}</pre>
            </div>
        `);
    }
    
    container.innerHTML = sqlItems.join('');
}

// ===========================================
// CAROUSEL FUNCTIONALITY
// ===========================================

let currentSlide = 0;
let slides = [];
let navDots = [];

function showSlide(index) {
    slides = document.querySelectorAll('.carousel-slide');
    navDots = document.querySelectorAll('.nav-dot');
    
    if (slides.length === 0) return;
    
    slides.forEach(slide => slide.classList.remove('active'));
    navDots.forEach(dot => dot.classList.remove('active'));
    
    slides[index].classList.add('active');
    navDots[index].classList.add('active');
    currentSlide = index;
}

// Auto-advance carousel
function startCarousel() {
    setInterval(() => {
        slides = document.querySelectorAll('.carousel-slide');
        if (slides.length > 0) {
            currentSlide = (currentSlide + 1) % slides.length;
            showSlide(currentSlide);
        }
    }, 8000);
}

// ===========================================
// SECTIONS PLIABLES
// ===========================================

function toggleCollapsible(id) {
    const content = document.getElementById(id);
    const btn = event.target.closest('.collapsible-btn');
    const arrow = btn.querySelector('.arrow');
    
    if (content.classList.contains('open')) {
        content.classList.remove('open');
        arrow.textContent = '▶';
    } else {
        content.classList.add('open');
        arrow.textContent = '▼';
        
        // Charger le contenu si nécessaire
        if (id === 'more-sql' && !content.dataset.loaded) {
            loadAllSQL();
            content.dataset.loaded = 'true';
        }
    }
}

// ===========================================
// NAVIGATION
// ===========================================

function scrollToSection(id) {
    const element = document.getElementById(id);
    if (element) {
        element.scrollIntoView({ 
            behavior: 'smooth', 
            block: 'start' 
        });
    }
}

// Effet sur les boutons de navigation
document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('.nav-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.nav-btn').forEach(b => {
                b.style.background = '#0d0d0d';
                b.style.color = '#777';
            });
            
            this.style.background = '#4a9eff';
            this.style.color = '#fff';
            
            setTimeout(() => {
                this.style.background = '#0d0d0d';
                this.style.color = '#777';
            }, 300);
        });
    });
});

// ===========================================
// INTERSECTION OBSERVER (ANIMATIONS)
// ===========================================

const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -100px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// ===========================================
// INITIALISATION
// ===========================================

window.addEventListener('DOMContentLoaded', async () => {
    console.log('Chargement du contenu...');
    
    // Charger tous les contenus
    await loadDocuments();
    loadImages();
    await loadSQLCarousel();
    
    // Démarrer le carousel
    startCarousel();
    
    // Observer les sections
    document.querySelectorAll('.section').forEach(section => {
        observer.observe(section);
    });
    
    console.log('Contenu chargé !');
});