#!/usr/bin/env node

/**
 * Script di verifica setup backend NULL
 * Esegue controlli base per verificare che tutto sia configurato correttamente
 */

import fs from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
};

let errors = 0;
let warnings = 0;
let success = 0;

function log(message, type = 'info') {
  const prefix = {
    success: `${colors.green}✓${colors.reset}`,
    error: `${colors.red}✗${colors.reset}`,
    warning: `${colors.yellow}⚠${colors.reset}`,
    info: `${colors.blue}ℹ${colors.reset}`,
  }[type] || '';

  console.log(`${prefix} ${message}`);
}

function checkFile(filePath, required = true) {
  const fullPath = join(__dirname, filePath);
  const exists = fs.existsSync(fullPath);

  if (exists) {
    log(`File trovato: ${filePath}`, 'success');
    success++;
    return true;
  } else {
    if (required) {
      log(`File mancante (richiesto): ${filePath}`, 'error');
      errors++;
    } else {
      log(`File mancante (opzionale): ${filePath}`, 'warning');
      warnings++;
    }
    return false;
  }
}

function checkDirectory(dirPath, required = true) {
  const fullPath = join(__dirname, dirPath);
  const exists = fs.existsSync(fullPath) && fs.statSync(fullPath).isDirectory();

  if (exists) {
    log(`Cartella trovata: ${dirPath}`, 'success');
    success++;
    return true;
  } else {
    if (required) {
      log(`Cartella mancante (richiesta): ${dirPath}`, 'error');
      errors++;
    } else {
      log(`Cartella mancante (opzionale): ${dirPath}`, 'warning');
      warnings++;
    }
    return false;
  }
}

function checkPackageJson() {
  const packagePath = join(__dirname, 'package.json');
  if (!fs.existsSync(packagePath)) {
    log('package.json non trovato', 'error');
    errors++;
    return false;
  }

  try {
    const content = fs.readFileSync(packagePath, 'utf8');
    const pkg = JSON.parse(content);

    log('package.json valido', 'success');
    success++;

    // Verifica dipendenze essenziali
    const requiredDeps = ['express', 'mongoose', 'dotenv', 'cors', 'helmet'];
    const missingDeps = requiredDeps.filter(dep => !pkg.dependencies?.[dep]);

    if (missingDeps.length > 0) {
      log(`Dipendenze mancanti: ${missingDeps.join(', ')}`, 'warning');
      warnings++;
    } else {
      log('Tutte le dipendenze essenziali presenti', 'success');
      success++;
    }

    return true;
  } catch (error) {
    log(`Errore parsing package.json: ${error.message}`, 'error');
    errors++;
    return false;
  }
}

function checkEnvFile() {
  const envExample = join(__dirname, '.env.example');
  const env = join(__dirname, '.env');

  if (fs.existsSync(envExample)) {
    log('.env.example trovato', 'success');
    success++;
  } else {
    log('.env.example mancante', 'error');
    errors++;
  }

  if (fs.existsSync(env)) {
    log('.env trovato (configurazione presente)', 'success');
    success++;
  } else {
    log('.env mancante (copia da .env.example)', 'warning');
    warnings++;
  }
}

function checkNodeModules() {
  const nodeModulesPath = join(__dirname, 'node_modules');
  if (fs.existsSync(nodeModulesPath)) {
    log('node_modules trovato (dipendenze installate)', 'success');
    success++;
    return true;
  } else {
    log('node_modules mancante (esegui: npm install)', 'warning');
    warnings++;
    return false;
  }
}

console.log('\n' + '='.repeat(50));
console.log('  VERIFICA SETUP BACKEND NULL');
console.log('='.repeat(50) + '\n');

// Verifica file essenziali
console.log('📄 Verifica file essenziali:');
checkFile('package.json', true);
checkFile('src/server.js', true);
checkFile('src/config/env.js', true);
checkFile('src/config/database.js', true);
checkFile('src/config/tls.js', true);
checkFile('src/middleware/errorHandler.js', true);
checkFile('src/middleware/notFound.js', true);
checkFile('src/routes/health.js', true);
checkFile('src/utils/logger.js', true);
checkFile('.gitignore', true);
checkFile('README.md', true);

console.log('\n📁 Verifica cartelle:');
checkDirectory('src', true);
checkDirectory('src/config', true);
checkDirectory('src/middleware', true);
checkDirectory('src/routes', true);
checkDirectory('src/utils', true);
checkDirectory('certificates', false);
checkDirectory('uploads', false);

console.log('\n📦 Verifica package.json:');
checkPackageJson();

console.log('\n⚙️  Verifica configurazione:');
checkEnvFile();

console.log('\n📚 Verifica dipendenze:');
const depsInstalled = checkNodeModules();

console.log('\n' + '='.repeat(50));
console.log('  RISULTATO');
console.log('='.repeat(50));
console.log(`${colors.green}✓ Successi: ${success}${colors.reset}`);
if (warnings > 0) {
  console.log(`${colors.yellow}⚠ Avvisi: ${warnings}${colors.reset}`);
}
if (errors > 0) {
  console.log(`${colors.red}✗ Errori: ${errors}${colors.reset}`);
}

console.log('\n📋 Prossimi passi:');
if (errors > 0) {
  console.log('  1. Risolvi gli errori indicati sopra');
}
if (!depsInstalled) {
  console.log('  2. Installa dipendenze: npm install');
}
if (!fs.existsSync(join(__dirname, '.env'))) {
  console.log('  3. Crea file .env: copia .env.example in .env');
  console.log('  4. Modifica .env con le tue configurazioni');
}
if (errors === 0 && depsInstalled) {
  console.log('  1. Avvia server: npm start');
  console.log('  2. Testa health check: curl http://localhost:3000/health');
}

console.log('\n');

// Exit code
process.exit(errors > 0 ? 1 : 0);

