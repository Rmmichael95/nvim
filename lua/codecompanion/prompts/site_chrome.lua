-- Header/Footer Create, Refine, Validate prompts for CodeCompanion + Claude Code.
-- Technical and design rules belong to the skills, not this launcher.
-- Backward compatible: open_header_prompt() and open_footer_prompt() are Create.

local M = {}
local image_dir = vim.fn.expand('~/pictures/blocks')

local function is_image(path)
  local extension = (path:match('%.([^%.]+)$') or ''):lower()
  return extension == 'png' or extension == 'jpg' or extension == 'jpeg'
    or extension == 'webp' or extension == 'gif'
end

local function valid_image(value)
  local path = vim.trim(value or '')
  if path:match('^".*"$') or path:match("^'.*'$") then path = path:sub(2, -2) end
  if path == '' then return nil end
  path = vim.fn.fnamemodify(vim.fn.expand(path), ':p')
  if vim.fn.filereadable(path) ~= 1 or not is_image(path) then
    vim.notify('Screenshot not readable: ' .. path, vim.log.levels.ERROR)
    return nil
  end
  return path
end

local function cli(text)
  require('codecompanion').cli(text, { agent = 'claude_code', submit = false, focus = true })
end

local function skill_name(kind)
  return kind == 'header' and 'dhali-header' or 'dhali-footer'
end

local function send_create(kind, path)
  cli(table.concat({
    'Use the ' .. skill_name(kind) .. ' skill. Mode: Create.',
    'Reference screenshot: @' .. path,
    'Inspect it now. Propose a new editable ' .. kind .. ' template part for this local Ollie site.',
    'Follow the skill approval workflow; do not write before approval.',
  }, '\n'))
end

local function recent_images()
  local images = {}
  for _, path in ipairs(vim.fn.globpath(image_dir, '*', false, true)) do
    if vim.fn.filereadable(path) == 1 and is_image(path) then
      images[#images + 1] = path
    end
  end
  table.sort(images, function(a, b)
    local at, bt = vim.fn.getftime(a), vim.fn.getftime(b)
    return at == bt and a > b or at > bt
  end)
  local recent = {}
  for i = 1, math.min(#images, 15) do recent[i] = images[i] end
  return recent
end

local function custom_path(kind)
  vim.ui.input({ prompt = 'Screenshot path: ' }, function(value)
    if not value or vim.trim(value) == '' then return end
    local path = valid_image(value)
    if path then send_create(kind, path) end
  end)
end

local function create(kind)
  local other = 'Enter a different image path...'
  local choices = { other }
  for _, path in ipairs(recent_images()) do choices[#choices + 1] = path end
  vim.ui.select(choices, {
    prompt = 'Choose ' .. kind .. ' screenshot:',
    format_item = function(item)
      if item == other then return item end
      return vim.fn.fnamemodify(item, ':t')
    end,
  }, function(choice)
    if not choice then return end
    if choice == other then return custom_path(kind) end
    local path = valid_image(choice)
    if path then send_create(kind, path) end
  end)
end

local function ask_target(kind, callback)
  vim.ui.input({ prompt = 'Existing ' .. kind .. ' template-part ID or slug: ' }, function(value)
    if not value then return end
    local target = vim.trim(value)
    if target == '' then return end
    callback(target)
  end)
end

local function refine(kind)
  ask_target(kind, function(target)
    vim.ui.input({ prompt = 'Requested change: ' }, function(value)
      if not value or vim.trim(value) == '' then return end
      cli(table.concat({
        'Use the ' .. skill_name(kind) .. ' skill. Mode: Refine.',
        'Target existing template part: ' .. target,
        'Change: ' .. vim.trim(value),
        'Read only this part and relevant references. Propose the smallest edit; await approval.',
      }, '\n'))
    end)
  end)
end

local function validate(kind)
  ask_target(kind, function(target)
    cli(table.concat({
      'Use the ' .. skill_name(kind) .. ' skill. Mode: Validate.',
      'Target existing template part: ' .. target,
      'Run read-only targeted checks. Report passed, failed, and not-tested items. No writes.',
    }, '\n'))
  end)
end

function M.open_header_prompt() create('header') end
function M.open_footer_prompt() create('footer') end
function M.open_header_refine_prompt() refine('header') end
function M.open_footer_refine_prompt() refine('footer') end
function M.open_header_validate_prompt() validate('header') end
function M.open_footer_validate_prompt() validate('footer') end

return M
