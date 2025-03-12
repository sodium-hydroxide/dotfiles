local M = {}


function M.setup(opts)
  opts = opts or {}
  local extensions = opts.extensions or {"mcnp", "in"}

  -- Build file patterns from the given extensions (e.g. "*.mcnp")
  local patterns = {}
  for _, ext in ipairs(extensions) do
    table.insert(patterns, "*." .. ext)
  end

  vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = patterns,
    callback = function()
      vim.cmd([[
        " Vim syntax file
        " Language:	MCNP input file
        " Version:	1.02
        " Last Change:	2014 March 19
        " Maintainer:   Grant Goodyear <g2boojum@gmail.com>
        " Creator:	Giacomo L.A. Grasso
        "		Nuclear Reactor Core and Shielding Analysis and Design laboratory (PRONOC)
        "		Technical Unit for Reactor Safety and Fuel Cycle Methods (UTFISSM)
        "		Italian National Agency for New Technologies, Energy and Sustainable Economic Development (ENEA)
        " Contact:	<giacomo.grasso@enea.it>
        " Usage:	Do :help imcnp-syntax from Vim (FIXME: This doesn't actually work)
        " Credits:
        "  Version 0.1 was based on the MCNP5 input file scheme as reported in the
        "  Los Alamos User Manual. For instructions on use, do :help imcnp from vim
        "
        " This program is free software: you can redistribute it and/or modify
        " it under the terms of the GNU General Public License as published by
        " the Free Software Foundation, either version 3 of the License, or
        " (at your option) any later version.
        "
        " This program is distributed in the hope that it will be useful,
        " but WITHOUT ANY WARRANTY; without even the implied warranty of
        " MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        " GNU General Public License for more details.
        "
        " You should have received a copy of the GNU General Public License
        " along with this program.  If not, see <http://www.gnu.org/licenses/>.
        "

        " For version 5.x: Clear all syntax items
        " For version 6.x: Quit if a syntax file is already loaded
        if version < 600
          syntax clear
        elseif exists("b:current_syntax")
          finish
        endif

        syn case ignore

        " ------------- Generals -------------------------------------------------------
        " --- Unprocessed
        " Header
        syn match imcnpUnitHeader	display "\%1l.\+$"
        " Comments
        syn match imcnpComment		display "\%1cc$"
        syn match imcnpComment		display "\%1cc\s.*$"
        syn match imcnpComment		display "\$.*$"
        " --- Commons
        " Characterizig
        syn keyword imcnpKeyword	n
        " --- Numbers of various sorts
        " Integers
        syn match imcnpLabelNumber	display "[-+*#]\=\d\+r\="
        " floating points
        syn match imcnpFloat		display "[-+]\=\d\{2,}\.\d*"
        syn match imcnpFloat		display "[-+]\=\d\=\.\d*\(e[-+]\=\d\+\)\="

        " ------------- Cell cards -----------------------------------------------------
        " descriptives
        syn keyword imcnpKeyword	like but imp ext mat rho vol tmp area trcl u fill lat

        " ------------- Surface cards --------------------------------------------------
        " Surfaces
        syn keyword imcnpType		px py pz p cx cy cz so s sx sy sz kx ky kz sq gq tx ty tz x y z
        syn match imcnpType		"\<[ck]/[xyz]\>"
        " Macrobodies
        syn keyword imcnpType		box rpp sph rcc rhp hex rec trc ell wed arb nlib

        " ------------- Tally cards ----------------------------------------------------
        " --- Materials cards
        " mat number
        syn match imcnpTodo		"m[t]\=\d\+"
        " ENDF library
        syn match imcnpType		display "\<\d\{2,6}\.\d\d[cdytpuemg]\>"
        " --- Tallies cards
        " Tally
        syn match imcnpTodo		"f\(\(mesh\)\|[cqmsut]\)\=\d*"
        syn match imcnpTodo		"e[m]\=\d*"
        syn match imcnpTodo		"t[mf]\=\d\+"
        syn match imcnpTodo		"c[mf]\=\d\+"
        syn match imcnpTodo		"d[efd\(xt\)]\=\d\+"
        syn match imcnpTodo		"s[fd]\=\d\+"
        syn keyword imcnpKeyword	geom origin imesh iints jmesh jints kmesh kints emesh eints out factor
        " Comments
        syn region imcnpComment matchgroup=imcnpTodo start="[sf]c\d\+" end="$" contains=imcnpComment
        " syn match imcnpComment
        " --- Source cards
        " Generic
        syn keyword imcnpKeyword	ksrc sdef
        " Definition
        syn keyword imcnpKeyword	ssw ssr ipt icl jsu cel sur par tr pos rad axs dir vec nrm ccc ara eff erg tme wgt
        " Distribution
        "syn match imcnpTodo		"d\d\+"
        "syn match imcnpTodo		"s[ipbc]\d\+"
        "syn match imcnpTodo		"ds\d\+"
        "syn match imcnpTodo		"tr\d\+"
        " --- Mode cards
        " Simulation
        syn keyword imcnpKeyword	mode kcode
        " Output
        syn keyword imcnpKeyword	print
        syn keyword imcnpType		col cf ij ik jk

        " READ card
        syn keyword imcnpKeyword    read echo noecho
        syn region imcnpType    start=/file\s*=\s*/   end=/\s/ end=/$/
        syn region imcnpComment start=/encode\s*=\s*/ end=/\s/ end=/$/
        syn region imcnpComment start=/decode\s*=\s*/ end=/\s/ end=/$/

        "Catch errors caused by too many right parentheses
        syn region imcnpParen transparent start="(" end=")" contains=ALLBUT,imcnpParenError,@imcnpCommentGroup,cIncluded,@spell
        syn match  imcnpParenError   ")"
        syn region imcnpParen transparent start="\[" end="\]" contains=ALLBUT,imcnpParenError,@imcnpCommentGroup,cIncluded,@spell
        syn match  imcnpParenError   "\]"

        syn match imcnpOperator		"="
        syn match imcnpOperator		":"
        syn match imcnpOperator		"<"

        " Define the default highlighting.
        " For version 5.7 and earlier: only when not done already
        " For version 5.8 and later: only when an item doesn't have highlighting yet
        if version >= 508 || !exists("did_imcnp_syn_inits")
          if version < 508
            let did_imcnp_syn_inits = 1
            command -nargs=+ HiLink hi link <args>
          else
            command -nargs=+ HiLink hi def link <args>
          endif

          HiLink imcnpKeyword	 	Keyword
          HiLink imcnpConstructName	Identifier
          HiLink imcnpConditional	Conditional
          HiLink imcnpRepeat		Repeat
          HiLink imcnpTodo		Todo
          HiLink imcnpContinueMark	Todo
          HiLink imcnpString		String
          HiLink imcnpNumber		Number
          HiLink imcnpOperator		Operator
          HiLink imcnpBoolean		Boolean
          HiLink imcnpLabelError	Error
          HiLink imcnpObsolete		Todo
          HiLink imcnpType		Type
          HiLink imcnpStructure		Type
          HiLink imcnpStorageClass	StorageClass
          HiLink imcnpUnitHeader	Identifier
          HiLink imcnpReadWrite		Keyword
          HiLink imcnpIO		Keyword
          HiLink imcnp90Intrinsic	Function

          HiLink imcnpInclude		Include

          HiLink imcnpLabelNumber	Special
          HiLink imcnpTarget		Special
          HiLink imcnpFormatSpec	Identifier

          HiLink imcnpFloat		Float
          HiLink imcnpPreCondit		PreCondit
          HiLink imcnpInclude		Include
          HiLink cIncluded		imcnpString
          HiLink cInclude		Include
          HiLink cPreProc		PreProc
          HiLink cPreCondit		PreCondit
          HiLink imcnpParenError	Error
          HiLink imcnpComment		Comment
          HiLink imcnpSerialNumber	Todo
          HiLink imcnpTab		Error

          delcommand HiLink
        endif

        let b:current_syntax = "mcnp"
        set sw=6 ts=6
        set expandtab
        set smarttab
        set list "invisible characters cause trouble with mcnp
      ]])
    end
  })
