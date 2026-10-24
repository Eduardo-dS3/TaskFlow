/// <reference path="../pb_data/types.d.ts" />

// Regras de negócio executadas no servidor do TaskFlow.

// ---------------------------------------------------------------------------
// App web (pb_public)
// ---------------------------------------------------------------------------

// O navegador revalida os arquivos do app a cada acesso (resposta 304 quando
// nada mudou): depois de atualizar o servidor ninguém fica na versão antiga.
routerUse((e) => {
  const path = e.request.url.path
  if (!path.startsWith("/api/") && !path.startsWith("/_/")) {
    e.response.header().set("Cache-Control", "no-cache")
  }
  return e.next()
})

// ---------------------------------------------------------------------------
// Configuração inicial (primeiro administrador)
// ---------------------------------------------------------------------------

routerAdd("GET", "/api/taskflow/setup", (e) => {
  return e.json(200, { needsSetup: e.app.countRecords("users") === 0 })
})

routerAdd("POST", "/api/taskflow/setup", (e) => {
  const utils = require(`${__hooks}/taskflow_utils.js`)
  return utils.handleSetup(e)
})

// ---------------------------------------------------------------------------
// Tarefas
// ---------------------------------------------------------------------------

onRecordCreate((e) => {
  const utils = require(`${__hooks}/taskflow_utils.js`)
  if (!e.record.getString("code")) {
    e.record.set("code", utils.nextTaskCode(e.app))
  }
  utils.syncCompletion(e.record, "completedAt", "done", "")
  e.next()
}, "tasks")

onRecordUpdate((e) => {
  const utils = require(`${__hooks}/taskflow_utils.js`)
  const previous = e.record.original().getString("status")
  utils.syncCompletion(e.record, "completedAt", "done", previous)
  e.next()
}, "tasks")

// ---------------------------------------------------------------------------
// Projetos
// ---------------------------------------------------------------------------

onRecordCreate((e) => {
  const utils = require(`${__hooks}/taskflow_utils.js`)
  utils.syncCompletion(e.record, "finishedAt", "done", "")
  e.next()
}, "projects")

onRecordUpdate((e) => {
  const utils = require(`${__hooks}/taskflow_utils.js`)
  const previous = e.record.original().getString("status")
  utils.syncCompletion(e.record, "finishedAt", "done", previous)
  e.next()
}, "projects")

// ---------------------------------------------------------------------------
// Comentários: mantém o contador exibido nos cards do quadro
// ---------------------------------------------------------------------------

onRecordAfterCreateSuccess((e) => {
  const utils = require(`${__hooks}/taskflow_utils.js`)
  utils.adjustCommentCount(e.app, e.record.getString("task"), 1)
  e.next()
}, "comments")

onRecordAfterDeleteSuccess((e) => {
  const utils = require(`${__hooks}/taskflow_utils.js`)
  utils.adjustCommentCount(e.app, e.record.getString("task"), -1)
  e.next()
}, "comments")

// ---------------------------------------------------------------------------
// Equipe
// ---------------------------------------------------------------------------

onRecordCreate((e) => {
  if (e.record.getFloat("weeklyCapacity") === 0) {
    e.record.set("weeklyCapacity", 40)
  }
  e.next()
}, "users")

onRecordUpdate((e) => {
  const utils = require(`${__hooks}/taskflow_utils.js`)
  utils.ensureActiveAdmin(e.app, e.record, false)
  e.next()
}, "users")

onRecordDelete((e) => {
  const utils = require(`${__hooks}/taskflow_utils.js`)
  utils.ensureActiveAdmin(e.app, e.record, true)
  e.next()
}, "users")
