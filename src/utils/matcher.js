/**
 * 精确匹配主表和跨表数据
 * @param {object[]} mainRows - 主表行数据
 * @param {object[]} crossRows - 跨表行数据
 * @param {string} mainCol - 主表匹配列名
 * @param {string} crossCol - 跨表匹配列名
 * @returns {object[]} 合并后的结果行
 */
export function match(mainRows, crossRows, mainCol, crossCol) {
  if (mainRows.length === 0) return []

  const mainHeaders = mainRows.length > 0 ? Object.keys(mainRows[0]) : []
  const crossHeaders = crossRows.length > 0 ? Object.keys(crossRows[0]) : []

  // 构建跨表索引：key -> matching rows
  const crossIndex = new Map()
  for (const row of crossRows) {
    const key = row[crossCol] ?? ''
    if (!crossIndex.has(key)) {
      crossIndex.set(key, [])
    }
    crossIndex.get(key).push(row)
  }

  const result = []
  for (const mainRow of mainRows) {
    const key = mainRow[mainCol] ?? ''
    const matchedRows = crossIndex.get(key) || []

    if (matchedRows.length === 0) {
      // 无匹配：保留主表行，跨表字段为空
      const row = { __unmatched__: true }
      for (const h of mainHeaders) {
        row[`主表_${h}`] = mainRow[h]
      }
      for (const h of crossHeaders) {
        row[`跨表_${h}`] = ''
      }
      result.push(row)
    } else {
      // 有匹配：每条匹配结果生成一行
      for (const crossRow of matchedRows) {
        const row = {}
        for (const h of mainHeaders) {
          row[`主表_${h}`] = mainRow[h]
        }
        for (const h of crossHeaders) {
          row[`跨表_${h}`] = crossRow[h]
        }
        result.push(row)
      }
    }
  }

  return result
}