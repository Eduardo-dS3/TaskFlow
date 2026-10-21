/// <reference path="../pb_data/types.d.ts" />

// Esquema inicial do TaskFlow.
//
// Regras de acesso:
// - Só usuários autenticados (e ativos) acessam os dados.
// - Administradores (users.isAdmin) gerenciam a equipe e podem excluir
//   clientes e projetos.
// - Cada pessoa só altera o próprio perfil, sem poder se promover a admin.

const AUTH = '@request.auth.id != ""'
const ADMIN = "@request.auth.isAdmin = true"

const ATTACHMENT_MIME_TYPES = [
  "image/png",
  "image/jpeg",
  "image/gif",
  "image/webp",
  "application/pdf",
  "application/json",
  "text/plain",
  "text/csv",
  "application/zip",
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  "application/vnd.openxmlformats-officedocument.presentationml.presentation",
]

function timestamps() {
  return [
    { type: "autodate", name: "created", onCreate: true, onUpdate: false },
    { type: "autodate", name: "updated", onCreate: true, onUpdate: true },
  ]
}

function setupUsers(app) {
  const users = app.findCollectionByNameOrId("users")

  users.fields.add(new TextField({ name: "role", max: 100 }))
  users.fields.add(new BoolField({ name: "isAdmin" }))
  users.fields.add(new BoolField({ name: "active" }))
  users.fields.add(new NumberField({ name: "weeklyCapacity", min: 0, max: 168 }))
  users.fields.add(new DateField({ name: "lastSeen" }))

  users.listRule = AUTH
  users.viewRule = AUTH
  users.createRule = ADMIN
  users.updateRule =
    "(id = @request.auth.id" +
    " && @request.body.isAdmin:isset = false" +
    " && @request.body.active:isset = false" +
    " && @request.body.weeklyCapacity:isset = false)" +
    " || " + ADMIN
  users.deleteRule = ADMIN + " && id != @request.auth.id"
  users.manageRule = ADMIN
  // Contas desativadas não conseguem entrar.
  users.authRule = "active = true"
  // Sem servidor de e-mail configurado, o alerta de novo login só gera erro.
  users.authAlert.enabled = false

  app.save(users)
}

function createClients(app) {
  const clients = new Collection({
    type: "base",
    name: "clients",
    listRule: AUTH,
    viewRule: AUTH,
    createRule: AUTH,
    updateRule: AUTH,
    deleteRule: ADMIN,
    fields: [
      { type: "text", name: "name", required: true, max: 120, presentable: true },
      {
        type: "select",
        name: "tier",
        required: true,
        maxSelect: 1,
        values: ["enterprise", "pro", "custom", "maintenance"],
      },
      { type: "text", name: "sla", max: 60 },
      { type: "text", name: "contract", max: 120 },
      ...timestamps(),
    ],
  })
  app.save(clients)
  return clients
}

function createProjects(app, clients, users) {
  const projects = new Collection({
    type: "base",
    name: "projects",
    listRule: AUTH,
    viewRule: AUTH,
    createRule: AUTH,
    updateRule: AUTH,
    deleteRule: ADMIN,
    fields: [
      { type: "text", name: "name", required: true, max: 150, presentable: true },
      { type: "relation", name: "client", collectionId: clients.id, maxSelect: 1 },
      { type: "text", name: "description", max: 2000 },
      {
        type: "select",
        name: "status",
        required: true,
        maxSelect: 1,
        values: ["inProgress", "done", "paused"],
      },
      {
        type: "select",
        name: "priority",
        maxSelect: 1,
        values: ["urgent", "high", "medium", "low"],
      },
      {
        type: "select",
        name: "kind",
        maxSelect: 1,
        values: ["mobile", "web", "fiscal", "landing", "api", "report", "other"],
      },
      { type: "text", name: "badge", max: 60 },
      { type: "text", name: "note", max: 120 },
      { type: "date", name: "dueDate" },
      { type: "date", name: "finishedAt" },
      { type: "relation", name: "team", collectionId: users.id, maxSelect: 50 },
      ...timestamps(),
    ],
    indexes: ["CREATE INDEX idx_projects_status ON projects (status)"],
  })
  app.save(projects)
  return projects
}

