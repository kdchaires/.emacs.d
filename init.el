;;; minimum.el --- Oliver Minimum Config -*- lexical-binding: t -*-

;; Homepage: https://github.com/olivertaylor/dotfiles


;;; Commentary:

;; There are many "Emacs starter kits" out there, this one is mine. It is
;; designed to be exceedingly simple. Just copy this one file to
;; ~/.emacs/init.el and open Emacs. Everything should get installed and
;; configured automatically.

;; This is really meant for someone who is comfortable configuring their
;; dotfiles and wants to get started with Emacs in a way that is familiar to
;; that experience. Simply put: if I could travel back in time to the
;; beginning of my Emacs journey, I would give myself this file and say "start
;; with this".


;;; Goals and Philosophy

;; 1. Don't bother learning the Emacs key bindings you don't want to. Once you
;;    learn how to configure Emacs you can create whatever bindings make
;;    sense to you.
;; 2. I'm a Mac user, so this config targets Mac users and sets some of the
;;    most common shortcuts, as well as making the modifier keys behave in a
;;    slightly more predictable way.
;; 3. I use, and recommend, the combination of `straight' and
;;    `use-package' to manage the installation and configuration of packages.
;;    Using these 2 tools makes the package declarations in your init file the
;;    single source of what should be loaded and used by Emacs. Which is a
;;    better first-run experience than the default (in my opinion).
;; 4. I highly recommend, for first-time users, the combination of the
;;    packages `selectrum', `selectrum-prescient', and `marginalia'. These
;;    tools make Emacs easier to explore and discover capabilities. You may
;;    eventually decide they're not for you, but I think they're a great place
;;    to start.
;; 5. Provides some convenience bindings for my most used Emacs features.

;; ---------------------------------------------------------------------------


;;; Settings

;; Discovering the exact behavior of these settings is left as an exercise for
;; the reader. Documentation can be found with "C-h o <symbol>".

;; Keep in mind that there are two kinds of variables, global ones, and
;; buffer-local ones.
;;
;; 'setq' simply sets the value of a variable, so if the variable is global it
;; sets its value globally, and if the variable is buffer local it sets the
;; value locally.
;;
;; 'setq-local' takes a global variable and makes a buffer local "copy" that
;; doesn't effect the global value.
;;
;; 'setq-default' takes a local variable and sets a new default value for all new
;; buffers, but doesn't change it in existing buffers or the default.

