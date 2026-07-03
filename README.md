# RH App — Gestão de Pessoas

Aplicativo de gestão de pessoas inspirado no **Feedz**, desenvolvido para a disciplina de
Desenvolvimento para Dispositivos Móveis.

## Integrantes

- Carlos
- Aline
- Thaiane

## Funcionalidades

- **Login** — gestor RH (admin) e funcionários (e-mail e senha cadastrados)
- **Dashboard** — estatísticas da equipe e feed público de reconhecimentos
- **Funcionários** — cadastro, listagem com busca, perfil, edição e exclusão (restritos ao RH)
- **Departamentos** — agrupamento de funcionários por departamento
- **Feedbacks privados e 100% anônimos** — qualquer funcionário pode enviar; o autor
  nunca é gravado nem exibido; somente o dono do perfil e o RH veem o conteúdo e a
  contagem (os demais apenas enviam, sem visualizar nada)
- **Reconhecimentos públicos** — enviados entre colegas, exibidos no feed do Dashboard
  e na lista de reconhecimentos do perfil de cada funcionário

## Arquitetura — MVVM

```
lib/
├── models/          # Estruturas de dados (Employee, FeedbackModel anônimo, Recognition, LoggedUser)
├── repositories/    # Persistência com SharedPreferences (JSON)
├── viewmodels/      # Lógica de negócio + estado (ChangeNotifier / Provider)
└── views/           # Telas (apenas UI, observam os ViewModels)
```

- A **View** nunca acessa a persistência diretamente.
- O **ViewModel** expõe o estado e chama `notifyListeners()` para atualizar a UI.
- O **Repository** isola o SharedPreferences do resto do app.

## Como executar

```bash
flutter pub get
flutter run -d chrome
```

## Credenciais

| Perfil | Login | Senha |
|--------|-------|-------|
| Gestor RH | `admin` | `admin123` |
| Funcionário | e-mail cadastrado | senha definida no cadastro |

> O gestor RH cadastra os funcionários (com e-mail e senha). Depois, cada funcionário
> entra com as próprias credenciais para enviar feedbacks e reconhecimentos.

## Tecnologias

- Flutter + Material 3
- Provider (MVVM / ChangeNotifier)
- SharedPreferences (persistência local)
- uuid (geração de IDs)
