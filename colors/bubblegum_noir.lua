vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end
vim.g.colors_name = "bubblegum_noir"
vim.o.background = "dark"

-- Gradient arc: hot-pink → violet → purple → sienna(types)
-- Everything else: plain black on a soft pink-white canvas
local c = {
  bg          = "#FFF0F5",
  bg_soft     = "#FFE4EE",
  bg_sel      = "#FADADD",
  bg_line     = "#FFD6E4",
  border      = "#F4A7C0",

  fg          = "#000000",   -- plain black for identifiers/variables/operators
  fg_comment  = "#C49AB0",   -- dusty rose — comments stay whispered
  fg_muted    = "#C49AB0",

  -- Gradient: pink → magenta → violet → purple
  g1          = "#E0177A",   -- hot pink     (keywords)
  g2          = "#B4009E",   -- magenta      (keyword2 / control)
  g3          = "#7B2FBE",   -- violet       (functions)
  g4          = "#5B3FA0",   -- deep purple  (methods)
  g5          = "#A0522D",   -- sienna       (types — warm anchor at the end)

  string_     = "#2E8B57",   -- sea green
  macro       = "#E67E22",   -- amber (preprocessor — stands alone)

  error       = "#CC0033",
  warn        = "#B8860B",
  info        = "#3A86FF",
  hint        = "#C49AB0",

  diff_add    = "#D4EDDA",
  diff_del    = "#F8D7DA",
  diff_change = "#FFF3CD",

  statusline  = "#F9C6D8",
  tabline     = "#FFD6E4",
  winbar      = "#FFF0F5",
  search      = "#FFD700",
  incselect   = "#FF85A1",
  visual      = "#FADADD",
}

local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- ── Editor UI ──────────────────────────────────────────────────────────────
hi("Normal",          { fg = c.fg,       bg = c.bg })
hi("NormalFloat",     { fg = c.fg,       bg = c.bg_soft })
hi("NormalNC",        { fg = c.fg_muted, bg = c.bg })
hi("FloatBorder",     { fg = c.border,   bg = c.bg_soft })

hi("Cursor",          { fg = c.bg,       bg = c.g1 })
hi("CursorLine",      { bg = c.bg_line })
hi("CursorLineNr",    { fg = c.g1,       bold = true })
hi("LineNr",          { fg = c.fg_muted })
hi("ColorColumn",     { bg = c.bg_soft })
hi("SignColumn",      { fg = c.fg_muted, bg = c.bg })
hi("FoldColumn",      { fg = c.fg_muted, bg = c.bg })
hi("Folded",          { fg = c.fg_comment, bg = c.bg_soft, italic = true })

hi("Visual",          { bg = c.visual })
hi("VisualNOS",       { bg = c.bg_sel })
hi("Search",          { fg = c.fg,       bg = c.search })
hi("CurSearch",       { fg = c.bg,       bg = c.g1, bold = true })
hi("IncSearch",       { fg = c.bg,       bg = c.incselect })

hi("StatusLine",      { fg = c.fg,       bg = c.statusline })
hi("StatusLineNC",    { fg = c.fg_muted, bg = c.tabline })
hi("TabLine",         { fg = c.fg_muted, bg = c.tabline })
hi("TabLineSel",      { fg = c.g1,       bg = c.bg, bold = true })
hi("TabLineFill",     { bg = c.tabline })
hi("WinBar",          { fg = c.fg,       bg = c.winbar })
hi("WinBarNC",        { fg = c.fg_muted, bg = c.winbar })
hi("WinSeparator",    { fg = c.border })

hi("Pmenu",           { fg = c.fg,       bg = c.bg_soft })
hi("PmenuSel",        { fg = c.bg,       bg = c.g1 })
hi("PmenuSbar",       { bg = c.bg_sel })
hi("PmenuThumb",      { bg = c.border })

hi("MatchParen",      { fg = c.g1,       underline = true, bold = true })
hi("NonText",         { fg = c.fg_muted })
hi("SpecialKey",      { fg = c.fg_muted })
hi("Whitespace",      { fg = c.bg_sel })
hi("EndOfBuffer",     { fg = c.bg_sel })

hi("Title",           { fg = c.g1,       bold = true })
hi("Bold",            { bold = true })
hi("Italic",          { italic = true })

-- ── Syntax — classic groups ────────────────────────────────────────────────
hi("Comment",         { fg = c.fg_comment, italic = true })

hi("Constant",        { fg = c.fg })        -- black
hi("String",          { fg = c.string_ })
hi("Character",       { fg = c.string_ })
hi("Number",          { fg = c.fg })        -- black
hi("Boolean",         { fg = c.fg })        -- black
hi("Float",           { fg = c.fg })        -- black

hi("Identifier",      { fg = c.fg })        -- black
hi("Function",        { fg = c.g3,         bold = true })

hi("Statement",       { fg = c.g1,         bold = true })
hi("Conditional",     { fg = c.g2,         bold = true })
hi("Repeat",          { fg = c.g2,         bold = true })
hi("Label",           { fg = c.g1 })
hi("Operator",        { fg = c.fg })        -- black
hi("Keyword",         { fg = c.g1,         bold = true })
hi("Exception",       { fg = c.g2,         bold = true })