(delete-selection-mode t)
(global-visual-line-mode t)
(setq-default truncate-lines t)
(global-auto-revert-mode t)
(set-language-environment "UTF-8")
(setq uniquify-buffer-name-style 'forward)
(setq save-interprogram-paste-before-kill t)


;;; Keyboard modifiers setup

;; The below is designed for Mac users.

;; This makes your command key the 'super' key, which you can bind with "s-a",
;; keep in mind that shift is "S-a".
(setq mac-command-modifier 'super)

;; This makes the left option META and right one OPTION.
(setq mac-option-modifier 'meta)
(setq mac-right-option-modifier 'nil)

;; ===================================================
;; FUNCTIONS
;; ===================================================
(defun kada-toggle-projectile-dired ()
    "Toggle projectile-dired buffer."
    (interactive)
    (if (derived-mode-p 'dired-mode)
	(evil-delete-buffer (current-buffer))
      (if (projectile-project-p)
	  (projectile-dired)
	(dired (file-name-directory buffer-file-name)))))

(defun kada-toggle-dired ()
  "Toggle dired buffer."
  (interactive)
  (if (derived-mode-p 'dired-mode)
      (evil-delete-buffer (current-buffer))
    (dired (file-name-directory (or buffer-file-name "~/")))))

;;; Keybindings

;; To decide what to do, Emacs looks at keymaps in this order: (1) Minor Mode,
;; (2) Major Mode, (3) Global. So if you find yourself with a binding that
;; just doesn't work, it is likely because of an active minor mode binding.

;; <Control>-modified key bindings are case-insensitive. So 'C-A' is identical to
;; 'C-a'. You can bind shifted <Control> keystrokes with 'C-S-a'. All other
;; modifiers are case-sensitive.

;; In the old days ESC was used as a prefix key, but I want ESC to act like it
;; does everywhere else on my system and, you know, escape from things. So
;; I've remapped ESC to `keyboard-quit'.
(define-key key-translation-map (kbd "ESC") (kbd "C-g"))

;; I recommend leaving all of these bindings here and not relying on external
;; pacakges, even if you rebind them later in the config, that way if something
;; gets messed up in your package declarations all of these bindings still work.

;;; Package Management

;; - `straight' is used to install/update packages.
;; - `use-package' is used to precisely control the loading of packages and
;;    configure them.

;; Install the `straight' package if it isn't installed
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Install and load `use-package'
(straight-use-package 'use-package)

;; Tell Straight to use `use-package' config declarations for installation of packages.
(setq straight-use-package-by-default t)

;; Don't load any packages unless explicitly told to do so in the config, see
;; `use-package' documentation for more info. I HIGHLY recommend reading up on this.
;; Until you really understand how use-package loads packages you might drive yourself
;; crazy trying to get a package to load properly.
(setq use-package-always-defer t)

(use-package no-littering
  :demand t
  :config
  (require 'recentf)
  (add-to-list 'recentf-exclude no-littering-var-directory)
  (add-to-list 'recentf-exclude no-littering-etc-directory)
  (setq backup-by-copying t
        delete-old-versions t
        kept-new-versions 6
        kept-old-versions 2
        version-control t)
  (setq backup-directory-alist
        `(("." . ,(no-littering-expand-var-file-name "backup/"))))
  (setq auto-save-list-file-prefix
        (no-littering-expand-var-file-name "auto-save/"))
  (setq auto-save-file-name-transforms
        `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))
  (setq custom-file (no-littering-expand-etc-file-name "custom.el"))
  (load custom-file 'noerror))

;;; Packages

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x))
  :demand
  :config
  (exec-path-from-shell-initialize))

(use-package diminish)

;; Packages come last in the config because, in my experience, they are the
;; most common source of breakage, so if something goes wrong below all of the
;; above settings are still loaded.

(use-package general
  :demand t
  :config
  (general-define-key :states 'insert "M-v" 'clipboard-yank)
  (general-define-key :states 'normal :prefix "SPC"
    "u" 'universal-argument
    "dk" 'describe-key
    "dm" 'describe-mode
    "db" 'describe-bindings
    "dp" 'describe-package
    "dv" 'describe-variable
    "df" 'describe-function
    "da" 'apropos-command
    "dd" 'apropos-documentation
    "di" 'info)
  (general-define-key :keymaps '(normal visual) :prefix "SPC"
    "ln" 'linum-mode
    "ta" 'align-regexp))

(use-package undo-fu
  ;; Undo in Emacs is confusing, for example there's no redo command and you can
  ;; undo an undo. That's fine if you're an Emacs wizard, but this package
  ;; simplifies things so Emacs behaves like you might expect.
  :bind
  ("s-z" . undo-fu-only-undo)
  ("s-Z" . undo-fu-only-redo))

(use-package which-key
  ;; Displays useful pop-ups for when you type an incomplete binding.
  :init
  (which-key-mode 1))

(use-package whole-line-or-region
  ;; the region isn't always 'active' (visible), in those cases, if you call a
  ;; command that acts on a region you'll be acting on an invisible region.
  ;; This package makes it so that only the active region is acted upon, and
  ;; the fallback in the current line, instead of an invisible region.
  :diminish whole-line-or-region-mode
  :init
  (whole-line-or-region-global-mode 1))

(use-package selectrum
  ;; Select things from a nice list.
  :init
  (selectrum-mode 1))

(use-package selectrum-prescient
  ;; Present selection candidates in a useful order.
  :init
  (selectrum-prescient-mode 1)
  (prescient-persist-mode 1))

(use-package marginalia
  ;; Display useful information about the selection candidates.
  :init
  (marginalia-mode 1)
  (setq marginalia-annotators
	'(marginalia-annotators-heavy marginalia-annotators-light)))

(use-package modus-themes
  ;; My preferred theme.
  :init
  (modus-themes-load-operandi))

(use-package evil
  :demand t
  :init
  (setq evil-respect-visual-line-mode t)
  :custom
  (evil-want-C-u-scroll t)
  (evil-want-Y-yank-to-eol t)
  (evil-undo-system 'undo-fu)

  :config
  (defun kada-kill-buffer ()
    "Alias for killing current buffer."
    (interactive)
    (kill-buffer nil))

  (defun kada-kill-other-buffers ()
    "Kill all other buffers."
    (interactive)
    (mapc 'kill-buffer (delq (current-buffer) (buffer-list)))
    (message "cleared other buffers"))

  (defun kada-evil-window-delete-or-die ()
    "Delete the selected window.  If this is the last one, exit Emacs."
    (interactive)
    (condition-case nil
	(evil-window-delete)
      (error (condition-case nil
		 (delete-frame)
	       (error (evil-quit))))))

  (defun kada-save-to-escape ()
    (interactive)
    (save-buffer)
    (evil-normal-state))
  (evil-mode 1)
  (fset 'evil-visual-update-x-selection 'ignore)
  (general-define-key :keymaps 'normal
		      "M-s" 'kada-save-to-escape
		      "C-s" 'kada-save-to-escape
		      "C-a k" 'kada-kill-buffer
		      "C-a c" 'kada-kill-other-buffers
		      "C-a d" 'kada-evil-window-delete-or-die
		      "gb" 'evil-buffer)
  (general-define-key :keymaps 'insert
		      "M-s" 'kada-save-to-escape
		      "C-s" 'kada-save-to-escape))

(use-package company
  :demand t
  :diminish company-mode
  :load-path "lib/"
  :hook (evil-insert-state-exit . company-abort)
  :config
  (global-company-mode)
  (require 'company-simple-complete)
  (setq company-dabbrev-downcase 0
        company-idle-delay 0.2))

(use-package dired
  :straight nil
  :commands auto-revert-mode
  :hook (dired-mode . auto-revert-mode)
  :config
  (setq dired-dwim-target t
        dired-use-ls-dired t
        insert-directory-program "gls") ;; TODO This only on mac
  (put 'dired-find-alternate-file 'disabled nil)
  (general-evil-define-key 'normal dired-mode-map
    "o" 'dired-find-alternate-file
    "RET" 'dired-find-alternate-file
    "C-r" 'revert-buffer
    "r" 'dired-do-redisplay
    "gb" 'evil-buffer
    "M-{" 'evil-prev-buffer
    "M-}" 'evil-next-buffer
    "mc" 'dired-do-copy
    "mm" 'dired-do-rename
    "ma" 'dired-create-directory
    "md" 'dired-do-delete)
  :general
  (:keymaps 'normal :prefix "SPC"
   "tt" 'kada-toggle-dired))

(use-package ivy
  :diminish ivy-mode
  :config
  (ivy-mode 1)
  (setq ivy-initial-inputs-alist nil)
  (eval-after-load 'evil-ex
    '(evil-ex-define-cmd "ls" 'ivy-switch-buffer))
  :general
  (:states 'normal :prefix "SPC"
          "ls" 'ivy-switch-buffer)
  (:keymaps '(ivy-minibuffer-map ivy-mode-map)
   [escape] 'keyboard-escape-quit
   "C-w" 'backward-kill-word
   "C-j" 'ivy-next-line
   "C-k" 'ivy-previous-line))

(use-package counsel
  :demand t
  :diminish counsel-mode
  :config
  (when (eq system-type 'darwin)
    (setq counsel-locate-cmd 'counsel-locate-cmd-mdfind))
  (setq counsel-git-cmd "git ls-files --full-name --exclude-standard --others --cached --"
        counsel-find-file-ignore-regexp "\\(?:\\`\\|[/\\]\\)\\(?:[#.]\\)")
  (counsel-mode 1)
  (defalias 'locate #'counsel-locate)
  :general
  ("M-x" 'counsel-M-x
   "C-x C-f" 'counsel-find-file)
  (:keymaps 'normal :prefix "SPC"
   "mx" 'counsel-M-x
   "ff" 'counsel-find-file
   "fr" 'counsel-recentf
   "kr" 'counsel-yank-pop))

(use-package projectile
  :demand t
  :commands (projectile-project-p)
  :diminish projectile-mode
  :config
  (setq projectile-globally-ignored-files '(".DS_Store" ".class")
        projectile-indexing-method 'hybrid
        projectile-completion-system 'ivy)
  (projectile-mode)
  :general
  (:keymaps 'normal :prefix "SPC"
            "tr" 'kada-toggle-projectile-dired))


(use-package counsel-projectile
  :config
  (defun kada-find-file ()
    "Find a file in a project"
    (interactive)
    (if (projectile-project-p)
	(counsel-projectile-find-file)
      (counsel-find-file)))
  :general
  ("M-P" 'counsel-projectile-switch-project
   "M-p" 'kada-find-file)
  (:states 'normal
	   "C-p" 'kada-find-file)
  (:states 'normal :prefix "SPC"
	   "rg" 'counsel-projectile-rg))


(use-package haskell-mode
  :custom
  (haskell-stylish-on-save t))


(use-package lsp-haskell
  :after lsp
  :demand t
  :custom
  (lsp-haskell-formatting-provider "brittany"))

(use-package dhall-mode
  :mode "\\.dhall\\'")

(use-package lsp-mode
  :commands lsp
  :hook ((haskell-mode haskell-literate-mode) . lsp)
  :custom
  (lsp-prefer-flymake nil)
  (lsp-signature-doc-lines 2)
  (lsp-signature-auto-activate nil)
  (lsp-headerline-breadcrumb-enable nil)
  :general
  (:keymaps 'normal :prefix "SPC"
   "hh" 'lsp-describe-thing-at-point
   "hd" 'lsp-find-definition
   "hr" 'lsp-execute-code-action
   "hs" 'lsp-signature-activate))

(use-package kotlin-mode)

(use-package groovy-mode
  :mode "\\.gradle\\'")


(use-package nix-mode
  :mode "\\.nix\\'")

(use-package adoc-mode
  :mode "\\.adoc\\'")

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :general
  (:keymaps 'markdown-mode-map :states 'normal
   "TAB" 'markdown-cycle))

(use-package drag-stuff
  :diminish drag-stuff-mode
  :init
  (drag-stuff-global-mode 1)
  :config
  (add-to-list 'drag-stuff-except-modes 'org-mode)
  (drag-stuff-define-keys)
  :general
  (:keymaps '(normal visual)
   "C-k" 'drag-stuff-up
   "C-j" 'drag-stuff-down
   "C-h" 'drag-stuff-left
   "C-l" 'drag-stuff-right))

(use-package nyan-mode
  :if (display-graphic-p)
  :demand t
  :config
  (nyan-mode t)
  (setq nyan-animate-nyancat t
        nyan-bar-length 22))

(use-package disable-mouse
  :diminish disable-mouse-mode
  :init
  (global-disable-mouse-mode)
  (mapc #'disable-mouse-in-keymap
	(list evil-motion-state-map
	      evil-normal-state-map
	      evil-visual-state-map
	      evil-insert-state-map)))

(use-package file
  :straight nil
  :general
  (:prefix "C-x"
   "C-d" 'make-directory))

(use-package org
  :init
  (require 'org-tempo))

(use-package ox-gfm
  :after ox
  :demand t)

(use-package doom-themes
  :demand t
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-solarized-light)
  (doom-themes-treemacs-config)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

(when (and (display-graphic-p) (equal system-type 'darwin))
  (setq mac-option-modifier nil)
  (setq mac-command-modifier 'meta)
  (setq mac-pass-command-to-system nil))

;;; End of Config --- Good luck out there!
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("4f01c1df1d203787560a67c1b295423174fd49934deb5e6789abd1e61dba9552" default)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
