/// <reference path="../pb_data/types.d.ts" />

// Funções compartilhadas pelos hooks do TaskFlow.
//
// Os handlers do PocketBase rodam em contextos isolados, por isso este
// módulo é carregado com require() dentro de cada handler.

const MIN_PASSWORD_LENGTH = 8

/** Próximo código sequencial de tarefa (TK-1001, TK-1002, ...). */
function nextTaskCode(app) {
  const result = new DynamicModel({ last: 0 })
  app
    .db()
    .newQuery(
      "SELECT COALESCE(MAX(CAST(SUBSTR(code, 4) AS INTEGER)), 1000) AS last " +
        "FROM tasks WHERE code LIKE 'TK-%'",
    )
    .one(result)
  return "TK-" + (result.last + 1)
}

/**
 * Mantém a data de conclusão coerente com o status: preenchida quando o
 * registro passa para [doneStatus] e vazia nos demais status.
 */
function syncCompletion(record, field, doneStatus, previousStatus) {
  const status = record.getString("status")
  if (status !== doneStatus) {
    record.set(field, "")
    return
  }
  if (previousStatus !== doneStatus && !record.getString(field)) {
    record.set(field, new DateTime())
  }
}

/** Soma [delta] ao contador de comentários da tarefa, se ela ainda existir. */
function adjustCommentCount(app, taskId, delta) {
  let task
  try {
    task = app.findRecordById("tasks", taskId)
  } catch (_) {
    return // a tarefa foi excluída (exclusão em cascata dos comentários)
  }
  task.set("commentCount", Math.max(0, task.getInt("commentCount") + delta))
  app.saveNoValidate(task)
}

/**
 * Impede que a equipe fique sem nenhum administrador ativo, seja ao
 * rebaixar/desativar a conta ([removing] = false) ou ao excluí-la.
 */
function ensureActiveAdmin(app, record, removing) {
  const before = record.original()
  const wasActiveAdmin = before.getBool("isAdmin") && before.getBool("active")
  const staysActiveAdmin =
    !removing && record.getBool("isAdmin") && record.getBool("active")
  if (!wasActiveAdmin || staysActiveAdmin) return

  const others = app.countRecords(
    "users",
    $dbx.hashExp({ isAdmin: true, active: true }),
    $dbx.not($dbx.hashExp({ id: record.id })),
  )
  if (others === 0) {
    throw new BadRequestError(
      "É preciso manter pelo menos um administrador ativo na equipe.",
    )
  }
}

/**
 * Indica se o endereço IPv6 é o loopback (::1), aceitando também a forma
 * expandida (0000:...:0001) que o servidor recebe no Windows.
 */
function isLoopbackIPv6(ip) {
  const parts = ip.split("::")
  const head = parts[0] ? parts[0].split(":") : []
  const tail = parts.length > 1 && parts[1] ? parts[1].split(":") : []
  const missing = 8 - head.length - tail.length
  if (missing < 0 || (parts.length === 1 && missing !== 0)) return false
  const groups = head.concat(Array(missing).fill("0"), tail)
  const last = parseInt(groups[7], 16)
  return last === 1 && groups.slice(0, 7).every((g) => parseInt(g, 16) === 0)
}

function isLoopback(ip) {
  if (ip.startsWith("127.")) return true
  if (!ip.includes(":")) return false
  // IPv4 mapeado em IPv6, como ::ffff:127.0.0.1.
  const lastPart = ip.substring(ip.lastIndexOf(":") + 1)
  if (lastPart.includes(".")) return lastPart.startsWith("127.")
  return isLoopbackIPv6(ip)
}

/**
 * A configuração inicial só é aceita a partir do próprio servidor. Usa o
 * IP da conexão (e não cabeçalhos de proxy, que podem ser forjados).
 */
function isLocalRequest(e) {
  return isLoopback(e.remoteIP())
}

function readSetupBody(e) {
  const body = e.requestInfo().body
  const data = {
    name: String(body.name || "").trim(),
    email: String(body.email || "").trim().toLowerCase(),
    password: String(body.password || ""),
  }
  if (!data.name || !data.email || data.password.length < MIN_PASSWORD_LENGTH) {
    throw new BadRequestError(
      "Informe nome, e-mail e uma senha com pelo menos " +
        MIN_PASSWORD_LENGTH + " caracteres.",
    )
  }
  return data
}

function createAdminUser(app, data) {
  const user = new Record(app.findCollectionByNameOrId("users"))
  user.set("name", data.name)
  user.set("email", data.email)
  user.setPassword(data.password)
  user.set("role", "Administrador")
  user.set("isAdmin", true)
  user.set("active", true)
  user.set("verified", true)
  user.set("weeklyCapacity", 40)
  app.save(user)
}

/** Conta de superusuário do painel /_/ (backups, logs, banco de dados). */
function upsertSuperuser(app, data) {
  const collection = app.findCollectionByNameOrId("_superusers")
  let superuser
  try {
    superuser = app.findAuthRecordByEmail(collection, data.email)
  } catch (_) {
    superuser = new Record(collection)
    superuser.set("email", data.email)
  }
  superuser.setPassword(data.password)
  app.save(superuser)
}

/** Cria o primeiro administrador do app e do painel do servidor. */
function handleSetup(e) {
  if (!isLocalRequest(e)) {
    throw new ForbiddenError(
      "A configuração inicial só pode ser feita no próprio servidor, " +
        "acessando http://localhost.",
    )
  }
  if (e.app.countRecords("users") > 0) {
    throw new BadRequestError("A configuração inicial já foi concluída.")
  }
  const data = readSetupBody(e)
  e.app.runInTransaction((txApp) => {
    createAdminUser(txApp, data)
    upsertSuperuser(txApp, data)
  })
  return e.json(201, { ok: true })
}

module.exports = {
  ensureActiveAdmin,
  nextTaskCode,
  syncCompletion,
  adjustCommentCount,
  handleSetup,
}
