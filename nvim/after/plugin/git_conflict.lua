require('git-conflict').setup({
  list_opener = 'copen',
  highlights = {
    incoming = 'DiffAdd',
    current = 'DiffText',
  },
})
