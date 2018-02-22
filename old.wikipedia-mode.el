;;; wikipedia-mode.el --- Mode for editing Wikipedia articles off-line

;; Copyright (C) 2003, 2004 Chong Yidong

;; Author: Chong Yidong <cyd at stupidchicken com>
;; Version: 0.3.3
;; Keywords: wiki

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2 of
;; the License, or (at your option) any later version.

;; This file is distributed in the hope that it will be
;; useful, but WITHOUT ANY WARRANTY; without even the implied
;; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;; PURPOSE.  See the GNU General Public License for more details.

;; You should have received a copy of the GNU General Public
;; License along with GNU Emacs; if not, write to the Free
;; Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
;; MA 02111-1307 USA

;;; Commentary:

;; This is `wikipedia-mode', a major mode for editing articles written
;; in the markup language used by Wikipedia, the free on-line
;; encyclopedia (http://www.wikipedia.org). It is intended to work
;; with GNU Emacs 21.x, though it may also work with other versions of
;; (X)Emacs.

;; Installing wikipedia-mode
;; =========================
;;
;; Save wikipedia-mode.el in a convenient directory, preferably in
;; your `load-path'. Add the following to your `user-init-file':
;;
;;   (autoload 'wikipedia-mode
;;     "wikipedia-mode.el"
;;     "Major mode for editing documents in Wikipedia markup." t)
;;
;; If you did not save wikipedia-mode.el in your `load-path', you must
;; use the full pathname. On MS Windows, use forward slashes (/)
;; rather than back slashes (\) to indicate the directory, e.g.:
;;
;;   (autoload 'wikipedia-mode
;;     "C:/Documents and Settings/USERNAME/.emacs.d/Wikipedia-mode.el"
;;     "Major mode for editing documents in Wikipedia markup." t)
;;
;; If you want to associate filenames ending in ".wiki" with
;; wikipedia-mode, add the following to your init file:
;;
;;   (setq auto-mode-alist
;;     (cons '("\\.wiki\\'" . wikipedia-mode) auto-mode-alist))

;; Installing longlines-mode
;; =========================
;;
;; Wikipedia articles don't use newline characters to break paragraphs
;; into lines, so each paragraph looks like a super-long line to
;; Emacs. To let Emacs handle "soft word wrapping", you need to
;; download a third-party package, longlines-mode.
;;
;; Download longlines.el, saving into your `load-path':
;;
;;   http://www.emacswiki.org/elisp/longlines.el
;;
;; Add the following to your `user-init-file':
;;
;;   (autoload 'longlines-mode "longlines.el"
;;     "Minor mode for editing long lines." t)

;; Installing MozEx
;; ================
;;
;; If your web browser is Mozilla or Firefox, take a look at the MozEx
;; extension, which allows you to call Emacs for editing text boxes:
;;
;;   http://mozex.mozdev.org/
;;
;; See also
;;
;;   http://www.emacswiki.org/cgi-bin/wiki/FireFox
;;
;; If you mostly use MozEx to edit Wikipedia articles, it might be
;; worthwhile to tell Emacs to enter wikipedia-mode whenever it is
;; called by MozEx. Just add this to your `user-init-file':
;;
;;   (add-to-list 'auto-mode-alist '("mozex.\\.*" . wikipedia-mode))

;; Todo
;; ----
;; * Implement TeX highlighting in <math> environment

;;; Code:

