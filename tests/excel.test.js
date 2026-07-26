import { describe, it, expect } from 'vitest'
import * as XLSX from 'xlsx'
import { parseFile, exportFile } from '../src/utils/excel.js'
import fs from 'fs'
import path from 'path'

const TEST_DIR = path.join(__dirname, 'fixtures')

function ensureFixturesDir() {
  if (!fs.existsSync(TEST_DIR)) fs.mkdirSync(TEST_DIR, { recursive: true })
}

function createTestXlsx(filePath, headers, rows) {
  const ws = XLSX.utils.json_to_sheet(rows, { header: headers })
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Sheet1')
  XLSX.writeFile(wb, filePath)
}

function createTestCsv(filePath, headers, rows) {
  const lines = [headers.join(',')]
  for (const row of rows) {
    lines.push(headers.map(h => row[h] ?? '').join(','))
  }
  fs.writeFileSync(filePath, lines.join('\n'), 'utf-8')
}

describe('parseFile', () => {
  it('正常解析 .xlsx 文件', async () => {
    ensureFixturesDir()
    const filePath = path.join(TEST_DIR, 'test_normal.xlsx')
    createTestXlsx(filePath, ['姓名', '年龄'], [
      { '姓名': '张三', '年龄': 25 },
      { '姓名': '李四', '年龄': 30 }
    ])

    const result = await parseFile(filePath)
    expect(result.headers).toEqual(['姓名', '年龄'])
    expect(result.rows).toHaveLength(2)
    expect(result.rows[0]).toEqual({ '姓名': '张三', '年龄': 25 })
    expect(result.rows[1]).toEqual({ '姓名': '李四', '年龄': 30 })
  })

  it('正常解析 .csv 文件', async () => {
    ensureFixturesDir()
    const filePath = path.join(TEST_DIR, 'test_csv.csv')
    createTestCsv(filePath, ['姓名', '年龄'], [
      { '姓名': '王五', '年龄': 28 },
      { '姓名': '赵六', '年龄': 35 }
    ])

    const result = await parseFile(filePath)
    expect(result.headers).toEqual(['姓名', '年龄'])
    expect(result.rows).toHaveLength(2)
    expect(result.rows[0]).toEqual({ '姓名': '王五', '年龄': 28 })
  })

  it('解析空表格', async () => {
    ensureFixturesDir()
    const filePath = path.join(TEST_DIR, 'empty.xlsx')
    createTestXlsx(filePath, ['姓名', '年龄'], [])

    const result = await parseFile(filePath)
    expect(result.headers).toEqual(['姓名', '年龄'])
    expect(result.rows).toEqual([])
  })
})

describe('exportFile', () => {
  it('导出 .xlsx 文件内容正确', async () => {
    ensureFixturesDir()
    const outPath = path.join(TEST_DIR, 'export_test.xlsx')
    const headers = ['姓名', '年龄']
    const rows = [{ '姓名': '张三', '年龄': 25 }]

    await exportFile(rows, headers, outPath, 'xlsx')
    expect(fs.existsSync(outPath)).toBe(true)

    const result = await parseFile(outPath)
    expect(result.rows).toHaveLength(1)
    expect(result.rows[0]['姓名']).toBe('张三')
  })
})