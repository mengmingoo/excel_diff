import { describe, it, expect } from 'vitest'
import { match } from '../src/utils/matcher.js'

describe('match', () => {
  it('正常精确匹配（1对1）', () => {
    const mainRows = [
      { '姓名': '张三', '部门': '技术' },
      { '姓名': '李四', '部门': '产品' }
    ]
    const crossRows = [
      { '姓名': '张三', '工资': 10000 },
      { '姓名': '李四', '工资': 12000 }
    ]

    const result = match(mainRows, crossRows, '姓名', '姓名')
    expect(result).toHaveLength(2)
    expect(result[0]['主表_姓名']).toBe('张三')
    expect(result[0]['主表_部门']).toBe('技术')
    expect(result[0]['跨表_工资']).toBe(10000)
    expect(result[1]['主表_姓名']).toBe('李四')
    expect(result[1]['跨表_工资']).toBe(12000)
  })

  it('跨表多条匹配（1对多，全部带过来）', () => {
    const mainRows = [
      { '姓名': '张三', '部门': '技术' }
    ]
    const crossRows = [
      { '姓名': '张三', '项目': 'A' },
      { '姓名': '张三', '项目': 'B' }
    ]

    const result = match(mainRows, crossRows, '姓名', '姓名')
    expect(result).toHaveLength(2)
    expect(result[0]['主表_姓名']).toBe('张三')
    expect(result[0]['跨表_项目']).toBe('A')
    expect(result[1]['主表_姓名']).toBe('张三')
    expect(result[1]['跨表_项目']).toBe('B')
  })

  it('主表行无匹配（保留，跨表字段为空）', () => {
    const mainRows = [
      { '姓名': '张三', '部门': '技术' },
      { '姓名': '王五', '部门': '设计' }
    ]
    const crossRows = [
      { '姓名': '张三', '工资': 10000 }
    ]

    const result = match(mainRows, crossRows, '姓名', '姓名')
    expect(result).toHaveLength(2)
    expect(result[0]['主表_姓名']).toBe('张三')
    expect(result[0]['跨表_工资']).toBe(10000)
    expect(result[1]['主表_姓名']).toBe('王五')
    expect(result[1]['跨表_工资']).toBe('')
  })

  it('空值匹配：空=空匹配，空≠非空不匹配', () => {
    const mainRows = [
      { '姓名': '', '部门': '未知' },
      { '姓名': '张三', '部门': '技术' }
    ]
    const crossRows = [
      { '姓名': '', '工资': 5000 },
      { '姓名': '张三', '工资': 10000 }
    ]

    const result = match(mainRows, crossRows, '姓名', '姓名')
    expect(result).toHaveLength(2)
    expect(result[0]['主表_姓名']).toBe('')
    expect(result[0]['跨表_工资']).toBe(5000)
    expect(result[1]['主表_姓名']).toBe('张三')
    expect(result[1]['跨表_工资']).toBe(10000)
  })

  it('空输入：主表为空返回空数组', () => {
    const result = match([], [{ '姓名': '张三' }], '姓名', '姓名')
    expect(result).toEqual([])
  })

  it('空输入：跨表为空，主表行全部保留', () => {
    const mainRows = [{ '姓名': '张三', '部门': '技术' }]
    const result = match(mainRows, [], '姓名', '姓名')
    expect(result).toHaveLength(1)
    expect(result[0]['主表_姓名']).toBe('张三')
  })

  it('列名冲突时自动加前缀', () => {
    const mainRows = [{ '姓名': '张三', '年龄': 25 }]
    const crossRows = [{ '姓名': '张三', '年龄': 30 }]

    const result = match(mainRows, crossRows, '姓名', '姓名')
    expect(result).toHaveLength(1)
    expect(result[0]['主表_姓名']).toBe('张三')
    expect(result[0]['主表_年龄']).toBe(25)
    expect(result[0]['跨表_姓名']).toBe('张三')
    expect(result[0]['跨表_年龄']).toBe(30)
  })
})