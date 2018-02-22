(autoload 'wikipedia-mode "/var/lib/myfrdcsa/codebases/internal/reasonbase/wikipedia-mode.el"
	  "Major mode for editing documents in Wikipedia markup." t)
(add-to-list 'auto-mode-alist
	     '("\\.wiki\\'" . wikipedia-mode))
(add-to-list 'auto-mode-alist
	     '("en\\.wikipedia\\.org" . wikipedia-mode))
(setq text-mode-hook (quote (#[nil "\300\301!\207" [flyspell-mode 1] 2] flyspell-buffer text-mode-hook-identify)))
(autoload 'longlines-mode "longlines.el"
	  "Minor mode for editing long lines." t)
(add-to-list 'auto-mode-alist '("mozex.\\.*" . wikipedia-mode))
(add-to-list 'auto-mode-alist '("index.\\.*" . wikipedia-mode))
