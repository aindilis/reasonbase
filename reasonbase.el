;; Load all the wikipedia modes

(autoload 'wikipedia-mode "/var/lib/myfrdcsa/codebases/internal/reasonbase/wikipedia-mode.el"
	  "Major mode for editing documents in Wikipedia markup." t)
(add-to-list 'auto-mode-alist
	     '("\\.wiki$" . wikipedia-mode))
;; (add-to-list 'auto-mode-alist
;;	     '("en\\.wikipedia\\.org" . wikipedia-mode))
;; (setq text-mode-hook (quote (#[nil "\300\301!\207" [flyspell-mode 1] 2] flyspell-buffer text-mode-hook-identify)))
(autoload 'longlines-mode "longlines.el"
	  "Minor mode for editing long lines." t)
;; (add-to-list 'auto-mode-alist '("mozex.\\.*" . wikipedia-mode))
;; (add-to-list 'auto-mode-alist '("index.\\.*" . wikipedia-mode))

;; WIKI STUFF

;; (global-set-key "\C-c\C-gf" 'rb-wiki-list-pages)

;; (define-key wikipedia-mode-map "\C-c\C-ga"
;;  'rb-article-at-point)

;; (define-key wikipedia-mode-map "\C-c\C-gg"
;;  'rb-mvs-get-article-at-point)

(defun rb-wiki-article-at-point ()
 "Return the article at point if any"
 (interactive)
 (thing-at-point 'wikiarticle))

(defun forward-wikiarticle (arg)
  (interactive "p")
  (if (natnump arg) 
   (progn
    (re-search-forward "\]\]" nil 'move arg)
    (backward-char)
    (backward-char)
    )
   (progn
    (re-search-backward "\\[\\[" nil 'move)
    (forward-char)
    (forward-char)
    )))

(defun rb-wiki-mvs-get-article-at-point ()
 "get "
 (interactive)
 (shell-command (concat "/home/andrewd/mvs-client \"" (rb-wiki-article-at-point) "\"")))

(setq rb-wiki-data-directory
 "/var/lib/myfrdcsa/codebases/internal/reasonbase/data")

(defun rb-wiki-logon ()
 "logon to the appropriate service"
 (interactive))

(defun rb-wiki-get-server-directory ()
 "return rb-wiki-server-directory if exists or query it then return"
 (interactive)
 (if (not (boundp 'rb-wiki-server-directory))
  (rb-wiki-select-server))
 ;; if we're not logged on, do that
 rb-wiki-server-directory)

(defun rb-choose-file-from-dir (dir)
  "program to select a directory"
  (interactive "S")
  (let* ((lists (list dir))
	 (name-dir
	  (apply 'append
		 (mapcar
		  (lambda (dir)
			  (mapcar (lambda (name)
					  (list name dir))
				  (directory-files dir nil "[^\.]")))
		  lists)))
	 (selected-name
	  ;; (iswitchb-read-buffer "Entity: "))
	  (completing-read "Entity: " name-dir))
	 (directory
	  (concat
	   (cadr (assoc selected-name name-dir))
	   "/"
	   selected-name)))
	directory))

(defun rb-wiki-select-server ()
 "Select from which server to communicate"
 (interactive)
 ;; do a
 (setq rb-wiki-server-directory (rb-choose-file-from-dir rb-wiki-data-directory)))

(defun rb-wiki-list-pages ()
 "List the pages that we have for this server"
 (interactive)
 (ffap (rb-choose-file-from-dir (rb-wiki-get-server-directory))))

(defun rb-wiki-convert-link-to-file (link)
 "get file name for link"
 (interactive)
 (concat (rb-wiki-get-server-directory) link ".wiki"))

(defun rb-wiki-follow-link ()
 "Follow the link in the wiki, downloading the content if necessary"
 (interactive)
 (rb-wiki-convert-link-to-file (rb-wiki-article-at-point))
 )

(defun rb-wiki-commit-current-page ()
 "Follow the link in the wiki, downloading the content if necessary"
 (interactive)
 )