(require 'derived)
(require 'font-lock)

(defvar wikipedia-simple-tags
  '("b" "big" "blockquote" "br" "caption" "code" "center" "cite" "del"
    "dfn" "dl" "em" "i" "ins" "kbd" "math" "nowiki" "ol" "pre" "samp"
    "small" "strike" "strong" "sub" "sup" "tt" "u" "ul" "var")
  "Tags that do not accept arguments.")

(defvar wikipedia-complex-tags
  '("a" "div" "font" "table" "td" "th" "tr")
  "Tags that accept arguments.")

(defvar wikipedia-url-protocols
  '("ftp" "gopher" "http" "https" "mailto" "news")
  "Valid protocols for URLs in Wikipedia articles.")

(defface wikipedia-strong-emphasis-face '((t (:inherit bold-italic)))
  "`wikipedia-mode' face used to highlight text marked with four
apostrophes (e.g. ''''FOO''''.)")
(defvar wikipedia-strong-emphasis-face 'wikipedia-strong-emphasis-face)

(defface wikipedia-strong-face '((t (:inherit bold)))
  "`wikipedia-mode' face used to highlight text marked with three
apostrophes (e.g. '''FOO'''.)")
(defvar wikipedia-strong-face 'wikipedia-strong-face)

(defface wikipedia-emphasis-face '((t (:inherit italic)))
  "`wikipedia-mode' face used to highlight text marked with two
apostrophes (e.g. ''FOO''.)")
(defvar wikipedia-emphasis-face 'wikipedia-emphasis-face)

(defface wikipedia-header-face '((t (:inherit bold)))
  "`wikipedia-mode' face used to highlight section and subsection
headers (e.g. == FOO ==.)")
(defvar wikipedia-header-face 'wikipedia-header-face)

(defvar wikipedia-font-lock-keywords
      (list

  ;; Apostrophe-style text markup
  (cons "''''\\([^']\\|[^']'\\)*?\\(''''\\|\n\n\\)"
        'wikipedia-strong-emphasis-face)
  (cons "'''\\([^']\\|[^']'\\)*?\\('''\\|\n\n\\)"
        'wikipedia-strong-face)
  (cons "''\\([^']\\|[^']'\\)*?\\(''\\|\n\n\\)"
        'wikipedia-emphasis-face)

  ;; Headers and dividers
  (list "^\\(==+\\)\\(.*\\)\\(\\1\\)"
        '(1 font-lock-builtin-face)
        '(2 wikipedia-header-face)
        '(3 font-lock-builtin-face))
  (cons "^-----*" 'font-lock-builtin-face)

  ;; Bare URLs and ISBNs
  (cons (concat "\\(^\\| \\)" (regexp-opt wikipedia-url-protocols t)
                "://[-A-Za-z0-9._\/~%+&#?!=()@]+")
        'font-lock-variable-name-face)
  (cons "\\(^\\| \\)ISBN [-0-9A-Z]+" 'font-lock-variable-name-face)

  ;; Colon indentation, lists, definitions, and tables
  (cons "^\\(:+\\|[*#]+\\||[}-]?\\|{|\\)" 'font-lock-builtin-face)
  (list "^\\(;\\)\\([^:\n]*\\)\\(:?\\)"
        '(1 font-lock-builtin-face)
        '(2 font-lock-doc-face)
        '(3 font-lock-builtin-face))

  ;; Tags and comments
  (list (concat "\\(</?\\)"
                (regexp-opt wikipedia-simple-tags t) "\\(>\\)")
        '(1 font-lock-builtin-face t t)
        '(2 font-lock-function-name-face t t)
        '(3 font-lock-builtin-face t t))
  (list (concat "\\(</?\\)"
                (regexp-opt wikipedia-complex-tags t)
   "\\(\\(?: \\(?:[^\"'/><]\\|\"[^\"]*\"\\|'[^']*'\\)*\\)?\\)\\(>\\)")
        '(1 font-lock-builtin-face t t)
        '(2 font-lock-function-name-face t t)
        '(3 font-lock-doc-face t t)
        '(4 font-lock-builtin-face t t))
  (cons (concat "<!-- \\([^->]\\|>\\|-\\([^-]\\|-[^>]\\)\\)*-->")
        '(0 font-lock-comment-face t t))

  ;; External Links
  (list (concat "\\(\\[\\)\\(\\(?:"
                (regexp-opt wikipedia-url-protocols)
"\\)://[-A-Za-z0-9._\/~%-+&#?!=()@]+\\)\\(\\(?: [^]\n]*\\)?\\)\\(\\]\\)")
        '(1 font-lock-builtin-face t t)
        '(2 font-lock-variable-name-face t t)
        '(3 font-lock-doc-face t t)
        '(4 font-lock-builtin-face t t))

  ;; Wiki links
  '("\\(\\[\\[\\)\\([^]\n|]*\\)\\(|?\\)\\([^]\n]*\\)\\(\\]\\]\\)"
    (1 font-lock-builtin-face t t)
    (2 font-lock-variable-name-face t t)
    (3 font-lock-builtin-face t t)
    (4 font-lock-doc-face t t)
    (5 font-lock-builtin-face t t))

  ;; Wiki variables
  '("\\({{\\)\\(.+?\\)\\(}}\\)"
    (1 font-lock-builtin-face t t)
    (2 font-lock-variable-name-face t t)
    (3 font-lock-builtin-face t t))

  ;; Character entity references
  (cons "&#?[a-zA-Z0-9]+;" '(0 font-lock-type-face t t))

  ;; Preformatted text
  (cons "^ .*$" '(0 font-lock-constant-face t t))

  ;; Math environment (uniform highlight only, no TeX markup)
  (list "<math>\\(\\(\n?.\\)*\\)</math>"
        '(1 font-lock-doc-face t t))))

(defvar wikipedia-imenu-generic-expression
  (list '(nil "^==+ *\\(.*[^\n=]\\)==+" 1))
  "Imenu expression for wikipedia-mode. See `imenu-generic-expression'.")

(defun wikipedia-next-header ()
  "Move point to the end of the next section header."
  (interactive)
  (let ((oldpoint (point)))
    (end-of-line)
    (if (re-search-forward "\\(^==+\\).*\\1" (point-max) t)
        (beginning-of-line)
      (goto-char oldpoint)
      (message "No section headers after point."))))

(defun wikipedia-prev-header ()
  "Move point to the start of the previous section header."
  (interactive)
  (unless (re-search-backward "\\(^==+\\).*\\1" (point-min) t)
    (message "No section headers before point.")))

(defun wikipedia-terminate-paragraph ()
  "In a list, start a new list item. In a paragraph, start a new
paragraph; if the current paragraph is colon indented, the new
paragraph will be indented in the same way."
  (interactive)
  (let (indent-chars)
    (save-excursion
      (beginning-of-line)
      (while (cond ((looking-at "^$") nil)
                   ((looking-at "^\\(\\(?: \\|:+\\|[#*]+\\) *\\)")
                    (setq indent-chars (match-string 1)) nil)
                   ((eq (point) (point-min)) nil)
                   ((progn (forward-line -1) t)))
        t))
    (newline) (if (not indent-chars) (newline) 
		(insert indent-chars))))

(defun wikipedia-link-fill-nobreak-p ()
  "When filling, don't break the line for preformatted (fixed-width)
text or inside a Wiki link. See `fill-nobreak-predicate'."
  (save-excursion
    (let ((pos (point)))
      (or (eq (char-after (line-beginning-position)) ? )
          (if (re-search-backward "\\[\\[" (line-beginning-position) t)
              ;; Break if the link is really really long.
              ;; You often get this with captioned images.
              (null (or (> (- pos (point)) fill-column)
                        (re-search-forward "\\]\\]" pos t))))))))

(defun wikipedia-fill-article ()
  "Fill the entire article."
  (interactive)
  (save-excursion
    (fill-region (point-min) (point-max))))

(defun wikipedia-unfill-article ()
  "Undo filling, deleting stand-alone newlines (newlines that do not
end paragraphs, list entries, etc.)"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward ".\\(\n\\)\\([^# *;:|!\n]\\|----\\)" nil t)
      (replace-match " " nil nil nil 1)))
  (message "Stand-alone newlines deleted"))

;;;###autoload
(define-derived-mode wikipedia-mode text-mode "Wikipedia"
  "Major mode for editing articles written in the markup language used by
Wikipedia, the free on-line encyclopedia (http://www.wikipedia.org).

There are several ways to use wikipedia-mode. One is to copy articles
between Emacs and your web browser's text box. Another way is to use
MozEx, a Mozilla/Firefox web browser extension that allows you to call
Emacs from a text box (http://mozex.mozdev.org/).

Wikipedia articles are usually unfilled: newline characters are not
used for breaking paragraphs into lines. Unfortunately, Emacs does not
handle word wrapping yet. As a workaround, wikipedia-mode turns on
longlines-mode automatically. In case something goes wrong, the
following commands may come in handy:

\\[wikipedia-fill-article] fills the buffer.
\\[wikipedia-unfill-article] unfills the buffer.

The following commands are also defined:

\\[wikipedia-terminate-paragraph]     starts a new list item or paragraph in a context-aware manner.
\\[wikipedia-next-header]     moves to the next (sub)section header.
\\[wikipedia-prev-header]     moves to the previous (sub)section header."

  (set (make-local-variable 'adaptive-fill-regexp) "[ ]*")
  (set (make-local-variable 'comment-start-skip) "\\(?:<!\\)?-- *")
  (set (make-local-variable 'comment-end-skip) " *--\\([ \n]*>\\)?")
  (set (make-local-variable 'comment-start) "<!-- ")
  (set (make-local-variable 'comment-end) " -->")
  (set (make-local-variable 'paragraph-start)
       "\\*\\| \\|#\\|;\\|:\\||\\|!\\|$")
  (set (make-local-variable 'sentence-end-double-space) nil)
  (set (make-local-variable 'font-lock-multiline) t)
  (set (make-local-variable 'font-lock-defaults)
       '(wikipedia-font-lock-keywords t nil nil nil))
  (set (make-local-variable 'fill-nobreak-predicate)
       'wikipedia-link-fill-nobreak-p)
  (set (make-local-variable 'auto-fill-inhibit-regexp) "^[ *#:|;]")

  ;; Support for outline-minor-mode. No key conflicts, so we'll use
  ;; the normal outline-mode prefix.
  (set (make-local-variable 'outline-regexp) "==+")
  (set (make-local-variable 'outline-minor-mode-prefix) "\C-c")

  ;; Turn on the Imenu automatically.
  (when menu-bar-mode
    (set (make-local-variable 'imenu-generic-expression)
         wikipedia-imenu-generic-expression)
    (imenu-add-to-menubar "Contents"))

  (modify-syntax-entry ?< "(>" wikipedia-mode-syntax-table)
  (modify-syntax-entry ?> ")<" wikipedia-mode-syntax-table)

  (define-key wikipedia-mode-map "\M-n" 'wikipedia-next-header)
  (define-key wikipedia-mode-map "\M-p" 'wikipedia-prev-header)
  (define-key wikipedia-mode-map [M-down] 'wikipedia-next-header)
  (define-key wikipedia-mode-map [M-up]   'wikipedia-prev-header)
  (define-key wikipedia-mode-map "\C-j" 'wikipedia-terminate-paragraph)
  (define-key wikipedia-mode-map [(control return)]
    'wikipedia-terminate-paragraph)

  (let ((map (make-sparse-keymap "Wikipedia")))
    (define-key wikipedia-mode-map [menu-bar wikipedia]
      (cons "Wikipedia" map))
    (define-key map [unfill-article]
      '("Unfill article" . wikipedia-unfill-article))
    (define-key map [fill-article]
      '("Fill article" . wikipedia-fill-article))
    (define-key map [separator-fill] '("--"))
    (define-key map [next-header]
      '("Next header" . wikipedia-next-header))
    (define-key map [prev-header]
      '("Previous header" . wikipedia-prev-header))
    (define-key map [separator-header] '("--"))
    (define-key map [outline]
      '("Toggle Outline Mode..." . outline-minor-mode)))

  (define-key wikipedia-mode-map "\C-c\C-q"
    'wikipedia-unfill-article)
  (define-key wikipedia-mode-map "\C-c\M-q"
    'wikipedia-fill-article)

  (make-local-variable 'change-major-mode-hook))

(defun wikipedia-turn-on-longlines ()
  "Turn on longlines-mode if it is defined."
  (if (functionp 'longlines-mode)
      (longlines-mode 1)))
(add-hook 'wikipedia-mode-hook 'wikipedia-turn-on-longlines)
(set (make-local-variable 'auto-fill-inhibit-regexp) "^[ *#:|;]")

;;; wikipedia-mode.el ends here.
 
