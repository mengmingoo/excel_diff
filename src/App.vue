<template>
  <div class="app-container">
    <h1>跨表匹配工具</h1>

    <FileUpload
      @main-loaded="onMainLoaded"
      @cross-loaded="onCrossLoaded"
    />

    <MatchConfig
      :mainHeaders="mainHeaders"
      :crossHeaders="crossHeaders"
      @match="onMatch"
    />

    <ResultTable
      v-if="resultRows.length > 0"
      v-model:filterMode="filterMode"
      :resultRows="resultRows"
      :mainFormat="mainFormat"
      @delete-row="onDeleteRow"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import FileUpload from './components/FileUpload.vue'
import MatchConfig from './components/MatchConfig.vue'
import ResultTable from './components/ResultTable.vue'
import { match } from './utils/matcher.js'

const mainHeaders = ref([])
const mainRows = ref([])
const mainFormat = ref('xlsx')
const crossHeaders = ref([])
const crossRows = ref([])
const resultRows = ref([])
const filterMode = ref('all')

function onMainLoaded({ headers, rows, filePath }) {
  mainHeaders.value = headers
  mainRows.value = rows
  mainFormat.value = filePath.split('.').pop().toLowerCase()
}

function onCrossLoaded({ headers, rows }) {
  crossHeaders.value = headers
  crossRows.value = rows
}

function onMatch({ mainCol, crossCol }) {
  const result = match(mainRows.value, crossRows.value, mainCol, crossCol)
  resultRows.value = result
  filterMode.value = 'all'
}

function onDeleteRow(index) {
  resultRows.value.splice(index, 1)
}
</script>

<style>
.app-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

h1 {
  font-size: 20px;
  color: #303133;
  margin-bottom: 20px;
  text-align: center;
}
</style>