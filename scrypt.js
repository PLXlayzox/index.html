// ===========================================
// TIMER FUNCTIONALITY - BARRE VERTICALE
// ===========================================

let timerInterval = null;
let timeRemaining = 15 * 60; // 15 minutes en secondes
const totalTime = 15 * 60;
let isTimerRunning = false;

function updateTimerDisplay() {
    const minutes = Math.floor(timeRemaining / 60);
    const seconds = timeRemaining % 60;
    document.getElementById('timerDisplay').textContent = 
        `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    
    const progressBar = document.getElementById('timerProgressBar');
    const progress = (timeRemaining / totalTime) * 100;
    progressBar.style.height = progress + '%';
    
    // Changer la couleur selon le temps restant
    if (progress < 25) {
        progressBar.style.background = 'linear-gradient(180deg, #ff4a4a, #cc2d2d)';
    } else if (progress < 50) {
        progressBar.style.background = 'linear-gradient(180deg, #ffaa4a, #cc7a2d)';
    } else {
        progressBar.style.background = 'linear-gradient(180deg, #4a9eff, #2d7acc)';
    }
}

function startTimer() {
    if (isTimerRunning) return;
    
    isTimerRunning = true;
    document.getElementById('startBtn').style.display = 'none';
    document.getElementById('pauseBtn').style.display = 'block';
    
    timerInterval = setInterval(() => {
        if (timeRemaining > 0) {
            timeRemaining--;
            updateTimerDisplay();
        } else {
            pauseTimer();
            // Animation de fin
            const progressBar = document.getElementById('timerProgressBar');
            progressBar.style.background = 'linear-gradient(180deg, #ff4a4a, #cc2d2d)';
            alert('⏰ Temps écoulé ! Votre présentation de 15 minutes est terminée.');
        }
    }, 1000);
}

function pauseTimer() {
    isTimerRunning = false;
    clearInterval(timerInterval);
    document.getElementById('startBtn').style.display = 'block';
    document.getElementById('pauseBtn').style.display = 'none';
}

function resetTimer() {
    pauseTimer();
    timeRemaining = totalTime;
    updateTimerDisplay();
}

// ===========================================
// NAVIGATION ACTIVE
// ===========================================

function updateActiveNav() {
    const sections = document.querySelectorAll('.section[id]');
    const navLinks = document.querySelectorAll('.side-nav-link');
    
    let currentSection = '';
    
    sections.forEach(section => {
        const sectionTop = section.offsetTop;
        const sectionHeight = section.clientHeight;
        if (window.scrollY >= (sectionTop - 200)) {
            currentSection = section.getAttribute('id');
        }
    });
    
    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === '#' + currentSection) {
            link.classList.add('active');
        }
    });
}

window.addEventListener('scroll', updateActiveNav);

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
    // Tous les autres fichiers SQL (section pliable avec navigation)
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
    'ressources/images/image(2).png',
    'ressources/images/image(3).png',
    'ressources/images/image(4).png',
    'ressources/images/image(5).png',
    'ressources/images/image(6).png'
];

// Cache pour les fichiers SQL chargés
const sqlCache = {};

// ===========================================
// CHARGEMENT DES FICHIERS
// ===========================================

async function loadTextFile(path) {
    try {
        console.log(`📂 Tentative de chargement: ${path}`);
        const response = await fetch(path);
        if (!response.ok) {
            console.error(`❌ Erreur ${response.status}: ${path}`);
            throw new Error(`Erreur de chargement: ${path}`);
        }
        console.log(`✅ Chargé avec succès: ${path}`);
        return await response.text();
    } catch (error) {
        console.error('❌ Erreur:', error);
        return `-- Erreur lors du chargement du fichier ${path}\n-- Vérifiez que le fichier existe et que le chemin est correct`;
    }
}

// Charger les fichiers texte
async function loadDocuments() {
    console.log('📄 Chargement des documents texte...');
    
    try {
        // Journal de bord
        const journalContent = await loadTextFile('ressources/journal de bord.txt');
        document.getElementById('journal-content').innerHTML = 
            `<pre class="document-text">${journalContent}</pre>`;
        console.log('✅ Journal de bord chargé');
    } catch (error) {
        console.error('❌ Erreur journal de bord:', error);
    }
    
    try {
        // Info entreprise
        const infoContent = await loadTextFile('ressources/info voc entreprise.txt');
        document.getElementById('info-voc-content').innerHTML = 
            `<pre class="document-text">${infoContent}</pre>`;
        console.log('✅ Info entreprise chargée');
    } catch (error) {
        console.error('❌ Erreur info entreprise:', error);
    }
    
    try {
        // Exercices
        const exerciceContent = await loadTextFile('ressources/exercice.txt');
        document.getElementById('exercice-content').innerHTML = 
            `<pre class="document-text">${exerciceContent}</pre>`;
        console.log('✅ Exercices chargés');
    } catch (error) {
        console.error('❌ Erreur exercices:', error);
    }
}

// Charger les images
function loadImages() {
    console.log('🖼️ Chargement de la galerie d\'images...');
    const gallery = document.getElementById('image-gallery');
    
    if (!gallery) {
        console.error('❌ Élément image-gallery non trouvé!');
        return;
    }
    
    imageFiles.forEach((imgPath, index) => {
        const imgDiv = document.createElement('div');
        imgDiv.className = 'gallery-item';
        imgDiv.innerHTML = `
            <img src="${imgPath}" alt="Aperçu ${index + 1}" onclick="openImageModal('${imgPath}')" onerror="console.error('❌ Erreur chargement image: ${imgPath}')">
        `;
        gallery.appendChild(imgDiv);
    });
    
    console.log(`✅ ${imageFiles.length} images ajoutées à la galerie`);
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
    console.log('📄 Chargement du carousel SQL...');
    const carouselContainer = document.getElementById('sql-carousel');
    const navContainer = document.getElementById('carousel-nav');
    
    if (!carouselContainer || !navContainer) {
        console.error('❌ Éléments carousel non trouvés!');
        return;
    }
    
    carouselContainer.innerHTML = '';
    navContainer.innerHTML = '';
    
    for (let i = 0; i < sqlFiles.carousel.length; i++) {
        const filePath = sqlFiles.carousel[i];
        const fileName = filePath.split('/').pop();
        console.log(`📂 Chargement SQL ${i + 1}/${sqlFiles.carousel.length}: ${fileName}`);
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
    
    console.log('✅ Carousel SQL chargé avec succès!');
}

// Charger la navigation SQL avec système de fichiers
async function loadSQLBrowser() {
    const sidebar = document.getElementById('sql-sidebar');
    const viewer = document.getElementById('sql-viewer');
    
    sidebar.innerHTML = '';
    
    for (let i = 0; i < sqlFiles.all.length; i++) {
        const filePath = sqlFiles.all[i];
        const fileName = filePath.split('/').pop();
        
        const fileItem = document.createElement('div');
        fileItem.className = 'sql-file-item';
        fileItem.textContent = fileName;
        fileItem.onclick = () => showSQLFile(filePath, fileName, fileItem);
        
        sidebar.appendChild(fileItem);
    }
}

// Afficher un fichier SQL sélectionné
async function showSQLFile(filePath, fileName, fileItem) {
    const viewer = document.getElementById('sql-viewer');
    
    // Mettre à jour l'élément actif
    document.querySelectorAll('.sql-file-item').forEach(item => {
        item.classList.remove('active');
    });
    fileItem.classList.add('active');
    
    // Charger le contenu (avec cache)
    if (!sqlCache[filePath]) {
        viewer.innerHTML = '<div class="loading">Chargement...</div>';
        sqlCache[filePath] = await loadTextFile(filePath);
    }
    
    viewer.innerHTML = `
        <pre class="code-block"><span class="code-comment">-- ${fileName}</span>

${sqlCache[filePath]}</pre>
    `;
    
    // Scroll en haut du viewer
    viewer.scrollTop = 0;
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
    
    // Boucler si nécessaire
    if (index >= slides.length) index = 0;
    if (index < 0) index = slides.length - 1;
    
    slides.forEach(slide => slide.classList.remove('active'));
    navDots.forEach(dot => dot.classList.remove('active'));
    
    slides[index].classList.add('active');
    navDots[index].classList.add('active');
    currentSlide = index;
}

function nextSlide() {
    showSlide(currentSlide + 1);
}

function prevSlide() {
    showSlide(currentSlide - 1);
}

// Auto-advance carousel
function startCarousel() {
    setInterval(() => {
        slides = document.querySelectorAll('.carousel-slide');
        if (slides.length > 0) {
            currentSlide = (currentSlide + 1) % slides.length;
            showSlide(currentSlide);
        }
    }, 10000); // Changé à 10 secondes pour plus de temps de lecture
}

// Navigation clavier pour le carousel
document.addEventListener('keydown', (e) => {
    if (e.key === 'ArrowLeft') {
        prevSlide();
    } else if (e.key === 'ArrowRight') {
        nextSlide();
    }
});

// ===========================================
// SECTIONS PLIABLES
// ===========================================

function toggleCollapsible(id, event) {
    // Si event n'est pas passé, on utilise window.event
    const evt = event || window.event;
    const content = document.getElementById(id);
    const btn = evt ? evt.target.closest('.collapsible-btn') : document.querySelector(`[onclick*="${id}"]`);
    const arrow = btn.querySelector('.arrow');
    
    if (content.classList.contains('open')) {
        content.classList.remove('open');
        arrow.textContent = '▶';
    } else {
        content.classList.add('open');
        arrow.textContent = '▼';
        
        // Charger le contenu si nécessaire
        if (id === 'more-sql' && !content.dataset.loaded) {
            loadSQLBrowser();
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
// RACCOURCIS CLAVIER
// ===========================================

document.addEventListener('keydown', (e) => {
    // Espace = Démarrer/Pause Timer
    if (e.key === ' ') {
        if (!e.target.matches('input, textarea, button')) {
            e.preventDefault();
            if (isTimerRunning) {
                pauseTimer();
            } else {
                startTimer();
            }
        }
    }
    
    // R = Reset Timer
    if (e.key === 'r' || e.key === 'R') {
        if (!e.target.matches('input, textarea')) {
            resetTimer();
        }
    }
});

// ===========================================
// INITIALISATION
// ===========================================

window.addEventListener('DOMContentLoaded', async () => {
    console.log('🚀 Chargement du contenu...');
    
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
    
    // Initialiser le timer
    updateTimerDisplay();
    updateActiveNav();
    
    console.log('✅ Contenu chargé avec succès !');
    console.log('💡 Raccourcis clavier :');
    console.log('  - Espace : Démarrer/Pause timer');
    console.log('  - R : Reset timer');
    console.log('  - ← → : Naviguer dans le carousel SQL');
});