end
return M

-- -- File: lua/path/to/file.lua
--
-- local M = {}
--
-- function M.setup(opts)
--   opts = opts or {}
--   local extensions = opts.extensions or {"mcnp", "in"}
--
--   -- Build file patterns from the given extensions (e.g. "*.mcnp")
--   local patterns = {}
--   for _, ext in ipairs(extensions) do
--     table.insert(patterns, "*." .. ext)
--   end
--
--   vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
--     pattern = patterns,
--     callback = function()
--       -- Clear any existing syntax rules for this buffer.
--       vim.cmd("syntax clear")
--
--       -- Define a custom syntax match for MCNP comments:
--       -- This pattern matches any line where a 'c' or 'C' appears within the first five characters.
--       --
--       -- Pattern breakdown:
--       --   ^              : beginning of the line
--       --   \(.\{0,4}\)   : matches 0 to 4 of any character (positions 1 to 4)
--       --   [cC]          : matches a lowercase or uppercase 'c' at position 1-5
--       --   .*            : matches the rest of the line
--       vim.cmd([[syntax match MCNPComment /^\(.\{0,4}\)[cC] .*/]])
--       vim.cmd([[syntax match MCNPInlineComment /\$.*$/]])
--       -- Link the custom MCNP comment group to the standard Comment highlight group.
--       vim.cmd("highlight link MCNPComment Comment")
--       vim.cmd("highlight link MCNPInlineComment Comment")
--
--     vim.cmd([[
--         syntax keyword MCNPKeywordGroup if else while for
--     ]])
--     vim.cmd("highlight link MCNPKeywordGroup Keyword")
--     end,
--   })
-- end
--
-- return M
--
