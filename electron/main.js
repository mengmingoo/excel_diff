const { app, BrowserWindow, ipcMain, dialog, Menu } = require('electron')
const path = require('path')
const fs = require('fs')

let mainWindow = null

// 读取应用配置
function loadConfig() {
  const configPath = path.join(__dirname, '../app.config.json')
  try {
    const raw = fs.readFileSync(configPath, 'utf-8')
    return JSON.parse(raw)
  } catch (e) {
    return {
      appName: '跨表匹配工具',
      appVersion: '1.0.0',
      developer: 'mengming',
      icon: 'assets/icon.png'
    }
  }
}

const appConfig = loadConfig()

// 解析图标路径
function getIconPath() {
  const iconPath = path.join(__dirname, '..', appConfig.icon || 'assets/icon.png')
  if (fs.existsSync(iconPath)) {
    return iconPath
  }
  return null
}

// 设置自定义菜单（仅保留"关于"）
function setAppMenu() {
  const template = [
    {
      label: '关于',
      submenu: [
        {
          label: '关于软件',
          click: () => {
            dialog.showMessageBox(mainWindow, {
              type: 'info',
              title: '关于',
              message: appConfig.appName,
              detail: `版本：${appConfig.appVersion}\n开发者：${appConfig.developer}`,
              buttons: ['确定']
            })
          }
        },
        { type: 'separator' },
        {
          label: '退出',
          accelerator: process.platform === 'darwin' ? 'Cmd+Q' : 'Alt+F4',
          click: () => app.quit()
        }
      ]
    }
  ]

  const menu = Menu.buildFromTemplate(template)
  Menu.setApplicationMenu(menu)
}

function createWindow() {
  const iconPath = getIconPath()

  mainWindow = new BrowserWindow({
    width: 1400,
    height: 900,
    icon: iconPath,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    }
  })

  // 开发模式加载 vite dev server，生产模式加载打包文件
  if (process.env.NODE_ENV === 'development') {
    mainWindow.loadURL('http://localhost:5173')
    mainWindow.webContents.openDevTools()
  } else {
    mainWindow.loadFile(path.join(__dirname, '../dist/index.html'))
  }

  // 阻止拖放文件时的默认导航行为，确保拖拽上传正常工作
  mainWindow.webContents.on('will-navigate', (event) => {
    event.preventDefault()
  })

  mainWindow.on('closed', () => {
    mainWindow = null
  })
}

app.whenReady().then(() => {
  setAppMenu()
  createWindow()
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow()
  }
})

// 保存文件对话框
ipcMain.handle('show-save-dialog', async (event, options) => {
  const result = await dialog.showSaveDialog(mainWindow, options)
  return result
})