# Pendências — modo produção (servidor Windows)

Branch: `feature/servidor-windows`. O que já está pronto e o que falta.

## Pronto

- Servidor PocketBase com SQLite embutido (`server/`): coleções, regras de
  acesso, configuração inicial do administrador (só via localhost), código
  automático de tarefas, anexos protegidos, backup diário.
- App conectado ao servidor (`lib/main.dart`) e modo de demonstração com dados
  de exemplo (`lib/main_development.dart`).
- Login e configuração inicial, quadro, tarefas (com anexos, horas,
  participantes), projetos e clientes (cadastro completo), relatórios
  calculados das tarefas com exportação CSV e PDF.

## A fazer

1. **Tela de Configurações**: perfil (nome, cargo), troca de senha e, para
   administradores, organização e sprint ativa. O repositório já tem os
   métodos (`UserRepository.updateProfile/changePassword`,
   `SettingsRepository.saveSettings`). Depois, recolocar o link no menu
   lateral e no menu do usuário (`Routes.settings`).
2. **Tela de Equipe** (administradores): listar, cadastrar, editar,
   redefinir senha e ativar/desativar pessoas (`UserRepository.createMember/
   updateMember/resetPassword`). Recolocar o item "Equipe" no menu
   (`Routes.team`). Até lá, a equipe é cadastrada no painel `/_/`.
3. **Testes de integração** dos repositórios remotos contra um PocketBase real.
4. **Instalador Windows** (Inno Setup): pocketbase.exe + app web em
   `pb_public` + migrations/hooks, serviço do Windows (WinSW), regra de
   firewall, escolha da porta, dados em `C:\ProgramData\TaskFlow`, abrir
   `http://localhost:PORTA` ao final para a configuração inicial.
5. **Pipeline**: gerar o instalador no GitHub Actions e testar a instalação
   silenciosa (runner Windows).
6. **Documentação** de instalação, acesso pelo IP, backup e atualização.
7. Juntar a branch na `main` quando tudo estiver validado.
