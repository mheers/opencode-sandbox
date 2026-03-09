# Session Context

## User Prompts

### Prompt 1

we already have some skill installed (look at the skills folder and how the Dockerfile adds them). I need to add 'npx skills add pbakaus/impeccable'

### Prompt 2

locally in my ~/.config/opencode/opencode.json (mounted into docker) I've added '"plugin": ["@mohak34/opencode-notifier@latest"]' that uses libnotify (installed on my linux host). when I run opencode with this notification tool inside a container (using './os -t') the notifications do not work