hi("PreProc",         { fg = c.macro })
hi("Include",         { fg = c.macro })
hi("Define",          { fg = c.macro })
hi("Macro",           { fg = c.macro })
hi("PreCondit",       { fg = c.macro })

hi("Type",            { fg = c.g5,         bold = true })
hi("StorageClass",    { fg = c.g1 })
hi("Structure",       { fg = c.g5,         bold = true })
hi("Typedef",         { fg = c.g5,         bold = true, italic = true })

hi("Special",         { fg = c.fg })        -- black
hi("SpecialChar",     { fg = c.string_ })
hi("Tag",             { fg = c.g1 })
hi("Delimiter",       { fg = c.fg })        -- black
hi("SpecialComment",  { fg = c.g2,         italic = true })
hi("Debug",           { fg = c.error })

hi("Underlined",      { underline = true })
hi("Ignore",          { fg = c.fg_muted })
hi("Error",           { fg = c.error,      bold = true })
hi("Todo",            { fg = c.bg,         bg = c.g1, bold = true })

-- ── Treesitter ─────────────────────────────────────────────────────────────
hi("@comment",               { fg = c.fg_comment, italic = true })
hi("@comment.documentation", { fg = c.fg_comment, italic = true })

hi("@keyword",               { fg = c.g1,  bold = true })
hi("@keyword.function",      { fg = c.g1,  bold = true })
hi("@keyword.operator",      { fg = c.fg })
hi("@keyword.return",        { fg = c.g2,  bold = true })
hi("@keyword.import",        { fg = c.macro })
hi("@keyword.coroutine",     { fg = c.g1 })
hi("@keyword.exception",     { fg = c.g2,  bold = true })

hi("@variable",              { fg = c.fg })
hi("@variable.builtin",      { fg = c.fg,  italic = true })
hi("@variable.member",       { fg = c.fg })
hi("@variable.parameter",    { fg = c.fg, italic = true })

hi("@function",              { fg = c.g3,  bold = true })
hi("@function.builtin",      { fg = c.g3 })
hi("@function.call",         { fg = c.g3 })
hi("@function.macro",        { fg = c.macro, bold = true })
hi("@function.method",       { fg = c.g4 })
hi("@function.method.call",  { fg = c.g4 })

hi("@type",                  { fg = c.g5,  bold = true })
hi("@type.builtin",          { fg = c.g5,  bold = true, italic = true })
hi("@type.definition",       { fg = c.g5,  bold = true })
hi("@type.qualifier",        { fg = c.g1 })

hi("@constructor",           { fg = c.g5,  bold = true })
hi("@property",              { fg = c.fg })
hi("@field",                 { fg = c.fg })
hi("@attribute",             { fg = c.macro })

hi("@string",                { fg = c.string_ })
hi("@string.escape",         { fg = c.fg })
hi("@string.special",        { fg = c.fg })
hi("@character",             { fg = c.string_ })
hi("@number",                { fg = c.fg })
hi("@boolean",               { fg = c.fg })
hi("@float",                 { fg = c.fg })

hi("@operator",              { fg = c.fg })
hi("@punctuation.bracket",   { fg = c.fg })
hi("@punctuation.delimiter", { fg = c.fg })
hi("@punctuation.special",   { fg = c.fg })

hi("@constant",              { fg = c.fg })
hi("@constant.builtin",      { fg = c.fg })
hi("@constant.macro",        { fg = c.macro })

hi("@namespace",             { fg = c.g5,  italic = true })
hi("@module",                { fg = c.g5 })
hi("@label",                 { fg = c.g1 })
hi("@tag",                   { fg = c.g1 })
hi("@tag.attribute",         { fg = c.fg })
hi("@tag.delimiter",         { fg = c.fg })

-- Rust specifics
hi("@lsp.type.namespace.rust",          { fg = c.g5,  italic = true })
hi("@lsp.type.macro.rust",              { fg = c.macro, bold = true })
hi("@lsp.type.selfKeyword.rust",        { fg = c.g1,  italic = true })
hi("@lsp.type.lifetime",                { fg = c.g2,  italic = true })
hi("@lsp.typemod.variable.mutable.rust",{ underline = true })

-- ── LSP semantic tokens ────────────────────────────────────────────────────
hi("@lsp.type.class",         { link = "@type" })
hi("@lsp.type.decorator",     { link = "@attribute" })
hi("@lsp.type.enum",          { link = "@type" })
hi("@lsp.type.enumMember",    { fg = c.fg })
hi("@lsp.type.function",      { link = "@function" })
hi("@lsp.type.interface",     { link = "@type" })
hi("@lsp.type.keyword",       { link = "@keyword" })
hi("@lsp.type.macro",         { link = "@function.macro" })
hi("@lsp.type.method",        { link = "@function.method" })
hi("@lsp.type.namespace",     { link = "@namespace" })
hi("@lsp.type.number",        { fg = c.fg })
hi("@lsp.type.operator",      { fg = c.fg })
hi("@lsp.type.parameter",     { fg = c.fg, italic = true })
hi("@lsp.type.property",      { fg = c.fg })
hi("@lsp.type.string",        { link = "@string" })
hi("@lsp.type.struct",        { link = "@type" })
hi("@lsp.type.type",          { link = "@type" })
hi("@lsp.type.typeParameter", { link = "@type.definition" })
hi("@lsp.type.variable",      { fg = c.fg })
hi("@lsp.type.comment",       { link = "@comment" })
hi("@lsp.type.generic",       { link = "@type" })