function createTasks(app, projects, users) {
  const tasks = new Collection({
    type: "base",
    name: "tasks",
    listRule: AUTH,
    viewRule: AUTH,
    createRule: AUTH,
    updateRule: AUTH,
    deleteRule: ADMIN + " || owner = @request.auth.id",
    fields: [
      // Gerado pelo hook ao criar a tarefa (TK-1001, TK-1002, ...).
      { type: "text", name: "code", max: 20, presentable: true },
      { type: "text", name: "title", required: true, max: 200 },
      { type: "text", name: "description", max: 50000 },
      {
        type: "select",
        name: "status",
        required: true,
        maxSelect: 1,
        values: ["pending", "inProgress", "done"],
      },
      {
        type: "select",
        name: "priority",
        required: true,
        maxSelect: 1,
        values: ["urgent", "high", "medium", "low"],
      },
      { type: "text", name: "category", max: 60 },
      { type: "text", name: "sprint", max: 80 },
      { type: "relation", name: "project", collectionId: projects.id, maxSelect: 1 },
      { type: "relation", name: "owner", collectionId: users.id, maxSelect: 1 },
      { type: "relation", name: "assignees", collectionId: users.id, maxSelect: 20 },
      { type: "date", name: "startDate" },
      { type: "date", name: "dueDate" },
      { type: "date", name: "completedAt" },
      { type: "number", name: "estimatedHours", min: 0, max: 10000 },
      { type: "number", name: "loggedHours", min: 0, max: 100000 },
      { type: "json", name: "tags", maxSize: 20000 },
      { type: "json", name: "subtasks", maxSize: 200000 },
      { type: "number", name: "commentCount", min: 0, onlyInt: true },
      ...timestamps(),
    ],
    indexes: [
      "CREATE UNIQUE INDEX idx_tasks_code ON tasks (code) WHERE code != ''",
      "CREATE INDEX idx_tasks_status ON tasks (status)",
      "CREATE INDEX idx_tasks_project ON tasks (project)",
    ],
  })
  app.save(tasks)
  return tasks
}

function createComments(app, tasks, users) {
  const comments = new Collection({
    type: "base",
    name: "comments",
    listRule: AUTH,
    viewRule: AUTH,
    createRule: AUTH + " && author = @request.auth.id",
    updateRule: "author = @request.auth.id",
    deleteRule: "author = @request.auth.id || " + ADMIN,
    fields: [
      {
        type: "relation",
        name: "task",
        required: true,
        collectionId: tasks.id,
        maxSelect: 1,
        cascadeDelete: true,
      },
      {
        type: "relation",
        name: "author",
        required: true,
        collectionId: users.id,
        maxSelect: 1,
      },
      { type: "text", name: "body", required: true, max: 5000 },
      ...timestamps(),
    ],
    indexes: ["CREATE INDEX idx_comments_task ON comments (task)"],
  })
  app.save(comments)
}

function createAttachments(app, tasks, users) {
  const attachments = new Collection({
    type: "base",
    name: "attachments",
    listRule: AUTH,
    viewRule: AUTH,
    createRule: AUTH + " && uploadedBy = @request.auth.id",
    updateRule: null,
    deleteRule: "uploadedBy = @request.auth.id || " + ADMIN,
    fields: [
      {
        type: "relation",
        name: "task",
        required: true,
        collectionId: tasks.id,
        maxSelect: 1,
        cascadeDelete: true,
      },
      {
        type: "file",
        name: "file",
        required: true,
        maxSelect: 1,
        maxSize: 25 * 1024 * 1024,
        mimeTypes: ATTACHMENT_MIME_TYPES,
        // Download só com token de arquivo do usuário autenticado.
        protected: true,
      },
      { type: "text", name: "name", required: true, max: 255 },
      { type: "number", name: "size", min: 0, onlyInt: true },
      { type: "relation", name: "uploadedBy", collectionId: users.id, maxSelect: 1 },
      ...timestamps(),
    ],
    indexes: ["CREATE INDEX idx_attachments_task ON attachments (task)"],
  })
  app.save(attachments)
}

function createAppSettings(app) {
  const appSettings = new Collection({
    type: "base",
    name: "app_settings",
    listRule: AUTH,
    viewRule: AUTH,
    createRule: null,
    updateRule: ADMIN,
    deleteRule: null,
    fields: [
      { type: "text", name: "organization", max: 120 },
      { type: "text", name: "activeSprint", max: 80 },
      ...timestamps(),
    ],
  })
  app.save(appSettings)

  // Registro único com as configurações gerais.
  const record = new Record(appSettings)
  record.set("organization", "")
  record.set("activeSprint", "Sprint 1")
  app.save(record)
}

function configureServer(app) {
  const settings = app.settings()
  settings.meta.appName = "TaskFlow"
  // Backup diário às 3h, mantendo os 14 mais recentes (pb_data/backups).
  settings.backups.cron = "0 3 * * *"
  settings.backups.cronMaxKeep = 14
  settings.logs.maxDays = 14
  settings.rateLimits.enabled = true
  app.save(settings)
}

migrate((app) => {
  setupUsers(app)
  const users = app.findCollectionByNameOrId("users")
  const clients = createClients(app)
  const projects = createProjects(app, clients, users)
  const tasks = createTasks(app, projects, users)
  createComments(app, tasks, users)
  createAttachments(app, tasks, users)
  createAppSettings(app)
  configureServer(app)
}, (app) => {
  for (const name of ["app_settings", "attachments", "comments", "tasks", "projects", "clients"]) {
    app.delete(app.findCollectionByNameOrId(name))
  }
  const users = app.findCollectionByNameOrId("users")
  for (const field of ["role", "isAdmin", "active", "weeklyCapacity", "lastSeen"]) {
    users.fields.removeByName(field)
  }
  app.save(users)
})
