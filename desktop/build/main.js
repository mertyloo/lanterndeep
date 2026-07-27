const { app, BrowserWindow, Menu } = require('electron');
const path = require('path');

function createWindow () {
  const win = new BrowserWindow({
    width: 1180,
    height: 820,
    minWidth: 760,
    minHeight: 560,
    backgroundColor: '#0d0a08',
    title: 'Lanterndeep',
    icon: path.join(__dirname, 'icon.png'),
    autoHideMenuBar: true,
    webPreferences: { contextIsolation: true, nodeIntegration: false, backgroundThrottling: false }
  });
  Menu.setApplicationMenu(null);
  win.loadFile('index.html');
  win.setTitle('Lanterndeep');
  win.on('page-title-updated', e => e.preventDefault());

  // F11 fullscreen, F12 dev tools
  win.webContents.on('before-input-event', (e, input) => {
    if (input.type !== 'keyDown') return;
    if (input.key === 'F11') win.setFullScreen(!win.isFullScreen());
    if (input.key === 'F12') win.webContents.toggleDevTools();
  });
}

app.whenReady().then(() => {
  createWindow();
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});