-- ── Diagnostics ────────────────────────────────────────────────────────────
hi("DiagnosticError",            { fg = c.error })
hi("DiagnosticWarn",             { fg = c.warn })
hi("DiagnosticInfo",             { fg = c.info })
hi("DiagnosticHint",             { fg = c.hint })
hi("DiagnosticOk",               { fg = c.string_ })

hi("DiagnosticUnderlineError",   { sp = c.error, underline = true })
hi("DiagnosticUnderlineWarn",    { sp = c.warn,  underline = true })
hi("DiagnosticUnderlineInfo",    { sp = c.info,  underline = true })
hi("DiagnosticUnderlineHint",    { sp = c.hint,  underline = true })

hi("DiagnosticSignError",        { fg = c.error, bold = true })
hi("DiagnosticSignWarn",         { fg = c.warn,  bold = true })
hi("DiagnosticSignInfo",         { fg = c.info })
hi("DiagnosticSignHint",         { fg = c.hint })

hi("DiagnosticVirtualTextError", { fg = c.error, italic = true })
hi("DiagnosticVirtualTextWarn",  { fg = c.warn,  italic = true })
hi("DiagnosticVirtualTextInfo",  { fg = c.info,  italic = true })
hi("DiagnosticVirtualTextHint",  { fg = c.hint,  italic = true })

-- ── Git / Diff ─────────────────────────────────────────────────────────────
hi("DiffAdd",        { bg = c.diff_add })
hi("DiffDelete",     { bg = c.diff_del })
hi("DiffChange",     { bg = c.diff_change })
hi("DiffText",       { bg = c.diff_change, bold = true })

hi("GitSignsAdd",    { fg = c.string_ })
hi("GitSignsChange", { fg = c.warn })
hi("GitSignsDelete", { fg = c.error })

-- ── Telescope ──────────────────────────────────────────────────────────────
hi("TelescopeNormal",       { fg = c.fg,    bg = c.bg_soft })
hi("TelescopeBorder",       { fg = c.border,bg = c.bg_soft })
hi("TelescopePromptBorder", { fg = c.g1,    bg = c.bg_soft })
hi("TelescopeResultsTitle", { fg = c.g1,    bold = true })
hi("TelescopePreviewTitle", { fg = c.g3,    bold = true })
hi("TelescopeMatching",     { fg = c.g1,    bold = true })
hi("TelescopeSelection",    { bg = c.bg_line })

-- ── nvim-tree ──────────────────────────────────────────────────────────────
hi("NvimTreeNormal",           { fg = c.fg,    bg = c.bg_soft })
hi("NvimTreeRootFolder",       { fg = c.g1,    bold = true })
hi("NvimTreeFolderName",       { fg = c.g3 })
hi("NvimTreeOpenedFolderName", { fg = c.g1,    bold = true })
hi("NvimTreeFileName",         { fg = c.fg })
hi("NvimTreeGitDirty",         { fg = c.warn })
hi("NvimTreeGitNew",           { fg = c.string_ })
hi("NvimTreeGitDeleted",       { fg = c.error })

-- ── Indent guides ──────────────────────────────────────────────────────────
hi("IblIndent", { fg = c.bg_sel })
hi("IblScope",  { fg = c.border })

-- ── Which-key ──────────────────────────────────────────────────────────────
hi("WhichKey",          { fg = c.g1 })
hi("WhichKeyDesc",      { fg = c.fg })
hi("WhichKeyGroup",     { fg = c.g3,    bold = true })
hi("WhichKeySeparator", { fg = c.fg_muted })

-- ── Notify ─────────────────────────────────────────────────────────────────
hi("NotifyERRORTitle", { fg = c.error,  bold = true })
hi("NotifyWARNTitle",  { fg = c.warn,   bold = true })
hi("NotifyINFOTitle",  { fg = c.info,   bold = true })
hi("NotifyDEBUGTitle", { fg = c.fg_muted })

-- ── Mini.nvim statusline ───────────────────────────────────────────────────
hi("MiniStatuslineFilename",   { fg = c.fg,      bg = c.statusline })
hi("MiniStatuslineModeNormal", { fg = c.bg,      bg = c.g1,  bold = true })
hi("MiniStatuslineModeInsert", { fg = c.bg,      bg = c.g3,  bold = true })
hi("MiniStatuslineModeVisual", { fg = c.bg,      bg = c.g4,  bold = true })
hi("MiniStatuslineDevinfo",    { fg = c.fg_muted,bg = c.statusline })
