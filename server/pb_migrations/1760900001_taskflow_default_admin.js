/// <reference path="../pb_data/types.d.ts" />

// Acesso padrão do TaskFlow: o banco já nasce com um administrador, sem
// nenhuma configuração manual.
//
// - App TaskFlow: usuário "sa" (ou e-mail sa@taskflow.local), senha 256318
// - Painel do banco (/_/): e-mail sa@taskflow.local, senha 256318
//
// Troque a senha depois da instalação (Configurações > Alterar senha no app
// e, no painel, em Superusers).

const DEFAULT_USERNAME = "sa"
const DEFAULT_EMAIL = "sa@taskflow.local"
const DEFAULT_PASSWORD = "256318"
const MIN_PASSWORD = 6

function allowUsernameLogin(app) {
  const users = app.findCollectionByNameOrId("users")
  users.fields.add(
    new TextField({ name: "username", max: 60, pattern: "^[a-zA-Z0-9._-]*$" }),
  )
  users.fields.getByName("password").min = MIN_PASSWORD
  users.addIndex("idx_users_username", true, "username", "username != ''")
  // Login pelo e-mail ou pelo nome de usuário.
  users.passwordAuth.identityFields = ["email", "username"]
  app.save(users)
}

function relaxSuperuserPassword(app) {
  const superusers = app.findCollectionByNameOrId("_superusers")
  superusers.fields.getByName("password").min = MIN_PASSWORD
  app.save(superusers)
}

function seedSuperuser(app) {
  if (app.countRecords("_superusers") > 0) return
  const superuser = new Record(app.findCollectionByNameOrId("_superusers"))
  superuser.set("email", DEFAULT_EMAIL)
  superuser.setPassword(DEFAULT_PASSWORD)
  app.save(superuser)
}

function seedAppAdmin(app) {
  if (app.countRecords("users") > 0) return
  const admin = new Record(app.findCollectionByNameOrId("users"))
  admin.set("name", "Administrador")
  admin.set("username", DEFAULT_USERNAME)
  admin.set("email", DEFAULT_EMAIL)
  admin.setPassword(DEFAULT_PASSWORD)
  admin.set("role", "Administrador")
  admin.set("isAdmin", true)
  admin.set("active", true)
  admin.set("verified", true)
  admin.set("emailVisibility", true)
  admin.set("weeklyCapacity", 40)
  app.save(admin)
}

migrate((app) => {
  allowUsernameLogin(app)
  relaxSuperuserPassword(app)
  seedSuperuser(app)
  seedAppAdmin(app)
}, (app) => {
  const users = app.findCollectionByNameOrId("users")
  users.passwordAuth.identityFields = ["email"]
  users.removeIndex("idx_users_username")
  users.fields.removeByName("username")
  users.fields.getByName("password").min = 8
  app.save(users)
})
