;;; wikipedia-mode.el --- Major mode for editing Wikipedia articles

;; Copyright (C) 2003, 2004  Chong Yidong

;; Author: Chong Yidong <cyd@stupidchicken.com>
;; Maintainer: Chong Yidong <cyd@stupidchicken.com>
;; Contributions: Daniel Brockman <drlion@deepwood.net>
;; Version: 0.1.5
;; Keywords: wiki

;; This file is not part of GNU Emacs.
;; This is released under the GNU General Public License.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 2 of the License,
;; or (at your option) any later version.

;; This file is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; if not, write to the Free Software
;; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
;; USA

;;; Commentary:

;; This is `wikipedia-mode', a major mode for editing articles written
;; in the markup language used by Wikipedia, the free on-line
;; encyclopedia (http://www.wikipedia.org/).  It is intended to work
;; with GNU Emacs 21.x, though it may also work with other versions of
;; (X)Emacs.

;; To install this major mode, place wikipedia-mode.el in a convenient
;; directory, preferably one in your `load-path'.  Next, add the
;; following lines to your `user-init-file':
;;
;;   (autoload 'wikipedia-mode "wikipedia-mode.el"
;;    "Major mode for editing documents in Wikipedia markup." t)
;;
;; If you did not save it in a `load-path' directory, replace
;; "wikipedia-mode.el" with the full name of the file.
;;
;; To associate files named *.wiki with wikipedia-mode, add the
;; following to your init file:
;;
;;   (setq auto-mode-alist
;;     (cons '("\\.wiki\\'" . wikipedia-mode) auto-mode-alist))

;;; Todo:

;; * Implement TeX highlighting in <math> environment.

;; * Highlight only until end of paragraph.

;;; Code:

(defvar wikipedia-ignore-standalone-newlines t
  "Whether interparagraphical newlines should go to the clipboard.
If non-nil, stand-alone newlines (i.e., newlines that do not end
paragraphs, list entries, etc.) are not moved to the clipboard by
`wikipedia-copy-article-to-clipboard'.")

(defvar wikipedia-simple-tags
  '("b" "big" "blockquote" "br" "caption" "code" "center" "cite" "dfn"
    "dl" "em" "i" "kbd" "math" "nowiki" "ol" "pre" "samp" "small"
    "strike" "strong" "sub" "sup" "tt" "u" "ul" "var")
  "Tags that never have attributes.")

(defvar wikipedia-complex-tags
  '("a" "div" "font" "table" "td" "th" "tr")
  "Tags that potentially have attributes.")

(defvar wikipedia-url-protocols
  '("ftp" "gopher" "http" "https" "mailto" "news")
  "Valid protocols for URLs in Wikipedia articles.")

(defvar  wikipedia-strong-emphasis-face 'wikipedia-strong-emphasis-face)
(defface wikipedia-strong-emphasis-face
  '((t (:inherit bold-italic)))
 "Face used to highlight text that is both emphasized and strongly
emphasized.  Such text is enclosed in five apostrophes.  Example:

  '''''foo'''''

Note: This only works if there is no other text in between the
emphasis tokens.  For example, none of the following will be
highlighted with this face:

  ''foo '''bar'''''
  '''foo ''bar'''''
  '''''foo'' bar'''

This is a bug.")

(defvar  wikipedia-strong-face 'wikipedia-strong-face)
(defface wikipedia-strong-face
  '((t (:inherit bold)))
 "Face used to highlight strongly emphasized text.
Strongly emphasized text is enclosed by three apostrophes.  Example:

  '''foo'''")

(defvar  wikipedia-emphasis-face 'wikipedia-emphasis-face)
(defface wikipedia-emphasis-face
  '((t (:inherit italic)))
 "Face used to highlight emphasized text.
Emphasized text is enclosed by double apostrophes.  Example:

  ''foo''")

(defvar  wikipedia-header-face 'wikipedia-header-face)
(defface wikipedia-header-face
  '((t (:inherit bold)))
 "Face used to highlight section and subsection headers.
Headers are enclosed by at least two equal signs.  Examples:

  == Foo ==
  ==== Bar ====")

(defvar  wikipedia-resource-face 'wikipedia-resource-face)
(defface wikipedia-resource-face
  '((t (:inherit font-lock-variable-name-face)))
  "Face used to highlight linked URLs and Wikipedia article names.")


(defvar wikipedia-font-lock-keywords
  `(
    
   ;; Apostrophe-style text markup
   ("'''''\\([^']\\|[^']'\\)*'''''" . wikipedia-strong-emphasis-face)
   ("'''\\([^']\\|[^']'\\)*'''" . wikipedia-strong-face)
   ("''\\([^']\\|[^']'\\)*''" . wikipedia-emphasis-face)
   
   ;; Dividers and headers
   ("^-----*" . font-lock-builtin-face)
   ("^\\(==+\\)\\(.*\\)\\(\\1\\)"
    (1 font-lock-builtin-face)
    (2 wikipedia-header-face)
    (3 font-lock-builtin-face))
   
   ;; ISBNs and Bare URLs
   ("\\(^\\| \\)ISBN [-0-9A-Z]+" . wikipedia-resource-face)
   (,(concat "\\(^\\| \\)"
             (regexp-opt wikipedia-url-protocols t)
             "://[-A-Za-z0-9._\/~%+&#?!=()@]+")
    . wikipedia-resource-face)
   
   ;; Colon indentation, lists, and definitions
   ("^\\(:+\\|[*#]+\\)" . font-lock-builtin-face)
   ("^\\(;\\)\\([^:\n]*\\)\\(:?\\)"
    (1 font-lock-builtin-face)
    (2 font-lock-doc-face)
    (3 font-lock-builtin-face))
   
   ;; Tags and comments
   (,(concat "\\(</?\\)"
             (regexp-opt wikipedia-simple-tags t)
             "\\(>\\)")
    (1 font-lock-builtin-face t t)
    (2 font-lock-function-name-face t t)
    (3 font-lock-builtin-face t t))
   (,(concat "\\(</?\\)"
             (regexp-opt wikipedia-complex-tags t)
             "\\(\\(?: \\(?:[^\"'/><]\\|\"[^\"]*\"\\|'[^']*'\\)*"
             "\\)?\\)\\(>\\)")
    (1 font-lock-builtin-face t t)
    (2 font-lock-function-name-face t t)
    (3 font-lock-doc-face t t)
    (4 font-lock-builtin-face t t))
   ("<!-- \\([^->]\\|>\\|-\\([^-]\\|-[^>]\\)\\)*-->"
    . (0 font-lock-comment-face t t))
   
   ;; External Links
   (,(concat "\\(\\[\\)\\(\\(?:"
             (regexp-opt wikipedia-url-protocols)
             "\\)://[A-Za-z0-9._\/~%-+&#?!=()@]+\\)"
             "\\(\\(?: [^]\n]*\\)?\\)\\(\\]\\)")
    (1 font-lock-builtin-face t t)
    (2 wikipedia-resource-face t t)
    (3 font-lock-doc-face t t)
    (4 font-lock-builtin-face t t))
   
   ;; Wiki links
   ("\\(\\[\\[\\)\\([^]\n|]*\\)\\(|?\\)\\([^]\n]*\\)\\(\\]\\]\\)"
    (1 font-lock-builtin-face t t)
    (2 wikipedia-resource-face t t)
    (3 font-lock-builtin-face t t)
    (4 font-lock-doc-face t t)
    (5 font-lock-builtin-face t t))
   
   ;; Character entity references
   ("&#?[a-zA-Z0-9]+;" . (0 font-lock-type-face t t))
   
   ;; Preformatted text
   ("^ .*$" . (0 font-lock-constant-face t t))))

(defun wikipedia-next-header ()
  "Move point to the end of the next section header."
  (interactive)
  (let ((old-point (point)))
    (end-of-line)
    (if (re-search-forward "\\(^==+\\).*\\1" (point-max) t)
        (beginning-of-line)
      (goto-char old-point)
      (message "No section headers after point."))))

(defun wikipedia-prev-header ()
  "Move point to the start of the previous section header."
  (interactive)
  (unless (re-search-backward "\\(^==+\\).*\\1" (point-min) t)
    (message "No section headers before point.")))

(defun wikipedia-terminate-paragraph ()
  "Start a new paragraph or list item.
In a list, start a new list item.  In a paragraph, start a new
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
                   ((progn (forward-line -1) t)))))
    (insert (concat "\n" (or indent-chars "\n")))))

