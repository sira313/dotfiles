const fs = require('fs');
const path = require('path');
const os = require('os');
const { exec } = require('child_process');

// Helper path
const expandHomeDir = (p) => p.startsWith('~') ? path.join(os.homedir(), p.slice(1)) : p;

// Replace with your own
const BASE_DIR = __dirname;
const SOURCE_DIR = path.join(BASE_DIR, 'icon');
const INDEX_THEME_SOURCE = path.join(BASE_DIR, 'index.theme');
const VARA_TARGET_DIR = expandHomeDir('~/.local/share/icons/Vara');
const TARGET_PLACES_DIR = path.join(VARA_TARGET_DIR, 'scalable/places');
const COLOR_SCHEME = expandHomeDir('~/.local/share/color-schemes/DankMatugen.colors');

function getColors() {
    if (!fs.existsSync(COLOR_SCHEME)) {
        return { primary: '#3498db', secondary: '#2ecc71' }; // Fallback
    }
    const content = fs.readFileSync(COLOR_SCHEME, 'utf8');
    const rgbToHex = (rgb) => {
        const colors = rgb.split(',').map(x => parseInt(x.trim()).toString(16).padStart(2, '0'));
        return `#${colors.join('')}`;
    };

    const primaryMatch = content.match(/\[Colors:Selection\][^]*?BackgroundNormal=([\d, ]+)/);
    const secondaryMatch = content.match(/\[Colors:View\][^]*?ForegroundLink=([\d, ]+)/);

    return {
        primary: primaryMatch ? rgbToHex(primaryMatch[1]) : '#3498db',
        secondary: secondaryMatch ? rgbToHex(secondaryMatch[1]) : '#2ecc71'
    };
}

async function run() {
    const colors = getColors();
    console.log(`🎨 Menggunakan Warna - Primary: ${colors.primary}, Secondary: ${colors.secondary}`);

    if (!fs.existsSync(TARGET_PLACES_DIR)) {
        fs.mkdirSync(TARGET_PLACES_DIR, { recursive: true });
    }

    if (fs.existsSync(INDEX_THEME_SOURCE)) {
        fs.copyFileSync(INDEX_THEME_SOURCE, path.join(VARA_TARGET_DIR, 'index.theme'));
    }

    const icons = fs.readdirSync(SOURCE_DIR).filter(f => f.endsWith('.svg'));
    icons.forEach(file => {
        let svg = fs.readFileSync(path.join(SOURCE_DIR, file), 'utf8');
        
        svg = svg.replace(/fill="primary"/g, `fill="${colors.primary}"`)
                 .replace(/fill="secondary"/g, `fill="${colors.secondary}"`);

        fs.writeFileSync(path.join(TARGET_PLACES_DIR, file), svg);
    });

    console.log(`✅ ${icons.length} icon berhasil di-generate ke ~/.local/share/icons/Vara`);
    
    exec(`gtk-update-icon-cache -f ${VARA_TARGET_DIR}`);
}

run();
