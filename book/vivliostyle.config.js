module.exports = {
  title: 'サンプル本',
  author: '著者名',
  theme: '@vivliostyle/theme-techbook',
  entryContext: './manuscripts',
  entry: [
    'index.md',
    'sample.md',
    'colophon.md'
  ],
  output: [
    'output/ebook.pdf',
  ],
  workspaceDir: '.vivliostyle', // 中間ファイルの保存場所
}
