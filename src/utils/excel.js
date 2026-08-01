import * as XLSX from 'xlsx'

const ALLOWED_EXT = /\.(xlsx|xls|csv)$/i

/**
 * 获取 fs 模块，兼容 Electron 渲染进程和 Node.js 测试环境
 * - Electron: window.require('fs') 绕过 Vite 的 browser-external stub
 * - Node.js: eval('require')('fs') 绕过 Vite 的静态分析
 */
function getFs() {
  if (typeof window !== 'undefined' && window.require) {
    return window.require('fs')
  }
  return eval('require')('fs')
}

/**
 * 校验文件格式（支持文件名或路径）
 */
export function validateFormat(filePath) {
  if (!ALLOWED_EXT.test(filePath)) {
    throw new Error('仅支持 .xlsx/.xls/.csv 格式')
  }
}

/**
 * 从 File 对象读取为 ArrayBuffer
 */
function readFileAsBuffer(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = () => resolve(new Uint8Array(reader.result))
    reader.onerror = () => reject(new Error('文件读取失败'))
    reader.readAsArrayBuffer(file)
  })
}

/**
 * 解析文件，返回 { headers, rows }
 * fileSource: 文件路径字符串（Electron）或 File 对象（浏览器/拖拽）
 * headerRow: 表头所在行号（1-based），默认 1
 */
export async function parseFile(fileSource, headerRow = 1) {
  let workbook
  const headerIndex = headerRow - 1 // 转为 0-based

  if (typeof fileSource === 'string') {
    // Electron 环境：文件路径
    validateFormat(fileSource)
    try {
      const ext = fileSource.toLowerCase().split('.').pop()
      if (ext === 'csv') {
        const fs = getFs()
        const content = fs.readFileSync(fileSource, 'utf-8')
        workbook = XLSX.read(content, { type: 'string' })
      } else {
        workbook = XLSX.readFile(fileSource)
      }
    } catch (e) {
      throw new Error('文件解析失败，请检查文件是否损坏')
    }
  } else {
    // 浏览器/拖拽环境：File 对象
    validateFormat(fileSource.name)
    try {
      const data = await readFileAsBuffer(fileSource)
      workbook = XLSX.read(data, { type: 'array' })
    } catch (e) {
      throw new Error('文件解析失败，请检查文件是否损坏')
    }
  }

  if (!workbook.SheetNames || workbook.SheetNames.length === 0) {
    throw new Error('文件解析失败，请检查文件是否损坏')
  }

  const sheetName = workbook.SheetNames[0]
  const sheet = workbook.Sheets[sheetName]

  // 从指定行开始解析，该行作为表头
  const rows = XLSX.utils.sheet_to_json(sheet, { defval: '', range: headerIndex })

  let headers = []
  if (rows.length > 0) {
    headers = Object.keys(rows[0])
  } else {
    // 手动提取表头行
    const range = XLSX.utils.decode_range(sheet['!ref'])
    for (let C = range.s.c; C <= range.e.c; ++C) {
      const cell = sheet[XLSX.utils.encode_cell({ r: headerIndex, c: C })]
      headers.push(cell ? String(cell.v) : '')
    }
  }

  return { headers, rows }
}

/**
 * 导出文件
 */
export async function exportFile(rows, headers, filePath, format) {
  try {
    const ws = XLSX.utils.json_to_sheet(rows, { header: headers })
    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, 'Sheet1')

    const fs = getFs()

    if (format === 'csv') {
      const csv = XLSX.utils.sheet_to_csv(ws)
      fs.writeFileSync(filePath, '\uFEFF' + csv, 'utf-8')
    } else {
      // 使用 type: 'array' 而非 'buffer'，兼容 Electron 渲染进程
      const data = XLSX.write(wb, { type: 'array', bookType: 'xlsx' })
      fs.writeFileSync(filePath, Buffer.from(data))
    }
  } catch (e) {
    console.error('导出失败:', e)
    throw new Error('导出失败，请重试')
  }
}