(defun wikipedia-copy-article-from-clipboard ()
  "Yank text from clipboard, and fill the paragraphs.
Copy the clipboard contents to the current buffer, automatically
filling the paragraphs.  If you do not wish the paragraphs to be
filled, use `clipboard-yank' instead."
  (interactive)
  (save-excursion
    (save-excursion (clipboard-yank))
    (fill-paragraph nil)
    (let ((this (forward-paragraph 1))
          (last 0))
      (while (> this last)
        (fill-paragraph nil)
        (setq last this this (forward-paragraph 1))))))
  
(defun wikipedia-copy-article-to-clipboard (arg)
  "Copy the current buffer formatted to the clipboard.
This should be used for pasting into Wikipedia's edit box.

If `wikipedia-ignore-standalone-newlines' is non-nil, we leave
out stand-alone newlines (i.e. those that do not end paragraphs,
list entries, etc.), following the standard procedure on
Wikipedia.

With a prefix argument, copy the region instead of the entire
buffer.

The heuristic for eliminating newlines cannot be perfect. If you
use this function, you should be careful to place your list items
and formatted text (lines starting with [;*#: ]) in cleanly separated
paragraphs.  That is, don't do the following:

  * List item.
  New paragraph immediately below the list item."
  (interactive "P")
  (if interprogram-cut-function
      (let ((x-select-enable-clipboard t)
            (start (if arg (point) (point-min)))
            (end (if arg (mark) (point-max))))
        (funcall interprogram-cut-function 
                 (if wikipedia-ignore-standalone-newlines
                     (replace-regexp-in-string
                      ".\\(\n\\)\\(?:[^# *;:\n]\\|----\\)"
                      " "
                      (buffer-substring start end) t nil 1))
                 t))
    (message "No clipboard is defined in this window system.")))

(defun wikipedia-link-fill-nobreak-p () 
  "When filling, don't break the line inside a Wiki link."
  (save-excursion
    (let ((pos (point)))
      (if (re-search-backward "\\[\\[" (line-beginning-position) t)
          (null (re-search-forward "\\]\\]" pos t))))))

(define-derived-mode wikipedia-mode text-mode "Wikipedia"
  "Major mode for editing articles written in the markup language used by
Wikipedia, the free on-line encyclopedia (http://www.wikipedia.org).

In this major mode, editing functions (such as commenting and
paragraph filling) respect the integrity of Wiki markup. In
addition, Wiki markup elements are highlighted if
`font-lock-mode' or `global-font-lock-mode' are turned on.

The usual way to use Wikipedia mode is to copy text from the Wikipedia
edit box displayed in a web browser into a wikipedia-mode buffer for
editing using `wikipedia-copy-article-from-clipboard'.  The paragraphs
are automatically filled to make them easier to edit.  When done
editing, paste the article text back into the edit box using
`wikipedia-copy-article-to-clipboard'.  Extraneous newline characters
are automatically removed from the copied text.

\\{wikipedia-mode-map}"
  (set (make-local-variable 'adaptive-fill-regexp) "[ ]*")
  (set (make-local-variable 'comment-start-skip) "\\(?:<!\\)?-- *")
  (set (make-local-variable 'comment-end-skip) " *--\\([ \n]*>\\)?")
  (set (make-local-variable 'comment-start) "<!-- ")
  (set (make-local-variable 'comment-end) " -->")
  (set (make-local-variable 'paragraph-start) "\\*\\| \\|#\\|;\\|:\\|$")
  (set (make-local-variable 'sentence-end-double-space) t)
  (set (make-local-variable 'font-lock-multiline) t)
  (set (make-local-variable 'font-lock-defaults)
       '(wikipedia-font-lock-keywords t nil nil nil))

  (modify-syntax-entry ?< "(>" wikipedia-mode-syntax-table)
  (modify-syntax-entry ?> ")<" wikipedia-mode-syntax-table)

  (define-key wikipedia-mode-map "\M-n" 'wikipedia-next-header)
  (define-key wikipedia-mode-map "\M-p" 'wikipedia-prev-header)
  (define-key wikipedia-mode-map [M-down] 'wikipedia-next-header)
  (define-key wikipedia-mode-map [M-up] 'wikipedia-prev-header)
  
  (define-key wikipedia-mode-map "\C-j"
    'wikipedia-terminate-paragraph)
  (define-key wikipedia-mode-map [(control return)]
    'wikipedia-terminate-paragraph)

  (define-key wikipedia-mode-map "\C-c\C-y"
    'wikipedia-copy-article-from-clipboard)
  (define-key wikipedia-mode-map "\C-c\C-w"
    'wikipedia-copy-article-to-clipboard)

  (setq fill-nobreak-predicate #'wikipedia-link-fill-nobreak-p))

(provide 'wikipedia-mode)
;;; wikipedia-mode.el ends here
