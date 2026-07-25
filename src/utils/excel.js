import * as XLSX from 'xlsx'
import fs from 'fs'
import path from 'path'

const ALLOWED_EXT = ['.xlsx', '.xls', '.csv']

/**
 * 校验文件格式
 */
export function validateFormat(filePath) {
  const ext = path.extname(filePath).toLowerCase()
  if (!ALLOWED_EXT.includes(ext)) {
    throw new Error('仅支持 .xlsx/.xls/.csv 格式')
  }
}

/**
 * 解析文件，返回 { headers, rows }
 */
export function parseFile(filePath) {
  validateFormat(filePath)
  const ext = path.extname(filePath).toLowerCase()

  let workbook
  try {
    if (ext === '.csv') {
      const content = fs.readFileSync(filePath, 'utf-8')
      workbook = XLSX.read(content, { type: 'string' })
    } else {
      // xlsx/xls 文件校验：真实 Office 文件应以 ZIP 头或 OLE 头开头
      const buf = Buffer.alloc(4)
      const fd = fs.openSync(filePath, 'r')
      fs.readSync(fd, buf, 0, 4, 0)
      fs.closeSync(fd)
      const header = buf.toString('hex')
      const validHeaders = ['504b0304', 'd0cf11e0']
      if (!validHeaders.includes(header)) {
        throw new Error('文件解析失败，请检查文件是否损坏')
      }
      workbook = XLSX.readFile(filePath)
    }
  } catch (e) {
    throw new Error('文件解析失败，请检查文件是否损坏')
  }

  if (!workbook.SheetNames || workbook.SheetNames.length === 0) {
    throw new Error('文件解析失败，请检查文件是否损坏')
  }

  const sheetName = workbook.SheetNames[0]
  const sheet = workbook.Sheets[sheetName]
  const rows = XLSX.utils.sheet_to_json(sheet, { defval: '' })

  let headers = []
  if (rows.length > 0) {
    headers = Object.keys(rows[0])
  } else if (sheet['!ref']) {
    const range = XLSX.utils.decode_range(sheet['!ref'])
    for (let C = range.s.c; C <= range.e.c; ++C) {
      const cell = sheet[XLSX.utils.encode_cell({ r: range.s.r, c: C })]
      headers.push(cell ? String(cell.v) : '')
    }
  }

  return { headers, rows }
}

/**
 * 导出文件
 */
export function exportFile(rows, headers, filePath, format) {
  try {
    const ws = XLSX.utils.json_to_sheet(rows, { header: headers })
    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, 'Sheet1')

    if (format === 'csv') {
      const csv = XLSX.utils.sheet_to_csv(ws)
      fs.writeFileSync(filePath, csv, 'utf-8')
    } else {
      XLSX.writeFile(wb, filePath)
    }
  } catch (e) {
    throw new Error('导出失败，请重试')
  }
}