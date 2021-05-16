;; Change defaults to ensure cleaniness
(defalias 'yes-or-no-p 'y-or-n-p)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq ring-bell-function 'ignore)
(setq make-backup-files nil)
(setq inhibit-startup-message t)
;; Move custom file out of here
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)
;; Suggested by lsp-mode. Maybe experiment with this
(setq gc-cons-threshold 100000000)

;; Package manager setup
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Don't use command for special characters
(setq mac-option-modifier 'meta)

;; UI Configuration
(set-frame-font "JetBrains Mono 15")
(load-theme 'solarized-light t)

;; Say no to tabs. And use 2 spaces always
(setq indent-tabs-mode nil)
(setq-default tab-width 2)

;; So Long Large Files
(global-so-long-mode 1)

;; Configure built-in modes
(subword-mode 1)
(electric-pair-mode 1)

;; Package configurations
(use-package expand-region
  :bind ("C-=" . er/expand-region))

(use-package multiple-cursors
  :bind (("C->" . mc/mark-next-like-this)
         ("C-<" . 'mc/mark-previous-like-this)
         ("C-c C-<" . 'mc/mark-all-like-this)))

;; Ivy configuration taken from github docs
(use-package ivy
  :bind (("C-c C-s" . swiper)
         ("C-c C-r" . ivy-resume)
         ("<f6>" . ivy-resume)
         ("M-x" . counsel-M-x)
         ("M-y" . counsel-yank-pop)
         ("C-x C-f" . counsel-find-file)
         ("<f1> f" . counsel-describe-function)
         ("<f1> v" . counsel-describe-variable)
         ("<f1> o" . counsel-describe-symbol)
         ("<f1> l" . counsel-find-library)
         ("<f2> i" . counsel-info-lookup-symbol)
         ("<f2> u" . counsel-unicode-char)
         ("C-c g" . counsel-git)
         ("C-c j" . counsel-git-grep)
         ("C-c f" . counsel-ag)
         ("C-x l" . counsel-locate))
  :config (ivy-mode))

;; Language Related Modes/Configurations & Overrides

;; Common LSP Configuration
(use-package lsp-mode
  :hook ((elixir-mode . lsp)
         (go-mode . lsp))
  :commands (lsp lsp-deferred)
  :init (add-to-list 'exec-path "~/.lsp-servers/elixir-server/"))

;; Common Runner Configuration
(use-package quickrun
  :bind ("C-c e b" . quickrun))

;; Golang Configuration
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

;; Elixir Configuration
(use-package exunit
  :bind (("C-c t ." . exunit-verify-single)
         ("C-c t f" . exunit-verify)))

(defun elixir-save-hooks ()
  (add-hook 'before-save-hook #'elixir-format t t))

(add-hook 'elixir-mode-hook #'elixir-save-hooks)

;; Utility Functions Taken from all over the internet

;; Revert current buffer
(global-set-key
 (kbd "<f5>")
 (lambda ()
   (interactive)
   (revert-buffer t t t)
   (message "buffer is reverted")))

;; Use c-u m-x to reverse sort
(defun sort-words (reverse beg end)
  (interactive "*P\nr")
  (sort-regexp-fields reverse "\\w+" "\\&" beg end))

(global-set-key (kbd "C-c M-w") 'sort-words)

(defun sort-symbols (reverse beg end)
  (interactive "*P\nr")
  (sort-regexp-fields reverse "\\(\\sw\\|\\s_\\)+" "\\&" beg end))

(defun toggle-camelcase-underscores ()
  "Toggle between camcelcase and underscore notation for the symbol at point."
  (interactive)
  (save-excursion
    (let* ((bounds (bounds-of-thing-at-point 'symbol))
           (start (car bounds))
           (end (cdr bounds))
           (currently-using-underscores-p (progn (goto-char start)
                                                 (re-search-forward "_" end t))))
      (if currently-using-underscores-p
          (progn
            (upcase-initials-region start end)
            (replace-string "_" "" nil start end)
            (downcase-region start (1+ start)))
        (replace-regexp "\\([A-Z]\\)" "_\\1" nil (1+ start) end)
        (downcase-region start end)))))

(global-set-key (kbd "C-c _") 'toggle-camelcase-underscores)

(defun hyphen-underscore-region (start end)
  "Replace underscore by space in region."
  (interactive "r")
  (save-restriction
    (narrow-to-region start end)
    (goto-char (point-min))
    (while (search-forward "-" nil t) (replace-match "_")) ))

(global-set-key (kbd "C-c -") 'hyphen-underscore-region)

(defun lines-to-csv (separator)
  "Converts the current region lines to a single line, CSV value, separated by the provided separator string."
  (interactive "sEnter separator character: ")
  (setq current-region-string (buffer-substring-no-properties (region-beginning) (region-end)))
  (insert
   (mapconcat 'identity
              (split-string current-region-string "\n")
              separator)))

(defun csv-to-lines (separator)
  "Converts the current region line, as a csv string, to a set of independent lines, splitting the string based on the provided separator."
  (interactive "sEnter separator character: ")
  (setq current-region-string (buffer-substring-no-properties (region-beginning) (region-end)))
  (insert
   (mapconcat 'identity
              (split-string current-region-string separator)
              "\n")))

;; Mouse side button key bindings
(global-set-key (kbd "<mouse-4>") 'previous-buffer)
(global-set-key (kbd "<mouse-5>") 'next-buffer)
