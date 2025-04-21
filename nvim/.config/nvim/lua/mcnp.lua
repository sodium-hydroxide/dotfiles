local M = {}


function M.setup(opts)
  opts = opts or {}
  local extensions = opts.extensions or { "mcnp", "in" }

  -- Build file patterns from the given extensions (e.g. "*.mcnp")
  local patterns = {}
  for _, ext in ipairs(extensions) do
    table.insert(patterns, "*." .. ext)
  end

  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = patterns,
    callback = function()
      vim.cmd([[
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
